# Contact Manager Full Stack Application

A modern contact management application built with React frontend and Python Lambda backend, deployed on AWS.

## Architecture

- **Frontend**: React with Vite, TypeScript, and Tailwind CSS
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
│   ├── main.tf
│   ├── api_gateway.tf
│   └── README.md
└── README.md
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

### Frontend (.env.local)
```
VITE_API_URL=http://localhost:3001/dev
```

For production, update with your actual API Gateway URL.

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
