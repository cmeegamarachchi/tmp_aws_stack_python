# Use a base image with common tools installed
FROM mcr.microsoft.com/vscode/devcontainers/base:ubuntu-22.04

# Install Python
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    python3-dev \
    python3-venv \
    build-essential && \
    pip3 install --upgrade pip && \
    pip3 install ipykernel jupyter && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Set the default shell
CMD [ "bash" ]
