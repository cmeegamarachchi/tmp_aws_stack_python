# AppSolve application blocks AWS starter kit

AppSolve application blocks AWS starter kit is a web full stack reference starter kit based on ReactJS, AWS serverless architecture and Infrastructure as Code

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

### 1. Prerequisites Installation

Before starting, ensure you have the following tools installed with the correct versions:

#### Node.js (v22.17.0)

**macOS (using Homebrew):**
```bash
# Install Node Version Manager (nvm)
brew install nvm

# Install and use specific Node.js version
nvm install 22.17.0
nvm use 22.17.0
nvm alias default 22.17.0
```

**Linux (Ubuntu/Debian):**
```bash
# Install Node Version Manager (nvm)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash

# Reload your shell
source ~/.bashrc

# Install and use specific Node.js version
nvm install 22.17.0
nvm use 22.17.0
nvm alias default 22.17.0
```

**Windows:**
```powershell
# Download and install Node.js v22.17.0 from https://nodejs.org/
# Or use chocolatey:
choco install nodejs --version=22.17.0
```

#### AWS CLI (v2.27.46)

**macOS:**
```bash
# Download and install specific version
curl "https://awscli.amazonaws.com/awscli-exe-macos-2.27.46.pkg" -o "AWSCLIV2.pkg"
sudo installer -pkg AWSCLIV2.pkg -target /
```

**Linux:**
```bash
# Download and install specific version
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64-2.27.46.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
rm -rf awscliv2.zip aws
```

**Windows:**
```powershell
# Download and install from https://awscli.amazonaws.com/AWSCLIV2-2.27.46.msi
# Or use chocolatey:
choco install awscli --version=2.27.46
```

#### Terraform (v1.12.2)

**macOS (using Homebrew):**
```bash
# Install tfenv (Terraform version manager)
brew install tfenv

# Install and use specific Terraform version
tfenv install 1.12.2
tfenv use 1.12.2
```

**Linux:**
```bash
# Download and install specific version
wget https://releases.hashicorp.com/terraform/1.12.2/terraform_1.12.2_linux_amd64.zip
unzip terraform_1.12.2_linux_amd64.zip
sudo mv terraform /usr/local/bin/
rm terraform_1.12.2_linux_amd64.zip
```

**Windows:**
```powershell
# Download from https://releases.hashicorp.com/terraform/1.12.2/terraform_1.12.2_windows_amd64.zip
# Extract and add to PATH
# Or use chocolatey:
choco install terraform --version=1.12.2
```

#### Verify Installation

After installing all prerequisites, verify the versions:

```bash
node --version    # Should output: v22.17.0
npm --version     # Should output: 10.x.x (comes with Node.js)
aws --version     # Should output: aws-cli/2.27.46 ...
terraform --version  # Should output: Terraform v1.12.2
```

> **💡 Alternative**: If you're using VS Code, you can skip manual installation by using the included dev container (`.devcontainer/`) which has all prerequisites pre-installed with the correct versions.

### 2. Initial Setup

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

### 3. Local Development

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

# Note: The React app is now automatically built and deployed by Terraform!
# It will:
# - Build the React app with the correct API Gateway URL
# - Upload it to S3
# - Invalidate CloudFront cache
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
   aws configure sso --use-device-code
   # Enter your credentials
   ```

3. **Terraform state issues**:
   ```bash
   cd infrastructure
   terraform refresh
   terraform plan
   ```

4. **S3 bucket not empty error during destroy**:
   If you get a "BucketNotEmpty" error when running `terraform destroy`, manually empty the S3 bucket first:
   ```bash
   # Get the bucket name from terraform output
   cd infrastructure
   terraform output s3_bucket_name
   
   # Empty the bucket (replace with actual bucket name)
   aws s3 rm s3://your-bucket-name --recursive
   
   # Then retry destroy
   terraform destroy
   ```

5. **Build errors**:
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