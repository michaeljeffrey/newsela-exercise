variable "base_website_name" {
	description = "Base website name; e.g. value of 'mywebsite' will create mywebsite.zone.com (if prod) or mywebsite-[environment].zone.com (if non-prod)"
	type    = string
}

variable "environment" {
	description = "Deployment environment; e.g. 'dev', 'prod', etc."
	type    = string
}

variable "zone" {
	description = "Name of registered DNS domain"
	type    = string
}

variable "cert_arn" {
	description = "ARN of certificate in AWS Certificate Manager -- must be in us-east-1"
	type = string
}