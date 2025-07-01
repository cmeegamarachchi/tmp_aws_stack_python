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

variable "contacts_lambda_zip" {
  description = "Path to contacts lambda zip file"
  type        = string
}

variable "countries_lambda_zip" {
  description = "Path to countries lambda zip file"
  type        = string
}
