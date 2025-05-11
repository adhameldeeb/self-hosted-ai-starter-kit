#!/bin/bash

# SSL setup script for n8n stack on DigitalOcean
# This script configures Caddy as a reverse proxy with automatic HTTPS

# Load configuration
source $(dirname "$0")/config.env

# Check if running as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root"
    exit 1
fi

# Check if domain is configured
if [ -z "$DOMAIN_NAME" ]; then
    echo "Error: Domain name not set in config.env"
    echo "Please set DOMAIN_NAME in config.env and run this script again"
    exit 1
fi

echo "=== Starting SSL setup ==="
echo "Domain: $DOMAIN_NAME"

# Install Caddy
echo "=== Installing Caddy ==="
apt install -y debian-keyring debian-archive-keyring apt-transport-https
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | tee /etc/apt/sources.list.d/caddy-stable.list
apt update
apt install -y caddy

# Create Caddyfile
echo "=== Configuring Caddy ==="
cat > /etc/caddy/Caddyfile << EOL
$DOMAIN_NAME {
    reverse_proxy localhost:5678
    tls {
        issuer acme
    }
}

www.$DOMAIN_NAME {
    redir https://$DOMAIN_NAME{uri} permanent
}
EOL

# Setup firewall
echo "=== Configuring firewall for HTTPS ==="
ufw allow 80/tcp
ufw allow 443/tcp

# Start Caddy service
echo "=== Starting Caddy service ==="
systemctl enable caddy
systemctl restart caddy

# Check if Caddy is running
echo "=== Checking if Caddy is running ==="
if systemctl is-active --quiet caddy; then
    echo "Caddy is running"
else
    echo "Caddy is not running, check the logs with: journalctl -u caddy"
    exit 1
fi

echo "=== SSL setup completed ==="
echo "Your n8n instance should now be accessible at: https://$DOMAIN_NAME"
echo ""
echo "Note: It may take a few minutes for Caddy to obtain an SSL certificate from Let's Encrypt."
echo "You can check the status with: systemctl status caddy"
