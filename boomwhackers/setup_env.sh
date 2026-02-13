#!/bin/bash

# ==============================================================================
# FEDORA SILVERBLUE / KINOITE SETUP SCRIPT FOR BOOMWHACKER PROJECT
# 
# This script:
# 1. Checks if you are inside a Toolbox container.
# 2. Installs system dependencies (ffmpeg, python-devel).
# 3. Creates a Python virtual environment (venv).
# 4. Installs Python tools: Basic Pitch, WhackerHero, yt-dlp.
# ==============================================================================

# --- Function: Check if running inside a Toolbox ---
is_toolbox() {
    if [ -f /run/.containerenv ] && grep -q 'name="toolbox"' /run/.containerenv; then
        return 0
    elif [ -f /run/.toolboxenv ]; then
        return 0
    else
        return 1
    fi
}

# --- Step 1: Enforce Toolbox Environment ---
if ! is_toolbox; then
    echo "❌ ERROR: You are running this on the Host System (Silverblue)."
    echo "   On immutable systems, you must use a Toolbox container for development."
    echo ""
    echo "   Please run the following commands:"
    echo "     1. toolbox create -y (if you haven't already)"
    echo "     2. toolbox enter"
    echo "     3. ./setup_env.sh"
    exit 1
fi

echo "✅ Detected Toolbox environment. Proceeding..."

# --- Step 2: Install System Dependencies (DNF) ---
echo "--- 📦 Installing System Dependencies (ffmpeg, python3, git) ---"
sudo dnf install -y \
    ffmpeg \
    python3-devel \
    gcc \
    git \
    portaudio-devel \
    python3-tkinter \
    openh264

# --- Step 3: Create Python Virtual Environment ---
echo "--- 🐍 Setting up Python Virtual Environment ---"
VENV_DIR="venv_boomwhacker"

if [ -d "$VENV_DIR" ]; then
    echo "   Virtual environment '$VENV_DIR' already exists."
else
    python3 -m venv "$VENV_DIR"
    echo "   Created new venv at ./$VENV_DIR"
fi

# Activate the venv for the following commands
source "$VENV_DIR/bin/activate"

# --- Step 4: Install Python Libraries ---
echo "--- 📥 Installing Python Packages ---"

# Upgrade pip and setuptools first
pip install --upgrade pip setuptools wheel

# 1. yt-dlp (Downloading YouTube videos)
# 2. basic-pitch (Audio to MIDI)
# 3. whackerhero (The specific Boomwhacker generator tool)
#    Note: Installing directly from GitHub to ensure latest version
echo "   Installing yt-dlp, basic-pitch, and WhackerHero..."

pip install yt-dlp basic-pitch

# Installing WhackerHero from the source we found (allejok96/whackerhero)
# We accept the [gui] option to ensure all graphical deps like Pillow are grabbed
# Using modern Direct URL requirement syntax instead of deprecated #egg= format
pip install "whackerhero[gui] @ git+https://github.com/allejok96/whackerhero.git"

# --- Step 5: Success Message ---
echo ""
echo "=================================================================="
echo "🎉 SETUP COMPLETE!"
echo "=================================================================="
echo "To start working, run:"
echo "   source $VENV_DIR/bin/activate"
echo ""
echo "Then you can run the python generation script I provided earlier."
echo "=================================================================="