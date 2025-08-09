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


echo "Restoring Logic Pro plugin settings from transient backup: $IMGNXDAW_TRANSIENT_DIR"
cp -r "$IMGNXDAW_TRANSIENT_DIR/Audio Music Apps" "$HOME/Music/" 2>/dev/null || echo "Warning: Could not restore plugin dir."
cp -r "$IMGNXDAW_TRANSIENT_DIR/Logic" "$HOME/Library/Application Support/" 2>/dev/null || echo "Warning: Could not restore support dir."
cp "$IMGNXDAW_TRANSIENT_DIR/com.apple.logic10.plist" "$HOME/Library/Preferences/" 2>/dev/null || echo "Warning: Could not restore prefs file."

echo "Restoration from transient backup complete. Please verify your Logic Pro settings."


