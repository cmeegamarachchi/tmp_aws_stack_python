# Contact Management System

A full-stack web application built with React.js frontend, TypeScript API backend running on AWS Lambda, and Terraform for infrastructure as code.

## 🏗️ Architecture

- **Frontend**: React.js with Vite, hosted on AWS S3 + CloudFront
- **Backend**: TypeScript Lambda functions behind AWS API Gateway
- **Infrastructure**: Terraform with modular configuration
- **Local Development**: Express.js server for API development

## 📁 Project Structure

```
├── api/                    # Backend API (TypeScript + AWS Lambda)
│   ├── src/
│   │   ├── handlers/       # Lambda function handlers
│   │   ├── data.ts         # Mock data
│   │   ├── types.ts        # Type definitions
│   │   └── server.ts       # Local development server
│   ├── package.json
│   └── tsconfig.json
├── app/                    # Frontend React app
│   ├── src/
│   │   ├── components/     # React components
│   │   ├── api.ts          # API client
│   │   ├── types.ts        # Type definitions
│   │   ├── App.tsx
│   │   └── main.tsx
│   ├── package.json
│   └── vite.config.ts
├── infrastructure/         # Terraform configuration
│   ├── modules/            # Terraform modules
│   │   ├── lambda/         # Lambda functions module
│   │   ├── api_gateway/    # API Gateway module
│   │   ├── s3/            # S3 bucket module
│   │   └── cloudfront/    # CloudFront module
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── locals.tf
└── scripts/               # Deployment and development scripts
    ├── setup.sh          # Initial setup
    ├── start-dev.sh      # Start development servers
    ├── deploy.sh         # Deploy to AWS
    └── cleanup.sh        # Clean up resources
```

## 🚀 Quick Start

### Prerequisites

Before getting started, ensure you have the following installed:

- **Node.js** (v16 or higher)
- **npm** (v7 or higher)
- **Terraform** (v1.0 or higher)
- **AWS CLI** (v2.0 or higher)
- **Git**

### 1. Initial Setup

Clone the repository and run the setup script:

```bash
git clone <repository-url>
cd tmp_aws_stack

# Make scripts executable (if not already)
chmod +x scripts/*.sh

# Run initial setup
./scripts/setup.sh
```

This script will:
- Check all prerequisites
- Install dependencies for both API and React app
- Build the API
- Initialize Terraform

### 2. Local Development

To start the development environment with both API and React app:

```bash
./scripts/start-dev.sh
```

This will start:
- API server on `http://localhost:3001`
- React app on `http://localhost:5173`

#### Available API Endpoints (Local Development)

- `GET http://localhost:3001/contacts` - Get all contacts
- `GET http://localhost:3001/countries` - Get all countries
- `GET http://localhost:3001/health` - Health check

#### Manual Development Setup

If you prefer to start services manually:

```bash
# Terminal 1 - Start API server
cd api
npm run dev

# Terminal 2 - Start React app
cd app
npm run dev
```

## 🌩️ AWS Deployment

### Prerequisites for AWS Deployment

1. **Configure AWS CLI**:
   ```bash
   aws configure
   ```
   Enter your AWS Access Key ID, Secret Access Key, default region, and output format.

2. **Verify AWS Configuration**:
   ```bash
   aws sts get-caller-identity
   ```

### Deploy to AWS

To deploy the entire application to AWS:

```bash
./scripts/deploy.sh [environment]
```

Default environment is `dev`. You can specify `staging` or `prod`:

```bash
./scripts/deploy.sh prod
```

#### What the deployment script does:

1. **Builds the API**: Compiles TypeScript and prepares Lambda packages
2. **Deploys Infrastructure**: Uses Terraform to create AWS resources
3. **Builds React App**: Creates production build with correct API endpoints
4. **Uploads to S3**: Syncs the built app to S3 bucket
5. **Invalidates CloudFront**: Ensures users get the latest version

#### Manual Deployment Steps

If you prefer to deploy manually:

```bash
# 1. Build API
cd api
npm run build
cd ..

# 2. Deploy infrastructure
cd infrastructure
terraform init
terraform plan -var="environment=dev"
terraform apply -var="environment=dev"
cd ..

# 3. Get API Gateway URL and build React app
cd app
echo "VITE_API_URL=$(cd ../infrastructure && terraform output -raw api_gateway_url)" > .env.production
npm run build
cd ..

# 4. Upload React app to S3
BUCKET_NAME=$(cd infrastructure && terraform output -raw s3_bucket_name)
aws s3 sync app/dist/ s3://$BUCKET_NAME --delete

# 5. Invalidate CloudFront (optional)
DISTRIBUTION_ID=$(cd infrastructure && terraform output -raw cloudfront_distribution_domain)
aws cloudfront create-invalidation --distribution-id $DISTRIBUTION_ID --paths "/*"
```

## 🔧 Configuration

### Environment Variables

#### Local Development (.env.local)
```bash
VITE_API_URL=http://localhost:3001
```

#### Production (.env.production)
```bash
VITE_API_URL=https://your-api-gateway-url
```

### Terraform Variables

You can customize the deployment by modifying `infrastructure/variables.tf` or passing variables:

```bash
terraform apply \
  -var="environment=prod" \
  -var="aws_region=us-west-2" \
  -var="project_name=my-contacts-app"
```

## 📊 API Documentation

### Contacts Endpoint

**GET** `/contacts`

Returns a list of contacts with the following structure:

```json
{
  "success": true,
  "data": [
    {
      "id": "1",
      "first_name": "John",
      "last_name": "Doe",
      "email": "john.doe@example.com",
      "street_address": "123 Main St",
      "city": "New York",
      "country": "United States"
    }
  ]
}
```

### Countries Endpoint

**GET** `/countries`

Returns a list of countries:

```json
{
  "success": true,
  "data": [
    {
      "id": "1",
      "name": "United States"
    }
  ]
}
```

## 🧹 Cleanup

### Clean up AWS Resources

To destroy all AWS resources:

```bash
./scripts/cleanup.sh [environment] aws
```

### Clean up Local Files

To clean local build artifacts:

```bash
./scripts/cleanup.sh [environment] local
```

### Clean up Everything

To clean both AWS resources and local files:

```bash
./scripts/cleanup.sh [environment] all
```

## 🔍 Troubleshooting

### Common Issues

1. **Port already in use**:
   ```bash
   # Kill processes on specific ports
   pkill -f "node.*3001"  # API port
   pkill -f "node.*5173"  # React app port
   ```

2. **AWS CLI not configured**:
   ```bash
   aws configure
   # Enter your credentials
   ```

3. **Terraform state issues**:
   ```bash
   cd infrastructure
   terraform refresh
   terraform plan
   ```

4. **Build errors**:
   ```bash
   # Clean and reinstall dependencies
   rm -rf api/node_modules api/dist
   rm -rf app/node_modules app/dist
   ./scripts/setup.sh
   ```

### Checking Deployment Status

After deployment, you can check the status:

```bash
cd infrastructure

# Get all outputs
terraform output

# Check specific resources
aws lambda list-functions --query 'Functions[?contains(FunctionName, `contacts-app`)].FunctionName'
aws s3 ls | grep contacts-app
aws cloudfront list-distributions --query 'DistributionList.Items[].DomainName'
```

## 🛠️ Development

### Adding New API Endpoints

1. Create a new handler in `api/src/handlers/`
2. Add the Lambda function to `infrastructure/modules/lambda/main.tf`
3. Add API Gateway integration to `infrastructure/modules/api_gateway/main.tf`
4. Update the API client in `app/src/api.ts`

### Modifying the Frontend

The React app uses:
- **Vite** for build tooling
- **TypeScript** for type safety
- **Axios** for API calls
- **CSS** for styling (modern CSS with flexbox/grid)

### Infrastructure Changes

The Terraform configuration is modular:
- `modules/lambda/` - Lambda functions and IAM roles
- `modules/api_gateway/` - API Gateway configuration
- `modules/s3/` - S3 bucket for static hosting
- `modules/cloudfront/` - CloudFront distribution

## 📋 Scripts Reference

| Script | Purpose | Usage |
|--------|---------|-------|
| `setup.sh` | Initial project setup | `./scripts/setup.sh` |
| `start-dev.sh` | Start development servers | `./scripts/start-dev.sh` |
| `deploy.sh` | Deploy to AWS | `./scripts/deploy.sh [env]` |
| `cleanup.sh` | Clean up resources | `./scripts/cleanup.sh [env] [type]` |

## 🔒 Security Considerations

- API Gateway has CORS configured for development
- Lambda functions have minimal IAM permissions
- S3 bucket is configured for static website hosting only
- CloudFront provides HTTPS termination

## 📝 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test locally
5. Submit a pull request

---

For questions or issues, please open an issue in the repository.