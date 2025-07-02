# Quick Start Guide

## � Prerequisites

Before starting, ensterraform --version # Should show: Terraform v1.12.2
```

> **💡 Alternative**: If you're using VS Code, you can skip manual installation by using the included dev container which has all prerequisites pre-installed with the correct versions.

## 🚀 Getting Startedyou have the following tools installed with the correct versions (matching the dev container):

### Required Versions
- **Node.js**: v22.17.0
- **AWS CLI**: v2.27.46  
- **Terraform**: v1.12.2

### Quick Installation Commands

**macOS (using Homebrew):**
```bash
# Install Node.js
brew install nvm
nvm install 22.17.0 && nvm use 22.17.0 && nvm alias default 22.17.0

# Install AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-macos-2.27.46.pkg" -o "AWSCLIV2.pkg"
sudo installer -pkg AWSCLIV2.pkg -target /

# Install Terraform
brew install tfenv
tfenv install 1.12.2 && tfenv use 1.12.2
```

**Linux (Ubuntu/Debian):**
```bash
# Install Node.js
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
source ~/.bashrc
nvm install 22.17.0 && nvm use 22.17.0 && nvm alias default 22.17.0

# Install AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64-2.27.46.zip" -o "awscliv2.zip"
unzip awscliv2.zip && sudo ./aws/install && rm -rf awscliv2.zip aws

# Install Terraform
wget https://releases.hashicorp.com/terraform/1.12.2/terraform_1.12.2_linux_amd64.zip
unzip terraform_1.12.2_linux_amd64.zip
sudo mv terraform /usr/local/bin/ && rm terraform_1.12.2_linux_amd64.zip
```

**Windows (PowerShell as Administrator):**
```powershell
# Install Node.js (download from https://nodejs.org/ or use chocolatey)
choco install nodejs --version=22.17.0

# Install AWS CLI (download MSI or use chocolatey)
choco install awscli --version=2.27.46

# Install Terraform (download ZIP or use chocolatey)
choco install terraform --version=1.12.2
```

### Verify Installation
```bash
node --version      # Should show: v22.17.0
aws --version       # Should show: aws-cli/2.27.46
terraform --version # Should show: Terraform v1.12.2
```

## �🚀 Getting Started

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
