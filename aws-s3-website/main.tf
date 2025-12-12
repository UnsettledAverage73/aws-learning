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
  content      = <<EOF
<!DOCTYPE html>
<html>
<head>
    <title>Serverless Demo</title>
    <style>body { font-family: sans-serif; text-align: center; margin-top: 50px; }</style>
</head>
<body>
    <h1>My Cloud Resume</h1>
    <button onclick="callLambda()">Call Backend</button>
    <p id="result">Waiting...</p>

    <script>
        async function callLambda() {
            // Terraform automatically pastes the URL here:
            const apiUrl = "${aws_lambda_function_url.test_live.function_url}";
            
            document.getElementById("result").innerText = "Calling...";
            try {
                const response = await fetch(apiUrl);
                const data = await response.json();
                // Lambda returns a string body, so we display that
                document.getElementById("result").innerText = data.body; 
            } catch (error) {
                document.getElementById("result").innerText = "Error: " + error;
            }
        }
    </script>
</body>
</html>
EOF
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

# ADD THIS (Find the role the teachers made for you)
data "aws_iam_role" "lab_role" {
  name = "LabRole"
}

# 3. Create the Lambda Function
resource "aws_lambda_function" "test_lambda" {
  # Point to the zip file created above
  filename      = "lambda_function.zip"
  function_name = "my_learning_function"
  role          = "arn:aws:iam::637423406602:role/LabRole"
  handler       = "hello.lambda_handler" # filename.function_name

  # Tell AWS this zip file changed (so it updates the code)
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  runtime = "python3.9"
}

# 1. Create the Function URL
resource "aws_lambda_function_url" "test_live" {
  function_name      = aws_lambda_function.test_lambda.function_name
  authorization_type = "NONE" # Publicly accessible

  cors {
    allow_credentials = true
    allow_origins     = ["*"] # Allow any website to call this (for learning)
    allow_methods     = ["*"]
  }
}

# 2. Output the URL so we can see it
output "api_url" {
  value = aws_lambda_function_url.test_live.function_url
}
