output "content_bucket" {
	value = aws_s3_bucket.content_bucket.id
	description = "Content bucket name"
}

output "logging_bucket" {
	value = aws_s3_bucket.logging_bucket.id
	description = "Logging bucket name"
}

output "cf_distribution" {
    value = aws_cloudfront_distribution.cf_distro.id
    description = "Cloudfront distribution ID"
}

output "dist_domain_name" {
    value = aws_cloudfront_distribution.cf_distro.domain_name
    description = "Distribution domain name"
}

output "alt_domain_name" {
    value = aws_cloudfront_distribution.cf_distro.aliases
    description = "Alternative domain name"
}