variable "region" {
  type = string
}

variable "lambda_name" {
  description = "Name of lambda_function"
  type        = string
}

variable "lambda_package_path" {
  description = "Path to the Lambda deployment package (ZIP or binary)"
  type        = string
}

variable "dynamodb_table_name" {
  description = "Name of the DynamoDB table"
  type        = string
}


variable "lambda_environment_variables" {
  description = "Map of environment variables for the Lambda function"
  type        = map(string)
  default     = {}
}
