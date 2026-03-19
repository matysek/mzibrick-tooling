#!/bin/bash

# Define the target directory (default is current directory)
TARGET_DIR=${1:-.}

# Ensure the directory exists
if [ ! -d "$TARGET_DIR" ]; then
    echo "Error: Directory $TARGET_DIR does not exist."
    exit 1
fi

echo "Scanning for .htaccess files in: $(realpath "$TARGET_DIR")"
echo "-----------------------------------"

# 1. Check if any files exist first without storing them in a messy variable
# We use a subshell to count matches quickly
FILE_COUNT=$(find "$TARGET_DIR" -type f -name ".htaccess" | wc -l)

if [ "$FILE_COUNT" -eq 0 ]; then
    echo "No .htaccess files found. You're clean!"
    exit 0
fi

echo "Found $FILE_COUNT .htaccess file(s):"
find "$TARGET_DIR" -type f -name ".htaccess"
echo "-----------------------------------"

# 2. Check for the force flag
if [[ "$2" == "--force" ]]; then
    echo "Action: DELETING ALL FOUND FILES..."
    # -delete is the safest and fastest way to handle many files
    find "$TARGET_DIR" -type f -name ".htaccess" -delete
    echo "Done. $FILE_COUNT files removed."
else
    echo "Safe Mode: No files were deleted."
    echo "Run the script with '--force' to delete them."
    echo "Example: $0 $TARGET_DIR --force"
fi
