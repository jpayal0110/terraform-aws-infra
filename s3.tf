resource "random_uuid" "bucket_suffix" {}

resource "aws_s3_bucket" "webapp_bucket" {
  bucket        = "webapp-${random_uuid.bucket_suffix.result}"
  force_destroy = true
}

resource "aws_s3_bucket_ownership_controls" "ownership" {
  bucket = aws_s3_bucket.webapp_bucket.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

# Block all public access to the bucket
resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket = aws_s3_bucket.webapp_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Enable default encryption for security
resource "aws_s3_bucket_server_side_encryption_configuration" "default_encryption" {
  bucket = aws_s3_bucket.webapp_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      #sse_algorithm = "AES256"
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.s3_key.arn
    }
  }
}

# Lifecycle rule to transition objects from STANDARD to STANDARD_IA after 30 days
resource "aws_s3_bucket_lifecycle_configuration" "webapp_bucket_lifecycle" {
  bucket = aws_s3_bucket.webapp_bucket.id

  rule {
    id     = "transition-to-ia"
    status = "Enabled"
    filter {
      prefix = "" # Apply the rule to all objects in the bucket
    }
    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }
  }
}

# Output bucket name
output "s3_bucket_name" {
  value = aws_s3_bucket.webapp_bucket.bucket
}
