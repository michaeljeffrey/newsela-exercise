locals {
  dash_env = (var.environment == "prod" ? "" : "-${var.environment}")
}

resource "aws_s3_bucket" "content_bucket" {
  bucket = "${var.base_website_name}${local.dash_env}"

  tags = {
    Name        = "${var.base_website_name} ${var.environment} content bucket"
    Environment = var.environment
  }
}

resource "aws_s3_bucket" "logging_bucket" {
  bucket = "${var.base_website_name}${local.dash_env}-logging"

  tags = {
    Name        = "${var.base_website_name} ${var.environment} logging bucket"
    Environment = var.environment
  }
}

// CLOUDFRONT scope requires us-east-1
provider "aws" {
  alias  = "east"
  region = "us-east-1"
}

resource "aws_wafv2_web_acl" "waf" {
  name        = "${var.base_website_name}-${var.environment}"
  description = "${var.base_website_name} ${var.environment}"
  scope       = "CLOUDFRONT"

  provider = aws.east

  default_action {
    allow {}
  }

  rule {
    name     = "AWSManagedRulesCommonRuleSet"
    priority = 1

    override_action {
      count {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"

        excluded_rule {
          name = "SizeRestrictions_QUERYSTRING"
        }

        excluded_rule {
          name = "NoUserAgent_HEADER"
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesCommonRuleSet"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "AWSManagedRulesCommonRuleSet"
    sampled_requests_enabled   = true
  }
}

data "aws_route53_zone" "dns_zone" {
  name = "${var.zone}."
}

resource "aws_route53_record" "cname" {
  zone_id = data.aws_route53_zone.dns_zone.zone_id
  name    = "${var.base_website_name}${local.dash_env}"
  type    = "CNAME"
  ttl     = "300"
  records = [aws_cloudfront_distribution.cf_distro.domain_name]
}

locals {
  s3_origin_id = "${var.base_website_name}-${var.environment}"
}

resource "aws_cloudfront_distribution" "cf_distro" {
  origin {
    domain_name = aws_s3_bucket.content_bucket.bucket_regional_domain_name
    origin_id   = local.s3_origin_id

    /*s3_origin_config {
      origin_access_identity = "origin-access-identity/cloudfront/ABCDEFG1234567"
    }*/
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "${var.base_website_name} ${var.environment}"
  default_root_object = "index.html"

  logging_config {
    bucket = aws_s3_bucket.logging_bucket.bucket_domain_name
  }

  aliases = ["${var.base_website_name}${local.dash_env}.${var.zone}"]

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

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

  # Cache behavior with precedence 0
  ordered_cache_behavior {
    path_pattern     = "/content/immutable/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false
      headers      = ["Origin"]

      cookies {
        forward = "none"
      }
    }

    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }

  ordered_cache_behavior {
    path_pattern     = "/content/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["US", "CA"]
    }
  }

  tags = {
    Environment = var.environment
  }

  viewer_certificate {
    acm_certificate_arn = var.cert_arn
    ssl_support_method  = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  web_acl_id = aws_wafv2_web_acl.waf.arn
}
