
#!/bin/bash

set -e

# Configuration
LOGS_DIR="./logs"
BACKUP_DIR="./backup"
REPORTS_DIR="./reports"
DAYS_OLD=7

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_NAME="logs_backup_${TIMESTAMP}"
ARCHIVE="${BACKUP_DIR}/${BACKUP_NAME}.tar.gz"
REPORT_FILE="${REPORTS_DIR}/cleanup_report_${TIMESTAMP}.txt"

# Create directories
mkdir -p "$BACKUP_DIR" "$REPORTS_DIR"

# Dry-run by default
DRY_RUN=true

if [[ "${1:-}" == "--exec" ]]; then
    DRY_RUN=false
elif [[ $# -gt 0 ]]; then
    echo "Usage: $0 [--exec]"
    exit 1
fi

# Find eligible log files
mapfile -t ELIGIBLE_FILES < <(
    find "$LOGS_DIR" -maxdepth 1 -type f -name "*.log" -mtime +"$DAYS_OLD"
)

FILE_COUNT=${#ELIGIBLE_FILES[@]}

echo "=========================================="
echo "          LOG CLEANUP SUMMARY"
echo "=========================================="

if [ "$DRY_RUN" = true ]; then
    echo "STATUS: DRY-RUN MODE"
else
    echo "STATUS: EXECUTION MODE"
fi

echo "Files older than $DAYS_OLD days: $FILE_COUNT"
echo "------------------------------------------"

if [ "$FILE_COUNT" -eq 0 ]; then
    echo "No files eligible for cleanup."
    exit 0
fi

for file in "${ELIGIBLE_FILES[@]}"; do
    echo "Eligible: $file"
done

# Stop if dry-run
if [ "$DRY_RUN" = true ]; then
    echo "------------------------------------------"
    echo "No files deleted."
    echo "Run with --exec to perform cleanup."
    exit 0
fi

# Create compressed backup
echo "Creating backup..."

tar -czf "$ARCHIVE" -C "$LOGS_DIR" \
    "${ELIGIBLE_FILES[@]##*/}"

# Verify archive integrity
echo "Verifying backup..."

tar -tzf "$ARCHIVE" > /dev/null

# Verify archive contains all eligible files
ARCHIVE_COUNT=$(tar -tzf "$ARCHIVE" | wc -l)

if [ "$ARCHIVE_COUNT" -ne "$FILE_COUNT" ]; then
    echo "ERROR: Backup file count mismatch. No deletion performed."
    exit 1
fi

echo "Backup verified: $ARCHIVE"

# Delete original files only after verification
SUCCESS_COUNT=0
FAILED_COUNT=0
PURGED_FILES=()

echo "Starting cleanup..."

for file in "${ELIGIBLE_FILES[@]}"; do
    if rm -- "$file"; then
        SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
        PURGED_FILES+=("$file")
    else
        FAILED_COUNT=$((FAILED_COUNT + 1))
    fi
done

# Generate cleanup report
{
    echo "=========================================="
    echo "          LOG CLEANUP REPORT"
    echo "=========================================="
    echo "Date: $(date)"
    echo "Backup: $ARCHIVE"
    echo "Eligible files: $FILE_COUNT"
    echo "Successfully cleaned: $SUCCESS_COUNT"
    echo "Failed deletions: $FAILED_COUNT"
    echo "------------------------------------------"
    echo "Successfully deleted files:"

    for file in "${PURGED_FILES[@]}"; do
        echo "$file"
    done

    echo "=========================================="
} > "$REPORT_FILE"

# Final summary
echo "=========================================="
echo "Cleanup completed."
echo "Successfully cleaned: $SUCCESS_COUNT"
echo "Failed deletions: $FAILED_COUNT"
echo "Report: $REPORT_FILE"
echo "=========================================="

if [ "$FAILED_COUNT" -gt 0 ]; then
    exit 1
fi
