#!/bin/bash

SHARED_DIR="/mnt/hdd/shared"
GDRIVE_DIR="gdrive:homelab-shared-backup"
LOG="/var/log/shared-backup.log"
DATE=$(date '+%Y-%m-%d %H:%M:%S')

echo "[$DATE] Starting shared backup" >> $LOG

rclone sync "$SHARED_DIR" "$GDRIVE_DIR" \
    --transfers 4 \
    --log-file "$LOG" \
    --log-level INFO

if [ $? -eq 0 ]; then
    echo "[$DATE] Shared backup complete" >> $LOG
else
    echo "[$DATE] ERROR: Shared backup failed" >> $LOG
fi
