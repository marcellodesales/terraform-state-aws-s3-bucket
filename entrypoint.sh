#!/bin/bash

###
### https://stackoverflow.com/questions/47913041/initial-setup-of-terraform-backend-using-terraform/59903802#59903802
###

# Use the settings from your local 'default' profile
if [ ! -z "$USE_LOCAL_CONFIG" ]; then
  eval $(bash aws-env.sh)
  echo ""
  echo "Loaded AWS_PROFILE '${AWS_PROFILE}'"
  # https://stackoverflow.com/questions/8928224/trying-to-retrieve-first-5-characters-from-string-in-bash-error/56711828#56711828
  #
  echo "AWS_REGION='$(echo ${AWS_SECRET_ACCESS_KEY::5})**********$(echo ${AWS_SECRET_ACCESS_KEY: -5})'"
  echo "AWS_ACCESS_KEY_ID='$(echo ${AWS_ACCESS_KEY_ID::7})**********$(echo ${AWS_ACCESS_KEY_ID: -7})'"
  echo "AWS_SECRET_ACCESS_KEY='$(echo ${AWS_SECRET_ACCESS_KEY::7})**********$(echo ${AWS_SECRET_ACCESS_KEY: -7})'"
  echo "AWS_SESSION_TOKEN='$(echo ${AWS_SESSION_TOKEN::7})**********$(echo ${AWS_SESSION_TOKEN: -7})'"
  echo ""

else
  : ${AWS_REGION:?"Need to set 'AWS_REGION' non-empty"}
  : ${AWS_ACCESS_KEY_ID:?"Need to set 'AWS_ACCESS_KEY_ID' non-empty"}
  : ${AWS_SECRET_ACCESS_KEY:?"Need to set 'AWS_SECRET_ACCESS_KEY' non-empty"}
fi

: ${BUCKET_NAME:?"Need to provide the bucket name 'BUCKET_NAME'"}

# Delete first is simpler
if [ ! -z "${DELETE_BUCKET}" ]; then
  echo "* Deleting bucket policy for bucket ${BUCKET_NAME}"
  aws s3api delete-bucket-policy --bucket ${BUCKET_NAME}
  echo "* Deleting bucket ${BUCKET_NAME}"
  aws s3 rb s3://${BUCKET_NAME} --force
  if [ ! -z "${BUCKET_DEPLOYER_USER}" ]; then
    echo "* Deleting user policies..."
    aws iam list-attached-user-policies --user-name ${BUCKET_DEPLOYER_USER} | jq '.AttachedPolicies[].PolicyArn' -r | xargs -I {} aws iam detach-user-policy --user-name ${BUCKET_DEPLOYER_USER} --policy-arn {}
    echo "* Deleting user ${BUCKET_DEPLOYER_USER}..."
    aws iam delete-user --user-name ${BUCKET_DEPLOYER_USER}
  fi
  echo ""
  echo "Done."
  exit 0

else
  : ${BUCKET_DEPLOYER_USER:?"Need to provide a user for the bucket with 'BUCKET_DEPLOYER_USER'"}

  echo "* Verifying if bucket '${BUCKET_NAME}' exists..."
  # Verify if it exists first by trying to list... It shows errors if it does
  aws s3 ls s3://${BUCKET_NAME} || \

  echo "" && \
  echo "* Creating a new bucket ${BUCKET_NAME}" && \
  # Just create it in case it doesn't exist
  aws s3api create-bucket --bucket ${BUCKET_NAME} \
    --region ${AWS_REGION} \
    --create-bucket-configuration \
    LocationConstraint=${AWS_REGION} && \

  echo ""
  echo "* Adding settings for security and reliability (AES256 encryption)" && \
  # Then, update it for security and reliability
  aws s3api put-bucket-encryption \
    --bucket ${BUCKET_NAME} \
    --server-side-encryption-configuration={\"Rules\":[{\"ApplyServerSideEncryptionByDefault\":{\"SSEAlgorithm\":\"AES256\"}}]} && \

  # Enable versioning
  echo ""
  echo "* Enabling bucket versioning" && \
  aws s3api put-bucket-versioning --bucket ${BUCKET_NAME} --versioning-configuration Status=Enabled
fi

# If it's to create a user
if [ ! -z "${BUCKET_DEPLOYER_USER}" ]; then
  echo ""
  echo "* Creating user '${BUCKET_DEPLOYER_USER}'" && \

  # Create the deploy user
  DEPLOYER_USER_ARN=$(aws iam create-user --user-name ${BUCKET_DEPLOYER_USER} | jq -r '.User.Arn')
  echo "- User '${BUCKET_DEPLOYER_USER}' created as user ${DEPLOYER_USER_ARN}"

  # Assign the roles for S3 and DynamoDB (locking state)
  echo ""
  echo "* Attaching role policies to control S3 and DynamoDB (lock table)"
  ROLES=( AmazonS3FullAccess AmazonDynamoDBFullAccess )
  for ROLE in "${ROLES[@]}"
  do
    echo "- Attaching policy '${ROLE}' to user ${BUCKET_DEPLOYER_USER}"
    aws iam attach-user-policy --policy-arn arn:aws:iam::aws:policy/${ROLE} --user-name ${BUCKET_DEPLOYER_USER}
  done

  # Create a policy for the user
  echo ""
  echo "* Assigning policy for the user to use the bucket"
  # https://stackoverflow.com/questions/23929235/multi-line-string-with-extra-space-preserved-indentation/23930212#23930212
  cat <<-EOF >> deployer-s3-access-policy.json
{
      "Id": "Deployer-S3-Access-Policy",
      "Version":"2012-10-17",
      "Statement": [
          {
              "Effect": "Allow",
              "Principal": {
                  "AWS": "${DEPLOYER_USER_ARN}"
              },
              "Action": "s3:*",
              "Resource": "arn:aws:s3:::${BUCKET_NAME}"
          }
      ]
}
EOF
  cat deployer-s3-access-policy.json
  echo ""

  # https://github.com/terraform-providers/terraform-provider-aws/issues/8905#issuecomment-706042496
  # https://docs.aws.amazon.com/IAM/latest/UserGuide/troubleshoot_general.html#troubleshoot_general_eventual-consistency
  echo "* Sleepting 10s until the user account has been propagated"
  sleep 10

  echo "* Putting policy above to bucket..."
  # https://stackoverflow.com/questions/18660798/here-document-gives-unexpected-end-of-file-error/18660985#18660985
  aws s3api put-bucket-policy --bucket ${BUCKET_NAME} --policy file://deployer-s3-access-policy.json

  echo ""
  echo "Done."
  echo ""
  echo "1. Don't forget to run 'create-dynamodb-lock-table.tf' for locking mechanism"
  echo ""
  cat create-dynamodb-lock-table.tf
  echo ""
  echo "- terraform plan -out \"planfile\" && terraform apply -input=false -auto-approve \"planfile\""
  echo ""
  echo "2. Setup your terraform.tf with the s3 state settings with the table"
  echo ""
  cat terraform.tf
fi
