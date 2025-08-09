#!/bin/bash
set -euo pipefail

# Set directories for backup
IMGNXDAW_PLUGIN_DIR="$HOME/Music/Audio Music Apps"
IMGNXDAW_SUPPORT_DIR="$HOME/Library/Application Support/Logic"
IMGNXDAW_PREFS_FILE="$HOME/Library/Preferences/com.apple.logic10.plist"

IMGNXDAW_CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/imgnx"
IMGNXDAW_CACHE_FILE="$IMGNXDAW_CACHE_DIR/logic_bk_repo_url"
IMGNXDAW_BACKUP_DIR_FILE="$IMGNXDAW_CACHE_DIR/logic_bk_dir"
IMGNXDAW_TRANSIENT_DIR="${IMGNXDAW_CACHE_DIR}/logic_trans_dir"

mkdir -p "$IMGNXDAW_CACHE_DIR"


# Load or prompt for backup directory
if [ -f "$IMGNXDAW_BACKUP_DIR_FILE" ]; then
    IMGNXDAW_BACKUP_DIR=$(cat "$IMGNXDAW_BACKUP_DIR_FILE")
    read -rp "Would you like to keep backup directory '$IMGNXDAW_BACKUP_DIR'? (Y/n): " CONFIRM_BK
    if [[ "${CONFIRM_BK:-Y}" =~ ^[Nn]$ ]]; then
        read -rp "Enter your new backup directory: " IMGNXDAW_BACKUP_DIR
        echo "$IMGNXDAW_BACKUP_DIR" > "$IMGNXDAW_BACKUP_DIR_FILE"
    fi
else
    read -rp "Enter the backup directory (default: ~/Downloads/logic-backups): " USER_BACKUP_DIR
    IMGNXDAW_BACKUP_DIR="${USER_BACKUP_DIR:-$HOME/Downloads/logic-backups}"
    echo "$IMGNXDAW_BACKUP_DIR" > "$IMGNXDAW_BACKUP_DIR_FILE"
fi


# Load or prompt for remote git repo URL
if [ -f "$IMGNXDAW_CACHE_FILE" ]; then
    IMGNXDAW_REMOTE_REPO_URL=$(cat "$IMGNXDAW_CACHE_FILE")
    read -rp "Would you like to keep remote repo URL '$IMGNXDAW_REMOTE_REPO_URL'? (Y/n): " CONFIRM_URL
    if [[ "${CONFIRM_URL:-Y}" =~ ^[Nn]$ ]]; then
        read -rp "Enter your new remote git repository URL: " IMGNXDAW_REMOTE_REPO_URL
        echo "$IMGNXDAW_REMOTE_REPO_URL" > "$IMGNXDAW_CACHE_FILE"
    fi
else
    read -rp "Enter your remote git repository URL: " IMGNXDAW_REMOTE_REPO_URL
    echo "$IMGNXDAW_REMOTE_REPO_URL" > "$IMGNXDAW_CACHE_FILE"
fi


# Check if backup directory exists, if not create it
if [ ! -d "$IMGNXDAW_BACKUP_DIR" ]; then
    echo "Backup directory not found, creating..."
    mkdir -p "$IMGNXDAW_BACKUP_DIR"
    cd "$IMGNXDAW_BACKUP_DIR" || exit 1
    if [ ! -d .git ]; then
        git init
        echo "Git repository initialized."
    fi
    if ! git remote | grep -q origin; then
        git remote add origin "$IMGNXDAW_REMOTE_REPO_URL"
        echo "Git remote 'origin' added."
    fi
else
    echo "Backup directory exists, proceeding..."
    cd "$IMGNXDAW_BACKUP_DIR" || exit 1
    if [ ! -d .git ]; then
        git init
        echo "Git repository initialized."
    fi
    if ! git remote | grep -q origin; then
        git remote add origin "$IMGNXDAW_REMOTE_REPO_URL"
        echo "Git remote 'origin' added."
    fi
fi

export IMGNXDAW_PLUGIN_DIR
export IMGNXDAW_SUPPORT_DIR
export IMGNXDAW_PREFS_FILE
export IMGNXDAW_CACHE_DIR
export IMGNXDAW_CACHE_FILE
export IMGNXDAW_BACKUP_DIR_FILE
export IMGNXDAW_TRANSIENT_DIR

# Assert required variables are set
: "${IMGNXDAW_PLUGIN_DIR:?IMGNXDAW_PLUGIN_DIR must be set}"
: "${IMGNXDAW_SUPPORT_DIR:?IMGNXDAW_SUPPORT_DIR must be set}"
: "${IMGNXDAW_PREFS_FILE:?IMGNXDAW_PREFS_FILE must be set}"
: "${IMGNXDAW_CACHE_DIR:?IMGNXDAW_CACHE_DIR must be set}"
: "${IMGNXDAW_CACHE_FILE:?IMGNXDAW_CACHE_FILE must be set}"
: "${IMGNXDAW_BACKUP_DIR_FILE:?IMGNXDAW_BACKUP_DIR_FILE must be set}"
: "${IMGNXDAW_TRANSIENT_DIR:?IMGNXDAW_TRANSIENT_DIR must be set}"

# Print values for confirmation
cat <<EOF
IMGNXDAW_PLUGIN_DIR=$IMGNXDAW_PLUGIN_DIR
IMGNXDAW_SUPPORT_DIR=$IMGNXDAW_SUPPORT_DIR
IMGNXDAW_PREFS_FILE=$IMGNXDAW_PREFS_FILE
IMGNXDAW_CACHE_DIR=$IMGNXDAW_CACHE_DIR
IMGNXDAW_CACHE_FILE=$IMGNXDAW_CACHE_FILE
IMGNXDAW_BACKUP_DIR_FILE=$IMGNXDAW_BACKUP_DIR_FILE
IMGNXDAW_TRANSIENT_DIR=$IMGNXDAW_TRANSIENT_DIR
EOF

# Ask user for action: backup or restore
echo ""
echo "Select an option:"
echo "  [b] Back up plugin settings"
echo "  [r] Restore plugin settings from remote"
echo "  [t] Transient backup rollback (in case you need to revert changes)"
read -rp "Enter your choice [b/r/t]: " ACTION
case "$ACTION" in
    b|B)
        echo "Backing up plugin settings..."
        bash "$(dirname "$0")/bk.sh"
    ;;
    r|R)
        read -rp "Are you sure you want to restore plugin settings from the remote repository? This will overwrite your current settings. (y/N): " CONFIRM_RESTORE
        if [[ "$CONFIRM_RESTORE" =~ ^[Yy]$ ]]; then
            echo "Backing up current plugin settings before restoring..."
            bash "$(dirname "$0")/bk.sh"
            echo "Pulling latest plugin settings from remote repository..."
            cd "$IMGNXDAW_BACKUP_DIR" || exit 1
            if git pull origin main; then
                echo "Pulled latest plugin settings from remote repository."
                echo "Restoring plugin settings from remote backup..."
                bash "$(dirname "$0")/restore.sh"
            else
                echo "Error: git pull failed. Could not restore from remote repository."
                echo "Restore cancelled."
                exit 1
            fi
            echo "Restoring plugin settings from remote backup..."
            bash "$(dirname "$0")/restore.sh"
        else
            echo "Restore cancelled."
        fi
    ;;
    t|T)
        read -rp "Are you sure you want to restore from the transient backup? This will overwrite your current settings. (y/N): " CONFIRM_TRANSIENT
        if [[ "$CONFIRM_TRANSIENT" =~ ^[Yy]$ ]]; then
            echo "Restoring plugin settings from transient backup..."
            bash "$(dirname "$0")/transient.sh"
        else
            echo "Transient restore cancelled."
        fi
    ;;
    *)
        echo "No action taken. Exiting."
    ;;
esac
