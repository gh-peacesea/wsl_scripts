#!/bin/bash

# Backup directory
DESTINATION="/mnt/c/Users/roman/WSL_backups"

# Create a timestamp for the backup file
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

# Check if the script is running in dry-run mode
if [[ "$1" == "--dry-run" ]]; then
    # Print the estimated WSL backup size without actually performing the backup
    WSL_BACKUP_SIZE_GB=$(du -sh --exclude="$DESTINATION" "$HOME" | awk '{print $1}')
    echo "WSL backup size: $WSL_BACKUP_SIZE_GB GB"
else
    # Compress the WSL home directory (excluding the backup directory itself) and save it to the backup location
    tar -czf "$DESTINATION/$TIMESTAMP.tar.gz" --exclude="$DESTINATION" --directory="$HOME" .
    # Optionally, you can add additional backup commands or exclude specific files/directories using the --exclude flag in the tar command.
fi
