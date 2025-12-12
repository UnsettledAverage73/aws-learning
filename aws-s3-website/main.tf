provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "my_bucket" {
  bucket = "learning-bucket-unsettledaverage-2025"

  tags = {
    Name = "My Static Website"
  }
}

# 1. Ownership Controls (Required for public access)
resource "aws_s3_bucket_ownership_controls" "example" {
  bucket = aws_s3_bucket.my_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

# 2. Public Access Block (We must TURN OFF the block to make it public)
resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.my_bucket.id

  block_public_acls       = false
  ignore_public_acls      = false
  block_public_policy     = false
  restrict_public_buckets = false
}

# 3. Bucket ACL (Access Control List)
resource "aws_s3_bucket_acl" "example" {
  depends_on = [
    aws_s3_bucket_ownership_controls.example,
    aws_s3_bucket_public_access_block.example,
  ]

  bucket = aws_s3_bucket.my_bucket.id
  acl    = "public-read"
}

# 4. Upload a file (index.html)
resource "aws_s3_object" "index" {
  bucket       = aws_s3_bucket.my_bucket.id
  key          = "index.html"
  content      = "<h1>Hello from S3 Serverless Hosting!</h1>"
  content_type = "text/html"
  acl          = "public-read"
}

# 5. Configure website hosting
resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.my_bucket.id

  index_document {
    suffix = "index.html"
  }
}

output "website_url" {
  value = aws_s3_bucket_website_configuration.website.website_endpoint
}
