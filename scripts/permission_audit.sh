
#!/bin/bash

# Permission Audit Script

TARGET_DIR="$1"
REPORT="permission_audit_$(date +%Y%m%d_%H%M%S).log"

if [ -z "$TARGET_DIR" ]; then
    echo "Usage: $0 <directory>"
    exit 1
fi

if [ ! -d "$TARGET_DIR" ]; then
    echo "ERROR: Directory does not exist"
    exit 1
fi

echo "===================================" | tee "$REPORT"
echo "       PERMISSION AUDIT REPORT     " | tee -a "$REPORT"
echo "===================================" | tee -a "$REPORT"

echo "Server: $(hostname)" | tee -a "$REPORT"
echo "Date: $(date)" | tee -a "$REPORT"
echo "Directory: $TARGET_DIR" | tee -a "$REPORT"

echo "" | tee -a "$REPORT"
echo "Checking world-writable files..." | tee -a "$REPORT"

find "$TARGET_DIR" -type f -perm -0002 -print | tee -a "$REPORT"

echo "" | tee -a "$REPORT"
echo "Checking world-writable directories..." | tee -a "$REPORT"

find "$TARGET_DIR" -type d -perm -0002 -print | tee -a "$REPORT"

echo "" | tee -a "$REPORT"
echo "Checking files with SUID permission..." | tee -a "$REPORT"

find "$TARGET_DIR" -type f -perm -4000 -print | tee -a "$REPORT"

echo "" | tee -a "$REPORT"
echo "===================================" | tee -a "$REPORT"
echo "Audit completed successfully"
echo "Report saved: $REPORT"
echo "==================================="

exit 0
