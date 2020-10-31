# S3 Bucket for Terraform State

* Setup an AWS S3 Bucket to use as a terraform backend.

# Setup

* Install the latest verison of terraform
* Update the file `s3-tf-deployers.tfvars`.

> NOTE: Make sure to select the s3 bucket name that's globally unique!
> * Make sure to update the other info.

```terraform
s3_bucket_name = "my-terraform-state-bucket"

deploy_policy_arns = [
  "arn:aws:iam::aws:policy/AmazonS3FullAccess",
  "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
]

# https://stackoverflow.com/questions/40631977/how-do-i-use-terraform-to-maintain-manage-iam-users/57416414#57416414
deploy_users = {
  "terraform-deployer" = {
    path          = "/"
    force_destroy = true
    tag_email     = "nobody@example.com"
  }
}

# Dynamo lock table's default name if needed to be different
# dynamodb_state_table = "terraform-state-lock-dynamo"
```

# Running

* Run `terraform apply` with the tfvars file above.

```console
$ terraform apply --auto-approve -var-file s3-tf-deployers.tfvars
module.iam_group_with_policies.aws_iam_group.this[0]: Refreshing state... [id=terraform-deployers]
aws_dynamodb_table.dynamodb-terraform-state-lock: Refreshing state... [id=terraform-state-lock-dynamo]
aws_kms_key.objects: Refreshing state... [id=7b3125a7-f0d1-48c8-a7d5-469f88e6b682]
aws_iam_user.deployer["terraform-deployer"]: Refreshing state... [id=terraform-deployer]
module.iam_group_with_policies.data.aws_partition.current: Refreshing state...
module.iam_group_with_policies.data.aws_caller_identity.current[0]: Refreshing state...
data.aws_canonical_user_id.current: Refreshing state...
module.iam_group_with_policies.aws_iam_group_policy_attachment.custom_arns[0]: Refreshing state... [id=terraform-deployers-20201020170440211600000002]
module.iam_group_with_policies.aws_iam_group_policy_attachment.custom_arns[1]: Refreshing state... [id=terraform-deployers-20201020170440248800000003]
aws_s3_bucket_policy.terraform_state: Refreshing state... [id=marcello-bucket]
module.iam_group_with_policies.aws_iam_group_membership.this[0]: Refreshing state... [id=terraform-deployers]
module.iam_group_with_policies.data.aws_iam_policy_document.iam_self_management: Refreshing state...
module.iam_group_with_policies.aws_iam_policy.iam_self_management[0]: Refreshing state... [id=arn:aws:iam::761010771720:policy/IAMSelfManagement-20201020170400073200000001]
module.s3_bucket.aws_s3_bucket.this[0]: Refreshing state... [id=marcello-bucket]
module.iam_group_with_policies.aws_iam_group_policy_attachment.iam_self_management[0]: Refreshing state... [id=terraform-deployers-20201020170441526600000004]
module.s3_bucket.aws_s3_bucket_public_access_block.this[0]: Refreshing state... [id=marcello-bucket]

Apply complete! Resources: 0 added, 0 changed, 0 destroyed.

Outputs:

this_dynamodb_lock_state_table = arn:aws:dynamodb:sa-east-1:761010771720:table/terraform-state-lock-dynamo
this_s3_bucket_arn = arn:aws:s3:::marcello-bucket
this_s3_bucket_bucket_domain_name = marcello-bucket.s3.amazonaws.com
this_s3_bucket_bucket_regional_domain_name = marcello-bucket.s3.sa-east-1.amazonaws.com
this_s3_bucket_hosted_zone_id = Z7KQH4QJS55SO
this_s3_bucket_id = marcello-bucket
this_s3_bucket_region = sa-east-1
this_terraform_deployer_users = {
  "terraform-deployer" = "arn:aws:iam::761010771720:user/terraform-deployer"
}
```

# Use in terraform projects

* View the current state by using `terraform output`

```console
$ terraform output
this_dynamodb_lock_state_table = arn:aws:dynamodb:sa-east-1:761010771720:table/terraform-state-lock-dynamo
this_s3_bucket_arn = arn:aws:s3:::marcello-bucket
this_s3_bucket_bucket_domain_name = marcello-bucket.s3.amazonaws.com
this_s3_bucket_bucket_regional_domain_name = marcello-bucket.s3.sa-east-1.amazonaws.com
this_s3_bucket_hosted_zone_id = Z7KQH4QJS55SO
this_s3_bucket_id = marcello-bucket
this_s3_bucket_region = sa-east-1
this_terraform_deployer_users = {
  "terraform-deployer" = "arn:aws:iam::761010771720:user/terraform-deployer"
}
```

* In your terraform provider's file, add the backend setup

```terraform
terraform {
  required_version = "~> 0.12.24" # which means ">= 0.12.24" and "< 0.13"
  backend "s3" {}
}
```

* Create the file backend file

```console
$ cat backend.tfvars
bucket               = "my-terraform-state-bucket"
dynamodb_table       = "terraform-state-lock-dynamo"
key                  = "tf-state.json"
region               = "sa-east-1"
workspace_key_prefix = "segment"
```
