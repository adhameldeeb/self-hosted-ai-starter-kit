#!/bin/bash

# Script to start the n8n server stack using Docker Compose
# This script should be run on the DigitalOcean droplet

echo "=== Starting n8n Server Stack ==="

# Check if running as root or with sudo
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root or with sudo"
    exit 1
fi

# Navigate to the self-hosted-ai-starter-kit directory
cd /home/dimoss/self-hosted-ai-starter-kit || {
    echo "Error: Could not find the self-hosted-ai-starter-kit directory"
    echo "Please make sure the directory exists at /home/dimoss/self-hosted-ai-starter-kit"
    exit 1
}

# Start the Docker Compose services in detached mode
docker compose up -d

echo "=== n8n Server Stack Started ==="
echo "To check the status of the containers, run: docker compose ps"
echo "To view the logs, run: docker compose logs -f"
