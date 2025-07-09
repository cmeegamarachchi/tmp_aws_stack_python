# Use a base image with common tools installed
FROM mcr.microsoft.com/vscode/devcontainers/base:ubuntu-22.04

# Define versions for version locking
ARG NODE_VERSION=22.17.0
ARG AWS_CLI_VERSION=2.27.46
ARG TERRAFORM_VERSION=1.12.2
ARG SAM_CLI_VERSION=1.142.1

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    unzip \
    git \
    python3 \
    python3-pip \
    python3-dev \
    python3-venv \
    build-essential && \
    pip3 install --upgrade pip && \
    pip3 install ipykernel jupyter && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Node.js (version locked)
RUN curl -fsSL https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-x64.tar.xz -o node.tar.xz \
    && tar -xJf node.tar.xz -C /usr/local --strip-components=1 \
    && rm node.tar.xz \
    && node --version \
    && npm --version

# Install AWS CLI v2 (version locked)
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64-${AWS_CLI_VERSION}.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \
    && ./aws/install \
    && rm -rf awscliv2.zip aws \
    && aws --version

# Install AWS SAM CLI (version locked)
RUN wget https://github.com/aws/aws-sam-cli/releases/download/v${SAM_CLI_VERSION}/aws-sam-cli-linux-x86_64.zip \
    && unzip aws-sam-cli-linux-x86_64.zip -d sam-installation \
    && ./sam-installation/install \
    && rm -rf aws-sam-cli-linux-x86_64.zip sam-installation \
    && sam --version

# Install Terraform (version locked)
RUN wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
    && unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
    && mv terraform /usr/local/bin/ \
    && rm terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
    && terraform --version

RUN echo "vscode ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/99-vscode \
    && chmod 0440 /etc/sudoers.d/99-vscode    

# Set the default shell
CMD [ "bash" ]    