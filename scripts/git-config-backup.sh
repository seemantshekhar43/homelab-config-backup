#!/bin/bash

REPO_DIR="/opt/homelab-config-backup"
LOG="/var/log/git-config-backup.log"
DATE=$(date '+%Y-%m-%d %H:%M:%S')

echo "[$DATE] Starting config backup" >> $LOG

# Copy configs into repo
cp -r /etc/pve "$REPO_DIR/"
cp /etc/network/interfaces "$REPO_DIR/"
cp /etc/hosts "$REPO_DIR/"
cp /etc/hostname "$REPO_DIR/"

cp /usr/local/bin/git-config-backup.sh "$REPO_DIR/scripts/"
cp /usr/local/bin/lxc-backup.sh "$REPO_DIR/scripts/"
cp /usr/local/bin/gdrive-sync.sh "$REPO_DIR/scripts/"

cd "$REPO_DIR"

git add -A

# Only commit if there are changes
if git diff --cached --quiet; then
    echo "[$DATE] No changes to commit" >> $LOG
else
    git commit -m "config backup: $DATE"
    git push origin main >> $LOG 2>&1
    echo "[$DATE] Pushed to GitHub successfully" >> $LOG
fi
