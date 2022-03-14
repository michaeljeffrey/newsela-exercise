output "zone" {
    value = aws_route53_zone.dns_zone.name
	description = "Shared DNS zone name"
}