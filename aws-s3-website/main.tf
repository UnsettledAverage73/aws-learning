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

# 1. Zip the Python code automatically
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "hello.py"
  output_path = "lambda_function.zip"
}
# 2. Create the IAM Role (The "ID Card")
resource "aws_iam_role" "iam_for_lambda" {
  name = "learning_lambda_role"

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

# 3. Create the Lambda Function
resource "aws_lambda_function" "test_lambda" {
  # Point to the zip file created above
  filename      = "lambda_function.zip"
  function_name = "my_learning_function"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "hello.lambda_handler" # filename.function_name

  # Tell AWS this zip file changed (so it updates the code)
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  runtime = "python3.9"
}
