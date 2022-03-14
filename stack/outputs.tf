output "content_bucket" {
	value = module.website.content_bucket
	description = "Content bucket name"
}

output "logging_bucket" {
	value = module.website.logging_bucket
	description = "Logging bucket name"
}

output "cf_distribution" {
    value = module.website.cf_distribution
    description = "Cloudfront distribution ID"
}

output "dist_domain_name" {
    value = module.website.dist_domain_name
    description = "Distribution domain name"
}

output "alt_domain_name" {
    value = module.website.alt_domain_name
	description = "Alternative domain name"
}