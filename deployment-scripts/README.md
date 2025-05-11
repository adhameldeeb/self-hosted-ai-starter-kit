# Deployment Scripts

This directory contains scripts to facilitate the deployment and management of your n8n instance on DigitalOcean. These scripts automate various tasks from initial setup to maintenance and updates.

## Scripts Overview

- `setup.sh`: Initial server setup (Docker, dependencies)
- `deploy.sh`: Deploy the n8n stack to your DigitalOcean droplet
- `update.sh`: Update your deployment with the latest images
- `backup.sh`: Backup your n8n data and configurations
- `monitoring.sh`: Basic health checks and monitoring
- `ssl-setup.sh`: Configure SSL with Caddy (requires a domain)

## Usage

1. First modify the `config.env` file with your specific settings
2. Make the scripts executable: `chmod +x *.sh`
3. Run the scripts in sequence:

```bash
# On your local machine
./setup.sh            # Run once to set up the server
./deploy.sh           # Deploy the application stack
./ssl-setup.sh        # Optional: Only if you have a domain

# For maintenance
./update.sh           # Run periodically to update
./backup.sh           # Run to create backups
./monitoring.sh       # Run to check system health
```

## Configuration

Edit the `config.env` file to customize your deployment:

- `DROPLET_IP`: Your DigitalOcean droplet IP address
- `SSH_KEY_PATH`: Path to your SSH key for the droplet
- `DOMAIN_NAME`: Your domain (optional, for SSL setup)
- `OPENAI_API_KEY`: Your OpenAI API key (if using OpenAI)
- Additional API keys and configuration options

## Adding Custom Code

If you need to add custom code or workflows:

1. Place your code in the `custom-code/` directory
2. Add your workflows to the `n8n/custom-workflows/` directory
3. Configure the `deploy.sh` script to copy these files to the appropriate locations

## Notes

- All scripts have been tested on Ubuntu 22.04 droplets
- Minimum recommended droplet size: 2GB RAM, 1 CPU (Basic)
- For resource-intensive workflows, consider scaling up your droplet
