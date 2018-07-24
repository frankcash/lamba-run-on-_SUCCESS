provider "aws" {
  region = "us-east-1"
}

resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda_trigger_exec_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "basic-exec-role" {
  role       = "${aws_iam_role.lambda_exec_role.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

// Analytics policy to check S3
data "aws_iam_policy_document" "lambda_exec-policy_document" {
  statement {
    actions = [
      "s3:*",
    ]

    resources = [
      "*",
    ]
  }
}

resource "aws_iam_policy" "lambda_exec-policy" {
  name        = "lambda_exec-policy"
  path        = "/"
  description = "Policy for analytics lambda triggers"
  policy      = "${data.aws_iam_policy_document.lambda_exec-policy_document.json}"
}

resource "aws_iam_role_policy_attachment" "lambda_exec-policy" {
  role       = "${aws_iam_role.lambda_exec_role.name}"
  policy_arn = "${aws_iam_policy.lambda_exec-policy.arn}"
}

variable "bucket_name" {
  type        = "string"
  description = "S3 Bucket Name"
  default     = "lambda-run-on-success"
}

// Define Lambda
resource "aws_lambda_function" "success_lambda" {
  function_name    = "success_lambda"
  handler          = "function.handler"
  runtime          = "python3.6"
  filename         = "./function/function.zip"
  source_code_hash = "${base64sha256(file("./function/function.zip"))}"
  role             = "${aws_iam_role.lambda_exec_role.arn}"

  environment {
    variables = {
      AWS_BUCKET = "${var.bucket_name}"
    }
  }
}

// Define bucket
resource "aws_s3_bucket" "bucket" {
  bucket = "${var.bucket_name}"
}

resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.success_lambda.arn}"
  principal     = "s3.amazonaws.com"
  source_arn    = "${aws_s3_bucket.bucket.arn}"
}

// Create bucket challenge
resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = "${aws_s3_bucket.bucket.id}"

  lambda_function {
    lambda_function_arn = "${aws_lambda_function.success_lambda.arn}"
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "status/"
    filter_suffix       = "_SUCCESS"
  }
}
