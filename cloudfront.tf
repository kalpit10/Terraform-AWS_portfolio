# In CloudFront, Origin Access Control (OAC) is a newer and more secure way to allow CloudFront to access your S3 bucket (instead of the older OAI method). This ensures:

# Your S3 bucket stays private (not publicly accessible)

# Only CloudFront can read from it

# We'll start by creating this piece before the actual distribution.


resource "aws_cloudfront_origin_access_control" "oac" {
  name                              = "react-site-oac"
  description                       = "Access control for S3 bucket"
  origin_access_control_origin_type = "s3"     # We're connecting to an S3 origin
  signing_behavior                  = "always" # CloudFront will always sign the requests
  signing_protocol                  = "sigv4"  # This is AWS's secure signature method
}


resource "aws_cloudfront_distribution" "cdn" {
  enabled             = true         # Enable the distribution
  default_root_object = "index.html" # Load index.html when opening the site

  origin {
    domain_name = "${var.s3_bucket_name}.s3.amazonaws.com" # S3 bucket public domain
    origin_id   = "S3-${var.s3_bucket_name}"               # A unique ID for cloudfront to identify the origin

    #Attach the CloudFront Origin Access Control (OAC)
    origin_access_control_id = aws_cloudfront_origin_access_control.oac.id
  }

  // Defines how CloudFront should behave (allowing GET/HEAD, enabling HTTPS redirect)
  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]            # Only allow read operations (safe for static sites)
    cached_methods   = ["GET", "HEAD"]            # Cache these methods for better performance
    target_origin_id = "S3-${var.s3_bucket_name}" # Link to the S3 origin we defined above

    viewer_protocol_policy = "redirect-to-https" # Redirect HTTP requests to HTTPS for security

    forwarded_values {
      query_string = false # Don't forward query strings to the origin
      cookies {
        forward = "none" # Don't forward cookies to the origin
      }
    }

  }


  aliases = ["www.kalpitswami.com"]

  price_class = "PriceClass_100" # Use the cheapest price class for lower costs in North America and Europe (Within Free Tier limits)

  restrictions {
    geo_restriction {
      restriction_type = "none" # No geographic restrictions, allow users from all countries
    }
  }


  viewer_certificate {
    acm_certificate_arn      = "arn:aws:acm:us-east-1:395136123952:certificate/344098d3-f093-4f74-821d-edcff166d591"
    ssl_support_method       = "sni-only"     # Use SNI for SSL/TLS (most browsers support this)
    minimum_protocol_version = "TLSv1.2_2021" # Use a secure TLS version
    # cloudfront_default_certificate = true           # Use default CloudFront SSL certificate (for now)
  }

  tags = {
    Name = "react-portfolio-cdn" # Name tag for the distribution
  }
}


