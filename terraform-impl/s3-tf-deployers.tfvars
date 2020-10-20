s3_bucket_name = "marcello-bucket"

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
