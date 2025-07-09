# Contact Manager - Full Stack Application

## 🚀 Project Overview

This is a complete full-stack contact management application built with modern technologies and deployed on AWS infrastructure.

### ✅ What's Included

1. **React Frontend** - Modern UI with TypeScript and Tailwind CSS
2. **Python Lambda Backend** - Serverless API with layers architecture
3. **AWS API Gateway** - RESTful API routing
4. **Terraform Infrastructure** - Infrastructure as Code
5. **SAM Testing** - Local development and testing

### 🏗️ Architecture

```
Frontend (React + Vite)
        ↓
API Gateway (AWS)
        ↓
Lambda Functions (Python)
        ↓
Lambda Layer (Business Logic)
```

## 📋 Features Implemented

### Frontend Features
- ✅ Responsive contact list with search
- ✅ Add new contacts with form validation
- ✅ Edit existing contacts
- ✅ Delete contacts with confirmation
- ✅ Modern UI with Tailwind CSS
- ✅ Error handling and loading states
- ✅ TypeScript for type safety

### Backend Features
- ✅ RESTful API with 5 endpoints
- ✅ Lambda layers for code reuse
- ✅ CORS support for frontend
- ✅ Input validation and error handling
- ✅ In-memory data storage (easily replaceable)
- ✅ Structured response format

### Infrastructure Features
- ✅ Terraform for AWS deployment
- ✅ SAM template for local testing
- ✅ API Gateway with proper routing
- ✅ IAM roles and permissions
- ✅ Environment configuration

## 🛠️ Quick Start

### 1. Setup Project
```bash
./dev.sh setup
```

### 2. Start Development Environment
```bash
./dev.sh dev
```

This will start:
- Frontend: http://localhost:5173
- Backend API: http://localhost:3001

### 3. Test API Endpoints
```bash
./test-api.sh
```

### 4. Deploy to AWS
```bash
./dev.sh deploy
```

## 📁 Project Structure

```
contact-manager/
├── frontend/                   # React application
│   ├── src/
│   │   ├── components/        # React components
│   │   │   ├── ContactList.tsx
│   │   │   ├── ContactForm.tsx
│   │   │   └── ContactCard.tsx
│   │   ├── services/          # API service layer
│   │   │   └── contactApi.ts
│   │   └── types/             # TypeScript definitions
│   │       └── contact.ts
│   ├── package.json
│   ├── tailwind.config.js
│   └── .env.local
├── backend/                   # Lambda functions
│   ├── src/
│   │   ├── layers/
│   │   │   └── contact_layer/
│   │   │       └── contact_service.py
│   │   └── lambda_functions/
│   │       ├── list_contacts.py
│   │       ├── get_contact.py
│   │       ├── create_contact.py
│   │       ├── update_contact.py
│   │       └── delete_contact.py
│   ├── template.yaml          # SAM template
│   └── requirements.txt
├── infrastructure/            # Terraform configuration
│   ├── main.tf
│   ├── api_gateway.tf
│   └── README.md
├── dev.sh                     # Development script
├── test-api.sh               # API testing script
└── README.md                 # This file
```

## 🔧 API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/contacts` | List all contacts |
| GET | `/contacts/{id}` | Get specific contact |
| POST | `/contacts` | Create new contact |
| PUT | `/contacts/{id}` | Update contact |
| DELETE | `/contacts/{id}` | Delete contact |

## 🎯 Contact Data Format

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

## 🧪 Testing

### Manual Testing
1. Start the development environment: `./dev.sh dev`
2. Open frontend: http://localhost:5173
3. Test all CRUD operations through the UI

### API Testing
```bash
# Test all endpoints
./test-api.sh

# Or test individually with curl
curl http://localhost:3001/contacts
curl -X POST http://localhost:3001/contacts -H "Content-Type: application/json" -d '{"first_name":"Test","last_name":"User","email":"test@example.com","street_address":"123 Test St","city":"Test City","country":"Test Country"}'
```

## 🚀 Deployment

### Local Development
```bash
./dev.sh dev
```

### AWS Deployment
```bash
./dev.sh deploy
```

### Environment Variables
- Frontend: Set `VITE_API_URL` to your API Gateway URL
- Backend: Uses Lambda environment variables

## 🔄 Development Workflow

1. **Start Development**: `./dev.sh dev`
2. **Make Changes**: Edit frontend/backend code
3. **Test Locally**: Use the web interface or API tests
4. **Deploy**: `./dev.sh deploy`

## 📦 Technologies Used

### Frontend
- React 18 with TypeScript
- Vite for build tooling
- Tailwind CSS for styling
- Axios for API calls
- Lucide React for icons

### Backend
- Python 3.9
- AWS Lambda
- Lambda Layers
- In-memory data storage

### Infrastructure
- AWS API Gateway
- AWS Lambda
- Terraform
- SAM (Serverless Application Model)

## 🎨 UI/UX Features

- Modern, clean design
- Responsive layout
- Form validation
- Loading states
- Error handling
- Search functionality
- Confirmation dialogs

## 🔒 Security Features

- Input validation
- CORS configuration
- IAM roles with minimal permissions
- Error handling without data exposure

## 📈 Future Enhancements

- Database integration (DynamoDB)
- User authentication
- Contact categories/tags
- Import/export functionality
- Advanced search filters
- Pagination for large datasets
- Email/phone validation
- Profile pictures
- Bulk operations

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 License

MIT License - see LICENSE file for details

---

## 💡 Notes

- This project uses in-memory storage for simplicity
- For production, replace with DynamoDB or RDS
- All AWS resources are created in us-east-1 by default
- The frontend is configured for local development
- Update environment variables for production deployment

## 🆘 Troubleshooting

### Common Issues

1. **Frontend not building**: Check Node.js version and npm install
2. **Backend not starting**: Ensure SAM CLI is installed and Docker is running
3. **API calls failing**: Check if backend is running on port 3001
4. **Terraform errors**: Verify AWS credentials and permissions

### Getting Help

- Check the README files in each subdirectory
- Review the development scripts for common commands
- Ensure all prerequisites are installed
- Test with the provided test scripts

---

**Happy coding! 🎉**
