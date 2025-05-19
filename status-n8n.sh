#!/bin/bash

# Script to check the status of the n8n server stack
# This script should be run on the DigitalOcean droplet

echo "=== Checking n8n Server Stack Status ==="

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

# Check the status of the Docker Compose services
docker compose ps

echo "=== Status Check Complete ==="
