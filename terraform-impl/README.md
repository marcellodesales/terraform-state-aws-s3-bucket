# Setup S3 Bucket for Terraform

* Setup an AWS S3 Bucket to use as a terraform backend

```shell
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
