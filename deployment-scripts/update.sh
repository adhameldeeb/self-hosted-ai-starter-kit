#!/bin/bash

# Update script for n8n stack on DigitalOcean
# This script updates the n8n stack with the latest images

# Load configuration
source $(dirname "$0")/config.env

# Check if running as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root"
    exit 1
fi

DEPLOY_DIR="/root/self-hosted-ai-starter-kit"

# Check if deployment directory exists
if [ ! -d "$DEPLOY_DIR" ]; then
    echo "Deployment directory not found. Please run deploy.sh first."
    exit 1
fi

echo "=== Starting n8n update process ==="

# Navigate to deployment directory
cd $DEPLOY_DIR

# Pull the latest repository changes
echo "=== Updating repository ==="
git pull

# Pull the latest Docker images
echo "=== Pulling latest Docker images ==="
docker compose pull

# Restart the containers
echo "=== Restarting containers ==="
if [ "$USE_CPU_PROFILE" = true ]; then
    echo "Using CPU profile (no GPU acceleration)"
    docker compose --profile cpu down
    docker compose --profile cpu up -d
else
    echo "Using GPU profile (with GPU acceleration if available)"
    docker compose --profile gpu-nvidia down
    docker compose --profile gpu-nvidia up -d
fi

# Check if containers are running
echo "=== Checking container status ==="
sleep 5
docker ps

# Check if n8n is responding
echo "=== Checking if n8n is responding ==="
curl -s -o /dev/null -w "%{http_code}" http://localhost:5678/healthz
if [ $? -eq 0 ]; then
    echo "n8n is responding"
else
    echo "n8n is not responding, check the logs with: docker logs n8n"
fi

echo "=== Update completed ==="
echo "n8n is now accessible at: http://$DROPLET_IP:5678"
echo "Qdrant is accessible at: http://$DROPLET_IP:6333"
