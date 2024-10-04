# Custom Recycle Bin Shell Script

## Overview
This project provides a custom recycle bin solution for Linux systems using shell scripts. It allows users to safely delete and restore files without losing data permanently by moving files to a recycle bin instead of deleting them outright.

## Features
- **Recycle files**: Use `recyclebin1.sh` to move files to a custom recycle bin located in `~/recyclebin` instead of permanently deleting them.
- **Restore files**: Use `restore` to recover files that were moved to the recycle bin, returning them to their original location.
- **Confirmation and Verbose modes**: Enable confirmation before recycling files or get detailed output.
- **Safe Deletion**: Prevents deletion of the script itself to avoid accidental removal.

## Installation
1. Clone the repository to your local machine.
2. Copy `recyclebin1.sh` and `restore` to a directory in your PATH (e.g., `/usr/local/bin`).
3. Ensure both scripts are executable:
    ```bash
    chmod +x /usr/local/bin/recyclebin1.sh
    chmod +x /usr/local/bin/restore
    ```

## Usage

### Recycle a File
To delete (recycle) a file:
```bash
./recyclebin1.sh file_name
```

#### Options:
- `-i`: Ask for confirmation before deleting each file.
- `-v`: Enable verbose mode to print details of the operations.
- `-r`: Recursively delete directories.

Example:
```bash
./recyclebin1.sh -i -v -r directory_name
```

### Restore a File
To restore a file:
```bash
./restore file_name
```

If there are multiple copies of the file in the recycle bin, the script will allow you to choose which one to restore.

## Files
- **recyclebin1.sh**: Script to move files to a custom recycle bin.
- **restore**: Script to restore files from the recycle bin.

## Notes
- The recycle bin is located at `~/recyclebin`.
- The `restore` script keeps track of original file paths in `~/recyclebin/.restore.info`.
- Files are stored in the recycle bin using their inode number to avoid name conflicts.