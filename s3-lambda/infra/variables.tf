variable "lambda_function_name" {
  description = "Name of the Lambda"
  type = string
}

variable "s3_bucket_name" {
  description = "Name of the bucket"
  type        = string
}

variable "dynamodb_table_name" {
  description = "Name of DynamoDB table"
  type        = string
}