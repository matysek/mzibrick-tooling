#!/bin/bash
# Script to apply the whackerhero patch for bigger notes
# Run this after setting up the virtual environment

set -e

# Ensure we're in the correct directory
cd "$(dirname "$0")"

# Check if virtual environment exists
if [ ! -d "venv_boomwhacker" ]; then
    echo "Error: Virtual environment not found. Run ./setup_env.sh first."
    exit 1
fi

# Find the whackerhero.py file
WHACKERHERO_PATH="venv_boomwhacker/lib/python3.11/site-packages/whackerhero.py"

if [ ! -f "$WHACKERHERO_PATH" ]; then
    echo "Error: whackerhero.py not found at $WHACKERHERO_PATH"
    echo "Make sure whackerhero is installed in the virtual environment."
    exit 1
fi

# Apply the patch
echo "Applying whackerhero patch for bigger notes..."
patch "$WHACKERHERO_PATH" < whackerhero-bigger-notes.patch

echo "✓ Patch applied successfully!"
echo "NOTE_WIDTH is now set to 0.6 (60% of column width) for better visibility."
