#!/bin/bash
# Set recyclebin and .restore location
recyclebin="$HOME/recyclebin"
restore="$HOME/recyclebin/.restore.info"

# Create a recycle bin directory in $HOME if it doesn't exist
mkdir -p "$recyclebin"

# Options
confirmation=0
verbose=0
recursive=0

# Parse options
while getopts ":ivr" opt; do
    case "$opt" in
        i) confirmation=1 ;;
        v) verbose=1 ;;
        r) recursive=1 ;;
        \?) echo "Error: Invalid option -$OPTARG"; exit 1 ;;
    esac
done

# Shift past the options
shift $((OPTIND-1))

# Check if any file or directory is provided
if [ $# -eq 0 ]; then
    echo "Error: No file or directory name provided"
    exit 2
fi

# Function to handle individual file processing
process_file() {
    local file="$1"
    local file_path
    local file_name
    local file_inode
    local recycle_file

    # Get file info
    file_path=$(realpath "$file")
    file_name=$(basename "$file")
    file_inode=$(ls -i "$file" | cut -d ' ' -f1)
    recycle_file="$recyclebin/${file_name}_$file_inode"

    # Check if file exists
    if [ ! -e "$file" ]; then
        echo "Error: $file does not exist"
        return
    fi

    # Check if trying to delete the recycle script itself
    if [ "$file" == "$0" ]; then
        echo "Attempting to delete recycle - operation aborted"
        exit 1
    fi

    # Prompt for confirmation if required
    if [[ $confirmation -eq 1 ]]; then
        read -p "Recycle $file? (y/n): " input < /dev/tty
        if [[ "$input" != [yY] ]]; then
            return
        fi
    fi

    # Get file info
    file_path=$(realpath "$file")
    file_name=$(basename "$file")
    file_inode=$(ls -i "$file" | cut -d ' ' -f1)
    recycle_file="$recyclebin/${file_name}_$file_inode"

    # Move file to recycle bin
    if [ -e "$recycle_file" ]; then
        # If file already exists in the recycle bin, just remove the new file
        rm "$file"
    else
        ln "$file" "$recycle_file" && rm "$file" # Create a hard link in recycle bin and remove the original file
    fi

    # Log file info to .restore.info
    echo "$(basename "$recycle_file"):$file_path" >> "$restore"

    # Verbose option: print confirmation message
    if [ $verbose -eq 1 ]; then
        echo "Recycled $file_path to $recycle_file"
    fi
}

# Recursively process directories if -r option is set
if [ $recursive -eq 1 ]; then
    for item in "$@"; do
        if [ -d "$item" ]; then
            # Use file descriptor 3 for reading file paths
            exec 0< <(find "$item" -type f)
            while read -r file <&0; do
                process_file "$file"
            done
            exec 0>&-
        else
            process_file "$item"
        fi
    done
else
    # Process individual files or non-recursive directories
    for file in "$@"; do
        if [ -d "$file" ]; then
            echo "Error: $file is a directory. Use -r option to handle directories recursively."
            exit 1
        else
            process_file "$file"
        fi
    done
fi
