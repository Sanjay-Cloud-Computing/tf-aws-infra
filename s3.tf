resource "random_uuid" "s3_bucket_name" {}

resource "aws_s3_bucket" "file_upload_bucket" {
  bucket = random_uuid.s3_bucket_name.result

  force_destroy = true

  tags = {
    Name        = "FileUploadBucket"
    Environment = "dev"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "file_upload_encryption" {
  bucket = aws_s3_bucket.file_upload_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      # sse_algorithm = "AES256"
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.s3_key.arn
    }
  }
}

resource "aws_s3_bucket_versioning" "file_upload_versioning" {
  bucket = aws_s3_bucket.file_upload_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "file_upload_lifecycle" {
  bucket = aws_s3_bucket.file_upload_bucket.id

  rule {
    id     = "transition-rule"
    status = "Enabled"

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }
  }
}
