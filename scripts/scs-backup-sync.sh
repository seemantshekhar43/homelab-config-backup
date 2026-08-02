#!/bin/bash

SCS_BACKUP_DIR="/mnt/hdd/shared/scs/backup"
GDRIVE_DIR="gdrive:homelab-shared-backup/scs"
LOG="/var/log/scs-backup-sync.log"
DATE=$(date '+%Y-%m-%d %H:%M:%S')

echo "[$DATE] Starting scs backup sync" >> "$LOG"

rclone sync "$SCS_BACKUP_DIR" "$GDRIVE_DIR" \
    --transfers 4 \
    --log-file "$LOG" \
    --log-level INFO

if [ $? -eq 0 ]; then
    echo "[$DATE] scs backup sync complete" >> "$LOG"
else
    echo "[$DATE] ERROR: scs backup sync failed" >> "$LOG"
fi
