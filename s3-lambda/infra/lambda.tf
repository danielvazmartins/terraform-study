data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "aws_iam_policy_document" "policy_cloudwatch" {
  statement {
    effect    = "Allow"
    actions   = [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
    ]
    resources = ["arn:aws:logs:*"]
  }
}

resource "aws_iam_policy" "policy_cloudwatch" {
  name        = "log_in_cloudwatch"
  description = "Permission to Lambda save logs in Cloudwatch"
  policy      = data.aws_iam_policy_document.policy_cloudwatch.json
}

data "aws_iam_policy_document" "policy_s3" {
  statement {
    effect    = "Allow"
    actions   = [
        "s3:GetObject"
    ]
    resources = ["arn:aws:s3:::*/*"]
  }
}

resource "aws_iam_policy" "policy_s3" {
  name        = "read_s3_file"
  description = "Permission to Lambda get file from S3"
  policy      = data.aws_iam_policy_document.policy_s3.json
}


resource "aws_iam_policy_attachment" "lambda_policies" {
  name       = "lambda_policies"
  roles      = [aws_iam_role.iam_for_lambda.name]
  policy_arn = aws_iam_policy.policy_cloudwatch.arn
}

resource "aws_iam_policy_attachment" "lambda_policies_s3" {
  name       = "lambda_policies_s3"
  roles      = [aws_iam_role.iam_for_lambda.name]
  policy_arn = aws_iam_policy.policy_s3.arn
}

resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda01.arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.bucket01.arn
}

data "archive_file" "lambda" {
  type        = "zip"
  source_dir  = "../lambda/dist"
  output_path = "../files/lambda_function_payload.zip"
}

resource "aws_lambda_function" "lambda01" {
  function_name = "lambda01"
  handler       = "index.handler"
  runtime       = "nodejs18.x"

  role = aws_iam_role.iam_for_lambda.arn

  filename         = data.archive_file.lambda.output_path
  source_code_hash = data.archive_file.lambda.output_base64sha256
}