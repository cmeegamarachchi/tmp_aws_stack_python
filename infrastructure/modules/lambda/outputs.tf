output "contacts_function_name" {
  description = "Name of the contacts Lambda function"
  value       = aws_lambda_function.contacts.function_name
}

output "contacts_function_arn" {
  description = "ARN of the contacts Lambda function"
  value       = aws_lambda_function.contacts.arn
}

output "contacts_invoke_arn" {
  description = "Invoke ARN of the contacts Lambda function"
  value       = aws_lambda_function.contacts.invoke_arn
}

output "countries_function_name" {
  description = "Name of the countries Lambda function"
  value       = aws_lambda_function.countries.function_name
}

output "countries_function_arn" {
  description = "ARN of the countries Lambda function"
  value       = aws_lambda_function.countries.arn
}

output "countries_invoke_arn" {
  description = "Invoke ARN of the countries Lambda function"
  value       = aws_lambda_function.countries.invoke_arn
}
