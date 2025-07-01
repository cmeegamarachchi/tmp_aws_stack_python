variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
}

variable "contacts_lambda_invoke_arn" {
  description = "Invoke ARN of the contacts Lambda function"
  type        = string
}

variable "countries_lambda_invoke_arn" {
  description = "Invoke ARN of the countries Lambda function"
  type        = string
}

variable "contacts_lambda_function_name" {
  description = "Name of the contacts Lambda function"
  type        = string
}

variable "countries_lambda_function_name" {
  description = "Name of the countries Lambda function"
  type        = string
}
