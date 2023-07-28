#!/bin/bash

# Backup directory
DESTINATION="/mnt/c/Users/roman/WSL_backups"

# Create a timestamp for the backup file
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

# Compress the WSL home directory (excluding the backup directory itself) and save it to the backup location
tar -czf "$DESTINATION/$TIMESTAMP.tar.gz" --exclude="$DESTINATION" --directory="$HOME" .

# Optionally, you can add additional backup commands or exclude specific files/directories using the --exclude flag in the tar command.
