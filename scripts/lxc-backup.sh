#!/bin/bash

STORAGE="hdd-backup"
BACKUP_DIR="/mnt/hdd/proxmox-backups/dump"
LOG="/var/log/lxc-backup.log"
DATE=$(date '+%Y-%m-%d %H:%M:%S')
VMIDS="151 152 153 154 157"
KEEP=2

echo "[$DATE] Starting LXC backup" >> $LOG

for VMID in $VMIDS; do
    echo "[$DATE] Backing up VMID $VMID" >> $LOG
    vzdump $VMID \
        --storage $STORAGE \
        --mode snapshot \
        --compress zstd \
        --quiet 1 >> $LOG 2>&1

    if [ $? -eq 0 ]; then
        echo "[$DATE] VMID $VMID backup complete" >> $LOG
    else
        echo "[$DATE] ERROR: VMID $VMID backup failed" >> $LOG
    fi

    # Prune old backups — keep only last $KEEP for this VMID
    ls -t "$BACKUP_DIR"/vzdump-lxc-${VMID}-*.tar.zst 2>/dev/null | \
        tail -n +$((KEEP + 1)) | \
        xargs -r rm -v >> $LOG 2>&1
done

echo "[$DATE] LXC backup complete" >> $LOG
