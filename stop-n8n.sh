#!/bin/bash

# Script to stop the n8n server stack using Docker Compose
# This script should be run on the DigitalOcean droplet

echo "=== Stopping n8n Server Stack ==="

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

# Stop the Docker Compose services
docker compose down

echo "=== n8n Server Stack Stopped ==="
