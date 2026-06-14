#!/bin/bash

BACKUP_DIR="/mnt/hdd/proxmox-backups/dump"
GDRIVE_DIR="gdrive:proxmox-backups"
LOG="/var/log/gdrive-sync.log"
DATE=$(date '+%Y-%m-%d %H:%M:%S')
VMIDS="151 152 153 154 157 158 159 160 161 162"

echo "[$DATE] Starting GDrive sync" >> $LOG

for VMID in $VMIDS; do
    LATEST=$(ls -t "$BACKUP_DIR"/vzdump-lxc-${VMID}-*.tar.zst 2>/dev/null | head -1)

    if [ -z "$LATEST" ]; then
        echo "[$DATE] No backup found for VMID $VMID, skipping" >> $LOG
        continue
    fi

    FILENAME=$(basename "$LATEST")
    echo "[$DATE] Syncing $FILENAME to GDrive" >> $LOG

    rclone copyto "$LATEST" "$GDRIVE_DIR/$FILENAME" \
        --transfers 1 \
        --drive-chunk-size 128M \
        --no-update-modtime \
        --log-file "$LOG" \
        --log-level INFO

    # Delete older backups for this VMID from GDrive (keep only latest)
    rclone lsf "$GDRIVE_DIR" --files-only | \
        grep "vzdump-lxc-${VMID}-" | \
        grep -v "$FILENAME" | \
        while read OLD; do
            echo "[$DATE] Removing old GDrive backup: $OLD" >> $LOG
            rclone delete "$GDRIVE_DIR/$OLD" >> $LOG 2>&1
        done
done

echo "[$DATE] GDrive sync complete" >> $LOG
