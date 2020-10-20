# terraform.tf

variable "bucket_name" {
  default = "terraform-remote-store"
}

variable "aws_region" {
  default = "sa-east-1"
}

variable "dynamodb_table" {
  default = "terraform-state-lock-dynamo"
}
# 
# provider "aws" {
#   region                  = var.aws_region
#   shared_credentials_file = "~/.aws/credentials"
#   profile                 = "default"
# }

terraform {
  backend "s3" {
    bucket         = var.bucket_name
    encrypt        = true
    key            = "terraform.tfstate"
    region         = var.aws_region
    dynamodb_table = var.dynamodb_table
  }
}

# the rest of your configuration and resources to deploy
