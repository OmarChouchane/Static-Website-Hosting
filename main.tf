resource aws_s3_bucket "firstbucket" {
  bucket = var.bucket_name
}

resource "aws_s3_bucket_public_access_block" "block" {
  bucket = aws_s3_bucket.firstbucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_cloudfront_origin_access_control" "oac" {
  name                              = "demo-oac"
  description                       = "Example Policy"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_s3_bucket" "example" {
  bucket = "my-tf-test-bucket"
}

resource "aws_s3_bucket_policy" "allow_cf" {
  bucket = aws_s3_bucket.firstbucket.id
  depends_on = [ aws_s3_bucket_public_access_block.block ]
  policy = jsonencode({
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowCloudFront",
      "Effect": "Allow",
      "Principal": {
        "AWS": "cloudfront.amazonaws.com"
      },
      "Action": [
        "s3:GetObject",
        "s3:ListBucket"
        ],
      "Resource": "${aws_s3_bucket.firstbucket.arn}/*"
      conditions = {
        "StringEquals": {
          "AWS:SourceArn": "aws_cloudfront_distribution.s3_distribution.arn"
        }
      }
    }
  ]
})  
}

resource "aws_s3_object" "object" {
  for_each = fileset("${path.module/www}", "**/*")
  bucket = aws_s3_bucket.firstbucket.id
  key    = each.key
  source = "${path.module/www}/${each.value}"
  etag = filemd5("${path.module/www}/${each.value}")
}