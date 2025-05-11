#!/bin/bash

# Initial server setup script for n8n deployment on DigitalOcean
# This script installs Docker, Docker Compose, and other required dependencies

# Load configuration
source $(dirname "$0")/config.env

# Check if running as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root"
    exit 1
fi

echo "=== Starting server setup ==="
echo "This script will install Docker and other dependencies required for n8n deployment"

# Update system packages
echo "=== Updating system packages ==="
apt update
apt upgrade -y

# Install dependencies
echo "=== Installing dependencies ==="
apt install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    git \
    ufw \
    htop \
    unzip

# Install Docker
echo "=== Installing Docker ==="
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
rm get-docker.sh

# Install Docker Compose plugin
echo "=== Installing Docker Compose ==="
apt install -y docker-compose-plugin

# Create directory for shared files
echo "=== Creating shared directory ==="
mkdir -p /root/self-hosted-ai-starter-kit/shared
chmod 777 /root/self-hosted-ai-starter-kit/shared

# Configure firewall
echo "=== Configuring firewall ==="
ufw allow ssh
ufw allow 5678/tcp  # n8n web interface
ufw allow 6333/tcp  # Qdrant

if [ "$USE_SSL" = true ] && [ ! -z "$DOMAIN_NAME" ]; then
    ufw allow 80/tcp   # HTTP for Caddy HTTPS setup
    ufw allow 443/tcp  # HTTPS
fi

# Enable firewall
echo "=== Enabling firewall ==="
echo "y" | ufw enable

# Create directory for backups
echo "=== Creating backup directory ==="
mkdir -p $BACKUP_DIR

# Display version information
echo "=== Installation completed ==="
echo "Docker version:"
docker --version
echo "Docker Compose version:"
docker compose version

echo "=== Server setup completed ==="
echo "You can now run deploy.sh to deploy the n8n stack"
