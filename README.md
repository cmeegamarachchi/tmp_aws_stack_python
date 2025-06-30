# AWS Stack - Full Stack Web Application

A complete full-stack web application built with React (Vite), AWS Lambda, API Gateway, and Cognito authentication, deployed using Terraform.

## Architecture

- **Frontend**: React application built with Vite, hosted on S3 with CloudFront CDN
- **Backend**: TypeScript AWS Lambda functions
- **API**: AWS API Gateway with Cognito authentication
- **Authentication**: AWS Cognito User Pools and Identity Pools
- **Infrastructure**: Terraform for Infrastructure as Code
- **Storage**: S3 for frontend hosting

## Project Structure

```
.
├── README.md
├── app/                    # React frontend application
│   ├── src/
│   │   ├── components/
│   │   │   ├── Dashboard.tsx
│   │   │   └── Home.tsx
│   │   ├── App.tsx
│   │   ├── App.css
│   │   ├── main.tsx
│   │   └── index.css
│   ├── package.json
│   ├── vite.config.ts
│   ├── tsconfig.json
│   ├── index.html
│   └── .env.example
├── api/                    # AWS Lambda backend
│   ├── src/
│   │   ├── utils/
│   │   │   └── auth.ts
│   │   └── index.ts
│   ├── package.json
│   └── tsconfig.json
└── scripts/                # Deployment and infrastructure scripts
    ├── terraform/
    │   ├── main.tf
    │   ├── cognito.tf
    │   ├── lambda.tf
    │   ├── api-gateway.tf
    │   ├── s3-cloudfront.tf
    │   └── outputs.tf
    ├── setup.sh
    ├── deploy.sh
    └── destroy.sh
```

## Features

- 🔐 **Pure AWS Authentication**: Native Cognito OAuth flow without Amplify
- 🚀 **Serverless Backend**: AWS Lambda functions with TypeScript
- 🌐 **API Gateway**: RESTful API with Cognito authorization at gateway level
- ⚛️ **Modern Frontend**: React with Vite, no heavy dependencies
- 🏗️ **Infrastructure as Code**: Terraform for reproducible deployments
- 📦 **Automated Deployment**: Scripts for easy setup and deployment
- 🔒 **Zero Manual Auth Code**: All authentication handled by AWS services
- 📊 **CloudWatch Logging**: Centralized logging for debugging

## Prerequisites

Before setting up this project, ensure you have the following installed:

1. **Node.js** (v18 or later)
   ```bash
   node --version
   npm --version
   ```

2. **AWS CLI** configured with appropriate credentials
   ```bash
   aws --version
   aws configure list
   ```

3. **Terraform** (v1.0 or later)
   ```bash
   terraform --version
   ```

4. **Git** (for cloning the repository)
   ```bash
   git --version
   ```

## Quick Start

### 1. Clone and Setup

```bash
# Clone the repository
git clone <repository-url>
cd aws-stack

# Run the setup script
./scripts/setup.sh
```

### 2. Configure AWS Credentials

Ensure your AWS credentials are configured:

```bash
aws configure
```

You'll need:
- AWS Access Key ID
- AWS Secret Access Key
- Default region (e.g., us-east-1)
- Default output format (json)

### 3. Deploy the Application

```bash
# Deploy everything (infrastructure + applications)
./scripts/deploy.sh
```

This script will:
- Build the Lambda function
- Deploy AWS infrastructure with Terraform
- Build the React frontend
- Deploy frontend to S3
- Configure CloudFront
- Set up all necessary environment variables

### 4. Access Your Application

After successful deployment, you'll see output similar to:

```
Access your application at: https://d1234567890.cloudfront.net
API Gateway URL: https://abcdef123.execute-api.us-east-1.amazonaws.com/dev
User Pool ID: us-east-1_Abc123DEf
User Pool Client ID: 1abc23defg4hij567klm
```

## Manual Setup (Alternative)

If you prefer to set up components individually:

### Frontend Development

```bash
cd app

# Install dependencies
npm install

# Start development server
npm run dev

# Build for production
npm run build
```

### Backend Development

```bash
cd api

# Install dependencies
npm install

# Build TypeScript
npm run build

# Package for Lambda deployment
npm run package
```

### Infrastructure Deployment

```bash
cd scripts/terraform

# Initialize Terraform
terraform init

# Plan deployment
terraform plan

# Apply infrastructure
terraform apply
```

## Environment Variables

The frontend requires these environment variables (automatically configured during deployment):

```env
VITE_USER_POOL_ID=your_user_pool_id
VITE_USER_POOL_CLIENT_ID=your_user_pool_client_id
VITE_OAUTH_DOMAIN=your_cognito_domain.auth.us-east-1.amazoncognito.com
VITE_API_GATEWAY_URL=your_api_gateway_url
```

## API Endpoints

The backend provides these protected endpoints (all automatically authenticated by API Gateway):

- `GET /hello` - Returns a simple hello message with authenticated user info
- `GET /protected` - Returns protected data with full JWT claims
- `GET /user/profile` - Returns detailed user profile information

**No authentication headers required in Lambda!** API Gateway handles all authentication and passes user context automatically.

## Authentication Flow

1. **Unauthenticated Request**: When a user makes a request to API Gateway without a valid token
2. **Gateway-Level Rejection**: API Gateway immediately returns a 401 with authentication URL
3. **Cognito Hosted UI**: User is redirected to Cognito's hosted authentication page
4. **Token Generation**: After successful authentication, Cognito generates JWT tokens
5. **Authenticated Requests**: Frontend includes JWT tokens in API requests
6. **Gateway Validation**: API Gateway validates tokens against Cognito User Pool automatically
7. **Lambda Execution**: Only authenticated requests reach Lambda with user context included

### Key Benefits:
- **Zero manual token validation** in your Lambda code
- **Automatic user context** passed to Lambda
- **Centralized authentication** at the gateway level
- **Production-ready security** with AWS-managed validation

## Development

### Local Development

For local development, you can run the frontend and mock the backend:

```bash
# Start frontend development server
cd app
npm run dev
```

The frontend will be available at `http://localhost:3000`.

### Testing

```bash
# Test Lambda function
cd api
npm test

# Test frontend
cd app
npm test
```

## Customization

### Adding New API Endpoints

1. Add new route handling in `api/src/index.ts`
2. Update API Gateway configuration if needed
3. Redeploy with `./scripts/deploy.sh`

### Frontend Components

Add new React components in `app/src/components/` and import them in your routes.

### Terraform Configuration

Modify Terraform files in `scripts/terraform/` to customize AWS resources:
- `main.tf` - Provider and variables
- `cognito.tf` - Authentication configuration
- `lambda.tf` - Lambda function settings
- `api-gateway.tf` - API configuration
- `s3-cloudfront.tf` - Frontend hosting

## Troubleshooting

### Common Issues

1. **AWS Credentials Not Configured**
   ```bash
   aws configure
   ```

2. **Terraform State Issues**
   ```bash
   cd scripts/terraform
   terraform refresh
   ```

3. **Lambda Deployment Package Missing**
   ```bash
   cd api
   npm run package
   ```

4. **CORS Issues**
   - Check API Gateway CORS configuration
   - Ensure proper headers in Lambda responses

5. **Authentication Issues**
   - Verify Cognito User Pool configuration
   - Check JWT token format and expiration

### Logs and Debugging

- **Lambda Logs**: Check CloudWatch Logs for the Lambda function
- **API Gateway Logs**: Enable logging in API Gateway stage settings
- **Frontend**: Use browser developer tools for client-side debugging

## Cleanup

To destroy all AWS resources and avoid charges:

```bash
./scripts/destroy.sh
```

⚠️ **Warning**: This will permanently delete all data and resources!

## Security Considerations

- All API endpoints are protected by Cognito authentication
- HTTPS is enforced via CloudFront
- S3 bucket policies restrict access appropriately
- IAM roles follow the principle of least privilege
- JWT tokens have configurable expiration times

## Cost Optimization

This architecture uses several AWS free tier eligible services:
- Lambda (1M requests/month free)
- API Gateway (1M requests/month free)
- S3 (5GB storage free)
- CloudFront (1TB transfer/month free)
- Cognito (50,000 MAUs free)

Monitor your usage in the AWS Billing Console.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is licensed under the MIT License. See the LICENSE file for details.

## Support

For issues and questions:
1. Check the troubleshooting section
2. Review AWS CloudWatch logs
3. Open an issue in the repository
4. Consult AWS documentation for service-specific issues
