# Contact Manager Infrastructure

This directory contains Terraform configuration for deploying the Contact Manager API to AWS.

## Architecture

The infrastructure includes:
- Lambda functions for API endpoints
- Lambda layer for shared business logic
- API Gateway for HTTP routing
- IAM roles and policies

## Deployment

### Prerequisites
- AWS CLI configured with appropriate permissions
- Terraform installed

### Commands

1. **Initialize Terraform:**
   ```bash
   terraform init
   ```

2. **Plan deployment:**
   ```bash
   terraform plan
   ```

3. **Deploy infrastructure:**
   ```bash
   terraform apply
   ```

4. **Get outputs:**
   ```bash
   terraform output
   ```

5. **Destroy infrastructure:**
   ```bash
   terraform destroy
   ```

## Configuration

### Variables
- `aws_region`: AWS region for deployment (default: us-east-1)
- `environment`: Environment name (default: dev)
- `project_name`: Project name prefix (default: contact-manager)

### Outputs
- `api_gateway_url`: URL of the deployed API Gateway
- `api_gateway_id`: ID of the API Gateway

## Files

- `main.tf`: Main Terraform configuration with Lambda functions and layer
- `api_gateway.tf`: API Gateway configuration with methods and integrations

## Security

The Lambda functions use a minimal IAM role with only the necessary permissions for basic execution and logging.

## Customization

To modify the infrastructure:
1. Update variables in `main.tf` or create a `terraform.tfvars` file
2. Modify resources as needed
3. Run `terraform plan` to review changes
4. Apply with `terraform apply`
