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

data "aws_dynamodb_table" "table" {
  name = var.dynamodb_table_name
}

resource "aws_iam_role" "lambda_exec_role" {
  name = "${var.lambda_name}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Principal = {
        Service = "lambda.amazonaws.com"
      },
      Effect = "Allow",
      Sid    = ""
    }]
  })
}



resource "aws_iam_policy" "dynamodb_access" {
  name        = "${data.aws_dynamodb_table.table.name}-access"
  description = "Allow Lambda to access DynamoDB"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "dynamodb:PutItem",
          "dynamodb:Scan",
          "dynamodb:DescribeTable"
        ],
        Resource = data.aws_dynamodb_table.table.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attach" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = aws_iam_policy.dynamodb_access.arn
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "rust_lambda" {
  function_name = var.lambda_name
  role          = aws_iam_role.lambda_exec_role.arn
  handler       = "bootstrap"
  runtime       = "provided.al2023"

  filename         = var.lambda_package_path
  source_code_hash = filebase64sha256(var.lambda_package_path)

  timeout     = 60
  memory_size = 128

  environment {
    variables = var.lambda_environment_variables
  }

  publish = true
}

resource "aws_lambda_function_url" "rust_lambda_url" {
  function_name      = aws_lambda_function.rust_lambda.function_name
  authorization_type = "NONE"

  cors {
    allow_credentials = false
    allow_origins     = ["*"]
    allow_methods     = ["*"]
    allow_headers     = ["*"]
    expose_headers    = ["*"]
    max_age           = 86400
  }
}




