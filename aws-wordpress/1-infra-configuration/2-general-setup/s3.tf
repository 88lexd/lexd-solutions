resource "aws_s3_bucket" "lambda_s3_bucket" {
  bucket = var.lambda_s3_bucket_name
  acl    = "private"
}

resource "aws_s3_bucket_public_access_block" "lambda_s3_bucket_block_public" {
  bucket = aws_s3_bucket.lambda_s3_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
