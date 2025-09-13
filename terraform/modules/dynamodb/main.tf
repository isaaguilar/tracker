terraform {
  required_version = ">= 1.5"
  backend "s3" {}
  required_providers {
    aws = ">= 5.71.0"
  }
}

provider "aws" {
  region = var.region
}

resource "aws_dynamodb_table" "table" {
  name           = var.table_name
  billing_mode   = "PROVISIONED"
  read_capacity  = 1
  write_capacity = 1

  hash_key  = var.hash_key
  range_key = var.range_key

  attribute {
    name = var.hash_key
    type = var.hash_key_type
  }

  attribute {
    name = var.range_key
    type = var.range_key_type
  }

  tags = {
    Environment = "dev"
    Project     = var.project
  }
}

