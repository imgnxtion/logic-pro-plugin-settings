#!/bin/bash
#shellcheck shell=bash

# mv.sh — Restore plugin settings from backup
# Use the transient backup destination to temporarily
# backup settings before restoration — in case something
# gets overwritten — we want to confirm with the user that
# the backup worked and if they had problems, they can get
# their pre-restoration settings back by restoring from the
# transient backup location.

# Assert required variables
: "${IMGNXDAW_PLUGIN_DIR:?}"
: "${IMGNXDAW_SUPPORT_DIR:?}"
: "${IMGNXDAW_PREFS_FILE:?}"
: "${IMGNXDAW_BACKUP_DIR:?}"
: "${IMGNXDAW_TRANSIENT_DIR:?}"

echo "Creating transient backup of current Logic Pro plugin settings..."
mkdir -p "$IMGNXDAW_TRANSIENT_DIR"

# Backup current settings to transient location
cp -r "$IMGNXDAW_PLUGIN_DIR" "$IMGNXDAW_TRANSIENT_DIR/" 2>/dev/null || echo "Warning: Could not backup plugin dir."
cp -r "$IMGNXDAW_SUPPORT_DIR" "$IMGNXDAW_TRANSIENT_DIR/" 2>/dev/null || echo "Warning: Could not backup support dir."
cp "$IMGNXDAW_PREFS_FILE" "$IMGNXDAW_TRANSIENT_DIR/" 2>/dev/null || echo "Warning: Could not backup prefs file."

echo "Transient backup complete."
echo "If you encounter problems after restoration, you can restore your previous settings from: $IMGNXDAW_TRANSIENT_DIR"

# Confirm transient backup contents
echo "Contents of transient backup:"
ls -l "$IMGNXDAW_TRANSIENT_DIR"

# Restore from backup directory
echo "Restoring plugin settings from backup directory: $IMGNXDAW_BACKUP_DIR"
cp -r "$IMGNXDAW_BACKUP_DIR/Audio Music Apps" "$HOME/Music/" 2>/dev/null || echo "Warning: Could not restore plugin dir."
cp -r "$IMGNXDAW_BACKUP_DIR/Logic" "$HOME/Library/Application Support/" 2>/dev/null || echo "Warning: Could not restore support dir."
cp "$IMGNXDAW_BACKUP_DIR/com.apple.logic10.plist" "$HOME/Library/Preferences/" 2>/dev/null || echo "Warning: Could not restore prefs file."

echo "Restoration complete. Please verify your Logic Pro settings."


