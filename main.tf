# Data Sources

data "aws_caller_identity" "current" {}

data "aws_acm_certificate" "acm" {
  provider    = "aws.us-east-1"
  domain      = "${var.acm_cert_domain}"
  most_recent = true

  statuses = [
    "ISSUED",
  ]
}

data "aws_route53_zone" "zone" {
  name         = "${var.hosted_zone_domain_name}."
  private_zone = false
}

data "aws_iam_policy_document" "s3_policy_document" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.website_bucket.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = ["${aws_cloudfront_origin_access_identity.origin_access_identity.iam_arn}"]
    }
  }

  statement {
    actions   = ["s3:ListBucket"]
    resources = ["${aws_s3_bucket.website_bucket.arn}"]

    principals {
      type        = "AWS"
      identifiers = ["${aws_cloudfront_origin_access_identity.origin_access_identity.iam_arn}"]
    }
  }
}

# Resources

resource "aws_s3_bucket" "website_bucket" {
  bucket        = "${var.app_name}.${var.hosted_zone_domain_name}"
  force_destroy = true

  website {
    index_document = "index.html"

    //error_document = "404.html"
  }

  tags = "${merge("${var.tags}",map("Git", "s3-static-website-hosting"))}"
}

resource "aws_s3_bucket_public_access_block" "example" {
  bucket = "${aws_s3_bucket.website_bucket.id}"

  block_public_acls   = true
  block_public_policy = true
  restrict_public_buckets = true
  ignore_public_acls = true
}

resource "aws_s3_bucket_policy" "s3_policy" {
  bucket = "${aws_s3_bucket.website_bucket.id}"
  policy = "${data.aws_iam_policy_document.s3_policy_document.json}"
}

resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = "Origin access identity for cloudfront distribution"
}

resource "aws_cloudfront_distribution" "website_cdn" {
  enabled      = true
  price_class  = "PriceClass_200"
  http_version = "http1.1"

  "origin" {
    origin_id   = "origin-bucket-${aws_s3_bucket.website_bucket.id}"
    domain_name = "${aws_s3_bucket.website_bucket.bucket_regional_domain_name}"

    s3_origin_config {
      origin_access_identity = "${aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path}"
    }
  }

  default_root_object = "index.html"

  "default_cache_behavior" {
    allowed_methods = [
      "GET",
      "HEAD",
      "DELETE",
      "OPTIONS",
      "PATCH",
      "POST",
      "PUT",
    ]

    cached_methods = [
      "GET",
      "HEAD",
    ]

    "forwarded_values" {
      query_string = "${var.forward-query-string}"

      cookies {
        forward = "none"
      }
    }

    min_ttl          = "0"
    default_ttl      = "300"
    max_ttl          = "1200"
    target_origin_id = "origin-bucket-${aws_s3_bucket.website_bucket.id}"

    // This redirects any HTTP request to HTTPS. Security first!
    viewer_protocol_policy = "redirect-to-https"
    compress               = true
  }
  "restrictions" {
    "geo_restriction" {
      restriction_type = "none"
    }
  }
  "viewer_certificate" {
    acm_certificate_arn      = "${data.aws_acm_certificate.acm.arn}"
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1"
  }
  aliases = [
    "${var.app_name}.${var.hosted_zone_domain_name}",
  ]
  tags = "${merge("${var.tags}",map("Git", "s3-static-website-hosting"))}"
}

resource "aws_route53_record" "cdn-cname" {
  zone_id = "${data.aws_route53_zone.zone.zone_id}"
  name    = "${var.app_name}.${var.hosted_zone_domain_name}"
  type    = "A"

  alias {
    name                   = "${aws_cloudfront_distribution.website_cdn.domain_name}"
    zone_id                = "${aws_cloudfront_distribution.website_cdn.hosted_zone_id}"
    evaluate_target_health = true
  }
}
