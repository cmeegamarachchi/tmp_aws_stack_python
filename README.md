# Contact Manager Full Stack Application

A modern contact management application built with React frontend and Python Lambda backend, deployed on AWS.

## Architecture

- **Frontend**: React with Vite, TypeScript, and Tailwind CSS hosted on S3 with CloudFront CDN
- **Backend**: Python Lambda functions with layers
- **API**: AWS API Gateway
- **Infrastructure**: Terraform for AWS deployment
- **Testing**: AWS SAM for local development

## Features

- ✅ List all contacts
- ✅ View individual contact details
- ✅ Create new contacts
- ✅ Edit existing contacts
- ✅ Delete contacts
- ✅ Search and filter contacts
- ✅ Responsive design
- ✅ Form validation
- ✅ Error handling
- ✅ AWS deployment with CloudFront CDN
- ✅ Automated build and deployment scripts

## Project Structure

```
├── frontend/                 # React application
│   ├── src/
│   │   ├── components/       # React components
│   │   ├── services/         # API service layer
│   │   └── types/           # TypeScript type definitions
│   ├── package.json
│   └── tailwind.config.js
├── backend/                  # Lambda functions and layers
│   ├── src/
│   │   ├── layers/
│   │   │   └── contact_layer/    # Shared business logic
│   │   └── lambda_functions/     # API endpoints
│   ├── template.yaml            # SAM template
│   └── requirements.txt
├── infrastructure/           # Terraform configuration
│   ├── main.tf              # Main infrastructure
│   ├── api_gateway.tf       # API Gateway configuration
│   └── README.md
├── scripts/                  # Deployment scripts
│   ├── deploy.sh            # Main deployment script
│   ├── deploy-frontend.sh   # Frontend-only deployment
│   └── destroy.sh           # Infrastructure cleanup
└── README.md
```

## Quick Start

### Prerequisites

- AWS CLI configured with appropriate credentials
- Terraform >= 1.0
- Node.js >= 18
- Python 3.9
- Docker (for SAM local testing)

### Deploy to AWS

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd contact-manager
   ```

2. **Deploy everything**
   ```bash
   ./scripts/deploy.sh
   ```

3. **Deploy specific components**
   ```bash
   # Infrastructure only
   ./scripts/deploy.sh --infrastructure-only
   
   # Frontend only (requires infrastructure to be deployed first)
   ./scripts/deploy.sh --frontend-only
   ```

4. **Custom environment**
   ```bash
   ./scripts/deploy.sh --environment prod --region us-west-2
   ```

### Local Development

1. **Start the backend locally**
   ```bash
   cd backend
   sam local start-api --port 3001
   ```

2. **Start the frontend locally**
   ```bash
   cd frontend
   npm install
   npm run dev
   ```

3. **Visit** `http://localhost:5173`

### Cleanup

To destroy all AWS resources:
```bash
./scripts/destroy.sh
```

Or with force (skip confirmation):
```bash
./scripts/destroy.sh --force
```

## Contact Data Format

```json
{
  "id": "1",
  "first_name": "John",
  "last_name": "Doe",
  "email": "john.doe@example.com",
  "street_address": "123 Main St",
  "city": "New York",
  "country": "United States"
}
```

## Quick Start

### 1. Frontend Development

```bash
cd frontend
npm install
npm run dev
```

The frontend will run on `http://localhost:5173`

### 2. Backend Testing with SAM

```bash
cd backend
sam build
sam local start-api --port 3001
```

The API will be available at `http://localhost:3001`

### 3. Infrastructure Deployment

```bash
cd infrastructure
terraform init
terraform plan
terraform apply
```

## Development Workflow

1. **Local Development**: Use SAM to run the Lambda functions locally
2. **Frontend Development**: React dev server with hot reload
3. **Testing**: Test API endpoints using SAM local
4. **Deployment**: Deploy to AWS using Terraform

## Environment Variables

### Frontend

The frontend automatically picks up environment variables from:

- `.env.development` - for local development
- `.env.production` - generated automatically during deployment

**Required variables:**
- `VITE_API_BASE_URL` - API Gateway URL (e.g., `https://api123.execute-api.us-east-1.amazonaws.com/dev`)
- `VITE_ENVIRONMENT` - Environment name (dev, staging, prod)

### Backend

Lambda functions use environment variables set by Terraform:
- `PYTHONPATH=/opt/python` - for layer imports

## Deployment Architecture

### AWS Services Used

1. **S3** - Static website hosting for React frontend
2. **CloudFront** - CDN for global content delivery
3. **API Gateway** - REST API for backend endpoints
4. **Lambda** - Serverless functions for business logic
5. **Lambda Layers** - Shared code and dependencies
6. **IAM** - Security roles and policies

### Deployment Process

1. **Infrastructure Deployment** (Terraform)
   - Creates S3 bucket with static website hosting
   - Sets up CloudFront distribution
   - Deploys Lambda functions and layers
   - Configures API Gateway with CORS
   - Sets up IAM roles and policies

2. **Frontend Deployment**
   - Builds React app with Vite
   - Configures API URL from Terraform outputs
   - Uploads to S3 bucket
   - Invalidates CloudFront cache

### Security Features

- S3 bucket with proper public access policies
- CloudFront Origin Access Control (OAC)
- CORS configuration for cross-origin requests
- IAM roles with least privilege access

## API Endpoints

- `GET /contacts` - List all contacts
- `GET /contacts/{id}` - Get a specific contact
- `POST /contacts` - Create a new contact
- `PUT /contacts/{id}` - Update a contact
- `DELETE /contacts/{id}` - Delete a contact

## Technologies Used

### Frontend
- React 18
- TypeScript
- Vite
- Tailwind CSS
- Axios
- Lucide React (icons)

### Backend
- Python 3.9
- AWS Lambda
- Lambda Layers
- API Gateway
- SAM (Serverless Application Model)

### Infrastructure
- Terraform
- AWS CLI
- Docker (for SAM)

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test locally using SAM
5. Submit a pull request

## License

MIT License - see LICENSE file for details

### Jupyter Notebook support
This project has support for Jupyter notebooks. To run a notebook  

Create a notebook file

```bash
touch hello.ipynb
```

Double click on the file or in `Command Pallete` invoke `> Jupyter: Import Jupyter Notebook`
