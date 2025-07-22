resource "aws_s3_bucket" "portfolio" {
  bucket        = var.s3_bucket_name
  force_destroy = true # Allows the bucket to be deleted even if it contains objects)

  tags = {
    Name        = "Kalpit Swami Portfolio Bucket"
    Environment = "Production"

  }
}


# ────────────────────────────────────────────────
# Enable Static Website Hosting on the bucket
# ────────────────────────────────────────────────

resource "aws_s3_bucket_website_configuration" "portfolio_website" {
  bucket = aws_s3_bucket.portfolio.id

  index_document {
    suffix = "index.html" // The main page of the website
  }

  error_document {
    key = "index.html" // The page shown when an error occurs
  }
}

# ────────────────────────────────────────────────
# Make the bucket content publicly readable (for static hosting)
# ────────────────────────────────────────────────

resource "aws_s3_bucket_public_access_block" "portfolio_public_block" {
  bucket = aws_s3_bucket.portfolio.id

  block_public_acls       = false # Allow public ACLs
  block_public_policy     = false # Allow public policies
  ignore_public_acls      = false # Don't ignore public ACLs
  restrict_public_buckets = false # Don't restrict public buckets
}

resource "aws_s3_bucket_policy" "portfolio_policy" {
  bucket = aws_s3_bucket.portfolio.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "PublicReadGetObject",
        Effect    = "Allow",
        Principal = "*",
        Action    = "s3:GetObject",
        Resource  = "${aws_s3_bucket.portfolio.arn}/*"
      }
    ]
  })
}
