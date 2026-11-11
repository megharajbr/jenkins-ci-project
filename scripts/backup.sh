
#!/bin/bash

# Exit on errors
set -e

# Configuration
SOURCE_DIR="$1"
BACKUP_DIR="./backup"
REPORT_DIR="./reports"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
LOG_FILE="${REPORT_DIR}/backup.log"

# Check argument
if [ -z "$SOURCE_DIR" ]; then
    echo "ERROR: Please provide a source directory."
    echo "Usage: $0 <source_directory>"
    exit 1
fi

# Check source directory
if [ ! -d "$SOURCE_DIR" ]; then
    echo "ERROR: Source directory does not exist: $SOURCE_DIR"
    exit 1
fi

# Create destination directories
mkdir -p "$BACKUP_DIR" "$REPORT_DIR"

# Get directory name
SOURCE_NAME=$(basename "$SOURCE_DIR")

# Backup filename
BACKUP_FILE="${BACKUP_DIR}/${SOURCE_NAME}_${TIMESTAMP}.tar.gz"

echo "=========================================="
echo "             BACKUP SUMMARY"
echo "=========================================="
echo "Source: $SOURCE_DIR"
echo "Starting backup..."

# Create compressed backup
if tar -czf "$BACKUP_FILE" -C "$(dirname "$SOURCE_DIR")" "$SOURCE_NAME"; then

    # Verify archive integrity
    if tar -tzf "$BACKUP_FILE" > /dev/null; then

        BACKUP_SIZE=$(du -h "$BACKUP_FILE" | awk '{print $1}')

        echo "Status: SUCCESS"
        echo "Backup: $BACKUP_FILE"
        echo "Size: $BACKUP_SIZE"

        # Record success in log
        echo "$(date) | SUCCESS | $SOURCE_DIR | $BACKUP_FILE | $BACKUP_SIZE" >> "$LOG_FILE"

    else
        echo "ERROR: Backup archive verification failed."
        rm -f "$BACKUP_FILE"
        exit 1
    fi

else
    echo "ERROR: Backup creation failed."
    rm -f "$BACKUP_FILE"
    exit 1
fi

echo "=========================================="
echo "Backup completed successfully."
echo "Log file: $LOG_FILE"
echo "=========================================="
