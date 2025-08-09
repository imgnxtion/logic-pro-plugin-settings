#!/bin/bash
set -euo pipefail

# Copy plugin settings to backup folder
echo "Copying plugin settings..."
if [ -d "$IMGNXDAW_PLUGIN_DIR" ]; then
    cp -r "$IMGNXDAW_PLUGIN_DIR" "$IMGNXDAW_BACKUP_DIR/"
else
    echo "Warning: Plugin directory '$IMGNXDAW_PLUGIN_DIR' not found."
fi
if [ -d "$IMGNXDAW_SUPPORT_DIR" ]; then
    cp -r "$IMGNXDAW_SUPPORT_DIR" "$IMGNXDAW_BACKUP_DIR/"
else
    echo "Warning: Support directory '$IMGNXDAW_SUPPORT_DIR' not found."
fi
if [ -f "$IMGNXDAW_PREFS_FILE" ]; then
    cp "$IMGNXDAW_PREFS_FILE" "$IMGNXDAW_BACKUP_DIR/"
else
    echo "Warning: Preferences file '$IMGNXDAW_PREFS_FILE' not found."
fi


# Add new or changed files to Git
if git status --porcelain | grep .; then
    git add .
    git commit -m "chore: Backup at $(date)"
    if git remote | grep -q origin; then
        git push -u origin main || echo "Warning: git push failed. Please check your remote repository."
    else
        echo "Warning: No git remote 'origin' found. Skipping push."
    fi
    echo "Backup completed and pushed to the remote repository."
else
    echo "No changes to commit."
fi

