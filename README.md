# Logic Pro Plugin Settings Backup

This script automates the backup of your Logic Pro plugin settings, ensuring your custom configurations are
safely stored and easily restorable.

## Features

- Backs up all user plugin settings for Logic Pro.
- Organizes backups by date for easy retrieval.
- Simple and fast operation.
- Restore plugin settings from the remote repository backup, not from your local backup directory.
- Transient restoration: restore your previous settings from a temporary backup made before any restoration.

## Usage

1. Clone this repository:
   ```bash
   git clone https://github.com/yourusername/logic-pro-plugin-settings-backup.git
   ```
2. Run the main script:
   ```bash
   ./main.sh
   ```
   - Choose to back up or restore your Logic Pro plugin settings interactively.
   - If you restore, your current settings are backed up to a transient location before restoration.
   - Restoration pulls your plugin settings from the remote repository backup.
3. To restore from the transient backup (if you encounter issues after restoration):
   ```bash
   ./transient.sh
   ```
4. Find your backups in the backup directory you specify.

## Requirements

- Python 3.x
- macOS with Logic Pro installed

For shell scripts:

- Bash (macOS default)

## Customization

You can modify the script to change the backup location or schedule automatic backups.

## License

MIT License

## Contributing

Pull requests and suggestions are welcome!
