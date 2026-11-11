#!/bin/bash

exec > >(tee reports/disk_report.txt) 2>&1

# Define the threshold
THRESHOLD=80

# 1. Display a welcome message
echo "=========================================="
echo "   Welcome to System Disk Monitoring      "
echo "=========================================="

# 2. Display the current date and time
echo "Current Date and Time: $(date)"
echo "------------------------------------------"

# 3. Check overall disk usage
echo "--- Overall Disk Usage (df -h) ---"
df -h
echo "------------------------------------------"

# 4. Identify the filesystem with the highest disk usage
# Filters out header and pseudo-filesystems, sorts by usage percentage numerically (descending)
HIGHEST_FS=$(df -P | grep -v '^Filesystem' | sort -k5 -rn | head -n 1)
HIGHEST_NAME=$(echo "$HIGHEST_FS" | awk '{print $1}')
HIGHEST_MOUNT=$(echo "$HIGHEST_FS" | awk '{print $6}')
HIGHEST_USAGE_STR=$(echo "$HIGHEST_FS" | awk '{print $5}')
HIGHEST_USAGE_NUM=$(echo "$HIGHEST_USAGE_STR" | tr -d '%')

echo "Filesystem with the Highest Usage:"
echo "  Filesystem: $HIGHEST_NAME"
echo "  Mount Point: $HIGHEST_MOUNT"
echo "  Usage: $HIGHEST_USAGE_STR"
echo "------------------------------------------"

# 5 & 6. Display a warning or OK message based on the 80% threshold
if [ "$HIGHEST_USAGE_NUM" -gt "$THRESHOLD" ]; then
    echo "⚠️ WARNING: Disk usage on $HIGHEST_NAME ($HIGHEST_USAGE_STR) exceeds the ${THRESHOLD}% threshold!"
else
    echo "✅ OK: Highest disk usage ($HIGHEST_USAGE_STR) is below or equal to the ${THRESHOLD}% threshold."
fi
echo "==========================================" 
