#!/bin/bash

# Backup script for n8n stack on DigitalOcean
# This script creates backups of n8n data, workflows, and PostgreSQL database

# Load configuration
source $(dirname "$0")/config.env

# Check if running as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root"
    exit 1
fi

DEPLOY_DIR="/root/self-hosted-ai-starter-kit"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_NAME="n8n_backup_$TIMESTAMP"
BACKUP_PATH="$BACKUP_DIR/$BACKUP_NAME"

# Check if deployment directory exists
if [ ! -d "$DEPLOY_DIR" ]; then
    echo "Deployment directory not found. Please run deploy.sh first."
    exit 1
fi

# Create backup directory if it doesn't exist
if [ ! -d "$BACKUP_DIR" ]; then
    echo "=== Creating backup directory ==="
    mkdir -p $BACKUP_DIR
fi

# Create backup subdirectory for this backup
mkdir -p $BACKUP_PATH

echo "=== Starting backup process ==="
echo "Backup will be saved to: $BACKUP_PATH"

# Backup the n8n storage directory
echo "=== Backing up n8n data ==="
docker run --rm \
    --volumes-from n8n \
    -v $BACKUP_PATH:/backup \
    alpine tar czf /backup/n8n_data.tar.gz /home/node/.n8n

# Backup the shared directory if it exists
if [ -d "$DEPLOY_DIR/shared" ] && [ "$(ls -A $DEPLOY_DIR/shared)" ]; then
    echo "=== Backing up shared directory ==="
    tar czf $BACKUP_PATH/shared_dir.tar.gz -C $DEPLOY_DIR shared
fi

# Backup the custom code directory if it exists
if [ -d "$DEPLOY_DIR/custom-code" ] && [ "$(ls -A $DEPLOY_DIR/custom-code)" ]; then
    echo "=== Backing up custom code ==="
    tar czf $BACKUP_PATH/custom_code.tar.gz -C $DEPLOY_DIR custom-code
fi

# Backup PostgreSQL database
echo "=== Backing up PostgreSQL database ==="
docker exec postgres pg_dump -U $POSTGRES_USER $POSTGRES_DB > $BACKUP_PATH/postgres_dump.sql

# Backup environment variables
echo "=== Backing up .env file ==="
cp $DEPLOY_DIR/.env $BACKUP_PATH/env_backup

# Create a backup manifest
echo "=== Creating backup manifest ==="
cat > $BACKUP_PATH/manifest.txt << EOL
Backup created: $(date)
n8n version: $(docker exec n8n n8n --version 2>/dev/null || echo "unknown")
Postgres version: $(docker exec postgres postgres --version 2>/dev/null || echo "unknown")

Backup contents:
- n8n_data.tar.gz: n8n storage directory (/home/node/.n8n)
- postgres_dump.sql: PostgreSQL database dump
- env_backup: .env file backup
EOL

if [ -f "$BACKUP_PATH/shared_dir.tar.gz" ]; then
    echo "- shared_dir.tar.gz: Shared directory" >> $BACKUP_PATH/manifest.txt
fi

if [ -f "$BACKUP_PATH/custom_code.tar.gz" ]; then
    echo "- custom_code.tar.gz: Custom code directory" >> $BACKUP_PATH/manifest.txt
fi

# Clean up old backups if KEEP_BACKUPS is set
if [ ! -z "$KEEP_BACKUPS" ] && [ "$KEEP_BACKUPS" -gt 0 ]; then
    echo "=== Cleaning up old backups, keeping $KEEP_BACKUPS most recent ==="
    ls -dt $BACKUP_DIR/n8n_backup_* | tail -n +$((KEEP_BACKUPS+1)) | xargs -r rm -rf
fi

echo "=== Backup completed successfully ==="
echo "Backup saved to: $BACKUP_PATH"
echo "To restore from this backup, use the following commands:"
echo "1. Stop existing containers: docker compose down"
echo "2. Restore the database: cat $BACKUP_PATH/postgres_dump.sql | docker exec -i postgres psql -U $POSTGRES_USER $POSTGRES_DB"
echo "3. Restore n8n data: tar -xzf $BACKUP_PATH/n8n_data.tar.gz -C /"
