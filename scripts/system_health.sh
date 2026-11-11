
#!/bin/bash

# Configuration
REPORT_DIR="./reports"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
REPORT_FILE="${REPORT_DIR}/system_health_${TIMESTAMP}.txt"

# Create report directory
mkdir -p "$REPORT_DIR"

# Send output to terminal and report file
exec > >(tee "$REPORT_FILE") 2>&1

echo "=========================================="
echo "          SYSTEM HEALTH REPORT"
echo "=========================================="

echo "Hostname: $(hostname)"
echo "Date: $(date)"
echo "Uptime: $(uptime -p)"

echo ""
echo "------------- CPU USAGE ------------------"

CPU_IDLE=$(top -bn1 | grep "Cpu(s)" | awk '{print $8}' | cut -d. -f1)
CPU_USAGE=$((100 - CPU_IDLE))

echo "CPU Usage: ${CPU_USAGE}%"

if [ "$CPU_USAGE" -gt 80 ]; then
    echo "WARNING: High CPU usage!"
else
    echo "OK: CPU usage is normal."
fi

echo ""
echo "------------- MEMORY USAGE ---------------"

MEMORY_TOTAL=$(free -m | awk '/Mem:/ {print $2}')
MEMORY_USED=$(free -m | awk '/Mem:/ {print $3}')

MEMORY_USAGE=$((MEMORY_USED * 100 / MEMORY_TOTAL))

echo "Total Memory: ${MEMORY_TOTAL} MB"
echo "Used Memory: ${MEMORY_USED} MB"
echo "Memory Usage: ${MEMORY_USAGE}%"

if [ "$MEMORY_USAGE" -gt 80 ]; then
    echo "WARNING: High memory usage!"
else
    echo "OK: Memory usage is normal."
fi

echo ""
echo "------------- DISK USAGE -----------------"

df -h

DISK_USAGE=$(df -P / | awk 'NR==2 {gsub("%","",$5); print $5}')

echo "Root Disk Usage: ${DISK_USAGE}%"

if [ "$DISK_USAGE" -gt 80 ]; then
    echo "WARNING: High disk usage!"
else
    echo "OK: Disk usage is normal."
fi

echo ""
echo "------------- SERVICE STATUS -------------"

SERVICES=("nginx" "ssh" "cron")

for SERVICE in "${SERVICES[@]}"; do

    if systemctl is-active --quiet "$SERVICE"; then
        echo "OK: $SERVICE is RUNNING"
    else
        echo "WARNING: $SERVICE is NOT RUNNING"
    fi

done

echo ""
echo "=========================================="
echo "       SYSTEM HEALTH CHECK COMPLETED"
echo "=========================================="

echo "Report saved at: $REPORT_FILE"
