############
# Lambda S3
resource "aws_s3_bucket" "lambda_s3_bucket" {
  bucket = var.lambda_s3_bucket_name
}

resource "aws_s3_bucket_acl" "lambda_s3_bucket_acl" {
  bucket = aws_s3_bucket.lambda_s3_bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "lambda_s3_bucket_config_versioning" {
  bucket = aws_s3_bucket.lambda_s3_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "lambda_s3_bucket_config" {
  bucket = aws_s3_bucket.lambda_s3_bucket.id

  rule {
    id     = "lifecycle-1"
    status = "Enabled"

    abort_incomplete_multipart_upload {
      days_after_initiation = 1
    }

    noncurrent_version_expiration {
      noncurrent_days = 3
    }

    expiration {
      expired_object_delete_marker = true
    }
  }
}
# END Lambda S3

##################
# Code Deploy S3
resource "aws_s3_bucket" "codedeploy_s3_bucket" {
  bucket = var.codedeploy_s3_bucket_name
}

resource "aws_s3_bucket_acl" "codedeploy_s3_bucket_acl" {
  bucket = aws_s3_bucket.codedeploy_s3_bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "codedeploy_s3_bucket_versioning" {
  bucket = aws_s3_bucket.codedeploy_s3_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "codedeploy_s3_bucket_config" {
  bucket = aws_s3_bucket.codedeploy_s3_bucket.id

  rule {
    id     = "lifecycle-1"
    status = "Enabled"

    abort_incomplete_multipart_upload {
      days_after_initiation = 1
    }

    noncurrent_version_expiration {
      noncurrent_days = 3
    }

    expiration {
      expired_object_delete_marker = true
    }
  }
}

resource "aws_s3_bucket_notification" "codedeploy_s3_notification" {
  bucket = aws_s3_bucket.codedeploy_s3_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.codedeploy_lambda.arn
    events              = ["s3:ObjectCreated:*"]
    filter_suffix       = ".zip"
  }
}
# END CodeDeploy S3

locals {
  all_buckets = {
    lambda     = aws_s3_bucket.lambda_s3_bucket.id,
    codedeploy = aws_s3_bucket.codedeploy_s3_bucket.id
  }
}

resource "aws_s3_bucket_public_access_block" "s3_bucket_block_public" {
  for_each = { for k, v in local.all_buckets : k => v }

  bucket = each.value

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
