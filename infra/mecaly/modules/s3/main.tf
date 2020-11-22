resource "aws_s3_bucket" "frontend" {
  bucket = var.frontend_bucket_name
  acl    = "private"
  
 versioning {
    enabled = true
  }
}

resource "aws_s3_bucket" "data" {
  bucket = var.data_bucket_name
  acl    = "private"
 
 versioning {
    enabled = true
  }
}

resource "aws_cloudfront_distribution" "s3_frontend_distribution" {
  origin {
    domain_name = aws_s3_bucket.frontend.bucket_regional_domain_name
    origin_id   = "s3_frontend_origin"
    

  }
  enabled             = true
  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "s3_frontend_origin"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }
   restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["US", "CA", "GB", "DE","IN"]
    }
  }
  viewer_certificate {
    cloudfront_default_certificate = true
  }

}

resource "aws_cloudfront_distribution" "s3_dataend_distribution" {
  origin {
    domain_name = aws_s3_bucket.data.bucket_regional_domain_name
    origin_id   = "s3_data_origin"
    

  }
  enabled             = true
   default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "s3_data_origin"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }
   restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["US", "CA", "GB", "DE","IN"]
    }
  }
  viewer_certificate {
    cloudfront_default_certificate = true
  }

}

resource "aws_s3_bucket_policy" "frontend-policy" {
  bucket = aws_s3_bucket.frontend.id

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "MYBUCKETPOLICY",
  "Statement": [
    {
      "Sid": "Stmt1603812426751",
      "Action": "s3:*",
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::${var.frontend_bucket_name}/*",
      "Principal": "*"
    }
  ]
}
POLICY
}

resource "aws_s3_bucket_policy" "dataend-policy" {
  bucket = aws_s3_bucket.data.id

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "MYBUCKETPOLICY",
  "Statement": [
    {
      "Sid": "Stmt1603812426751",
      "Action": "s3:*",
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::${var.data_bucket_name}",
      "Principal": "*"
    }
  ]
}
POLICY
}