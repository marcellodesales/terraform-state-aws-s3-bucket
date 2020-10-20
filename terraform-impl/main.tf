data "aws_canonical_user_id" "current" {}

variable "aws_region" {
  default = "sa-east-1"
}

variable "s3_bucket_name" {
  default = "super-crazy-name"
}

provider "aws" {
  region = var.aws_region
}

resource "aws_kms_key" "objects" {
  description             = "KMS key is used to encrypt bucket objects"
  deletion_window_in_days = 7
}

variable "s3_force_delete" {
  default = false
}

module "s3_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  #create_bucket = false
  force_destroy = var.s3_force_delete

  bucket = var.s3_bucket_name
  acl    = "private"

  versioning = {
    enabled = true
  }

  tags = {
    Owner       = "Terraform"
    Description = "Used by terraform state during development"
  }

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        kms_master_key_id = aws_kms_key.objects.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }
}

# Define policy ARNs as list
variable "deploy_users" {
  description = "List of users to deploy"
  type        = map
}

#########################################
# IAM user, login profile and access key
#########################################
resource "aws_iam_user" "deployer" {
  # https://stackoverflow.com/questions/40631977/how-do-i-use-terraform-to-maintain-manage-iam-users/57416414#57416414
  for_each      = var.deploy_users
  name          = each.key
  path          = each.value["path"]
  force_destroy = each.value["force_destroy"]
  tags          = map("EmailAddress", each.value["tag_email"])
}

variable "deploy_policy_arns" {
  description = "List of users to deploy"
  type        = list
}

# https://github.com/terraform-aws-modules/terraform-aws-iam/tree/v2.5.0#usage
module "iam_group_with_policies" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-group-with-policies"
  version = "~> 2.0"

  name = "terraform-deployers"

  group_users                       = keys(var.deploy_users)
  attach_iam_self_management_policy = true
  custom_group_policy_arns          = var.deploy_policy_arns
}

# List of users' arn 
locals {
  deployer_arns = [
    for deployer in aws_iam_user.deployer : deployer.arn
  ]
}

resource "aws_s3_bucket_policy" "terraform_state" {
  bucket = var.s3_bucket_name
  policy = <<EOF
{
      "Id": "Deployer-S3-Access-Policy",
      "Version":"2012-10-17",
      "Statement": [
          {
              "Effect": "Allow",
              "Principal": {
                  "AWS": ${jsonencode(local.deployer_arns)}
              },
              "Action": "s3:*",
              "Resource": "arn:aws:s3:::${var.s3_bucket_name}"
          }
      ]
}
EOF
}

# create-dynamodb-lock-table.tf
resource "aws_dynamodb_table" "dynamodb-terraform-state-lock" {
  name           = "terraform-state-lock-dynamo"
  hash_key       = "LockID"
  read_capacity  = 20
  write_capacity = 20
  attribute {
    name = "LockID"
    type = "S"
  }
}
