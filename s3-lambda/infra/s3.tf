resource "aws_s3_bucket" "bucket01" {
  bucket = var.s3_bucket_name

  tags = {
    Name        = "Bucket 01"
    Environment = "Dev"
    CreateFrom  = "Terraform"
  }
}

resource "aws_s3_bucket_notification" "bucket01_notification_lambda" {
  bucket = aws_s3_bucket.bucket01.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.lambda01.arn
    events              = ["s3:ObjectCreated:*"]
    # filter_prefix       = "AWSLogs/"
    # filter_suffix       = ".log"
  }

  depends_on = [aws_lambda_permission.allow_bucket]
}