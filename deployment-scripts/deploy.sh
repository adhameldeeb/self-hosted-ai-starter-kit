#!/bin/bash

# Deployment script for n8n stack on DigitalOcean
# This script deploys the n8n stack using Docker Compose

# Load configuration
source $(dirname "$0")/config.env

# Check if running as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root"
    exit 1
fi

echo "=== Starting n8n deployment ==="

# Create main directory if it doesn't exist
DEPLOY_DIR="/root/self-hosted-ai-starter-kit"
if [ ! -d "$DEPLOY_DIR" ]; then
    echo "=== Creating deployment directory ==="
    mkdir -p $DEPLOY_DIR
fi

# Clone repository if needed
if [ ! -f "$DEPLOY_DIR/docker-compose.yml" ]; then
    echo "=== Cloning self-hosted-ai-starter-kit repository ==="
    cd /root
    git clone https://github.com/n8n-io/self-hosted-ai-starter-kit.git
    cd self-hosted-ai-starter-kit
else
    echo "=== Repository already exists, updating ==="
    cd $DEPLOY_DIR
    git pull
fi

# Create shared directory if it doesn't exist
if [ ! -d "$DEPLOY_DIR/shared" ]; then
    echo "=== Creating shared directory ==="
    mkdir -p $DEPLOY_DIR/shared
    chmod 777 $DEPLOY_DIR/shared
fi

# Create custom-code directory if it doesn't exist
if [ ! -d "$DEPLOY_DIR/custom-code" ]; then
    echo "=== Creating custom code directory ==="
    mkdir -p $DEPLOY_DIR/custom-code
fi

# Create custom-workflows directory if it doesn't exist
if [ ! -d "$DEPLOY_DIR/n8n/custom-workflows" ]; then
    echo "=== Creating custom workflows directory ==="
    mkdir -p $DEPLOY_DIR/n8n/custom-workflows
fi

# Create the .env file
echo "=== Creating .env file ==="
cat > $DEPLOY_DIR/.env << EOL
POSTGRES_USER=$POSTGRES_USER
POSTGRES_PASSWORD=$POSTGRES_PASSWORD
POSTGRES_DB=$POSTGRES_DB

N8N_ENCRYPTION_KEY=$N8N_ENCRYPTION_KEY
N8N_USER_MANAGEMENT_JWT_SECRET=$N8N_USER_MANAGEMENT_JWT_SECRET
N8N_DEFAULT_BINARY_DATA_MODE=$N8N_DEFAULT_BINARY_DATA_MODE

# LLM API Keys
OPENAI_API_KEY=$OPENAI_API_KEY
EOL

# Add any additional API keys from config.env
if [ ! -z "$ANTHROPIC_API_KEY" ]; then
    echo "ANTHROPIC_API_KEY=$ANTHROPIC_API_KEY" >> $DEPLOY_DIR/.env
fi

if [ ! -z "$MISTRAL_API_KEY" ]; then
    echo "MISTRAL_API_KEY=$MISTRAL_API_KEY" >> $DEPLOY_DIR/.env
fi

# Copy any custom code if it exists
if [ -d "$(dirname "$0")/custom-code" ] && [ "$(ls -A $(dirname "$0")/custom-code)" ]; then
    echo "=== Copying custom code ==="
    cp -r $(dirname "$0")/custom-code/* $DEPLOY_DIR/custom-code/
fi

# Copy any custom workflows if they exist
if [ -d "$(dirname "$0")/custom-workflows" ] && [ "$(ls -A $(dirname "$0")/custom-workflows)" ]; then
    echo "=== Copying custom workflows ==="
    cp -r $(dirname "$0")/custom-workflows/* $DEPLOY_DIR/n8n/custom-workflows/
fi

# Start the containers
echo "=== Starting Docker containers ==="
cd $DEPLOY_DIR

if [ "$USE_CPU_PROFILE" = true ]; then
    echo "Using CPU profile (no GPU acceleration)"
    docker compose --profile cpu up -d
else
    echo "Using GPU profile (with GPU acceleration if available)"
    docker compose --profile gpu-nvidia up -d
fi

# Check if containers are running
echo "=== Checking container status ==="
sleep 5
docker ps

echo "=== Deployment completed ==="
echo "n8n is now accessible at: http://$DROPLET_IP:5678"
echo "Qdrant is accessible at: http://$DROPLET_IP:6333"
echo ""
echo "First time setup:"
echo "1. Open http://$DROPLET_IP:5678 in your browser"
echo "2. Complete the initial n8n setup"
echo "3. Navigate to Settings → Credentials to add your API credentials"
