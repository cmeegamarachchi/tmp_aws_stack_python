# Quick Start Guide

## 🚀 Getting Started

1. **Setup the project**:
   ```bash
   ./scripts/setup.sh
   ```

2. **Start local development**:
   ```bash
   ./scripts/start-dev.sh
   ```
   - API: http://localhost:3001
   - App: http://localhost:5173

3. **Deploy to AWS**:
   ```bash
   # Configure AWS CLI first
   aws configure
   
   # Deploy
   ./scripts/deploy.sh
   ```

## 📋 Available Commands

| Command | Description |
|---------|-------------|
| `npm run setup` | Initial project setup |
| `npm run dev` | Start development servers |
| `npm run deploy` | Deploy to AWS (dev) |
| `npm run deploy:prod` | Deploy to AWS (prod) |
| `npm run cleanup` | Clean up everything |
| `npm run cleanup:local` | Clean local files only |
| `npm run cleanup:aws` | Clean AWS resources only |

## 🔗 Endpoints

### Local Development
- **Health**: http://localhost:3001/health
- **Contacts**: http://localhost:3001/contacts
- **Countries**: http://localhost:3001/countries

### Production
After deployment, check the output for your API Gateway URL and website URL.

## 🛠️ Development

- **API**: TypeScript + Express (local) / Lambda (AWS)
- **Frontend**: React + Vite + TypeScript
- **Infrastructure**: Terraform (modular)
- **Deployment**: Bash scripts

## 📂 Key Files

- `api/src/server.ts` - Local development API server
- `api/src/handlers/` - Lambda function handlers
- `app/src/App.tsx` - Main React component
- `infrastructure/main.tf` - Main Terraform configuration
- `scripts/` - Deployment and development scripts

For detailed documentation, see README.md
