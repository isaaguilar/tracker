output "function_url" {
  description = "Public Function URL"
  value       = aws_lambda_function_url.rust_lambda_url.function_url
}
