output "api_gateway_url" {
  description = "API Gateway invoke URL"
  value       = "${aws_api_gateway_deployment.main.invoke_url}${var.environment}"
}

output "api_gateway_id" {
  description = "ID of the API Gateway"
  value       = aws_api_gateway_rest_api.main.id
}
