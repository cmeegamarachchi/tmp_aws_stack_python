output "api_gateway_url" {
  description = "API Gateway endpoint URL"
  value       = module.api_gateway.api_gateway_url
}

output "cloudfront_distribution_domain" {
  description = "CloudFront distribution domain name"
  value       = module.cloudfront.distribution_domain_name
}

output "s3_bucket_name" {
  description = "S3 bucket name for static website"
  value       = module.s3.bucket_name
}

output "website_url" {
  description = "Website URL"
  value       = "https://${module.cloudfront.distribution_domain_name}"
}
