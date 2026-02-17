#!/bin/bash

# ==============================================================================
# FEDORA SILVERBLUE / KINOITE SETUP SCRIPT FOR BOOMWHACKER PROJECT
# 
# This script:
# 1. Checks if you are inside a Toolbox container.
# 2. Installs system dependencies (Python 3.11, ffmpeg, python-devel, numpy).
# 3. Creates a Python 3.11 virtual environment (venv) with system-site-packages.
# 4. Installs Python tools: Basic Pitch, WhackerHero, yt-dlp.
# 
# Note: Uses Python 3.11 to ensure binary wheels are available for numpy 1.23.x
#       (required by basic-pitch), avoiding build-from-source issues on newer Python.
#       The venv uses --system-site-packages to leverage system-installed packages.
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
echo "--- 📦 Installing System Dependencies (Python 3.11, ffmpeg, git) ---"

# First, ensure python3.11 is available
echo "   Installing Python 3.11..."
sudo dnf install -y python3.11

# Then install Python 3.11 packages and other dependencies
sudo dnf install -y \
    python3.11-devel \
    python3.11-pip \
    python3.11-numpy \
    python3.11-tkinter \
    ffmpeg \
    gcc \
    git \
    portaudio-devel \
    openh264

# Verify Python 3.11 is available
if ! command -v python3.11 &> /dev/null; then
    echo "   ❌ ERROR: Python 3.11 not found after installation."
    exit 1
fi
echo "   ✅ Python 3.11 is available: $(python3.11 --version)"

# --- Step 3: Create Python Virtual Environment ---
echo "--- 🐍 Setting up Python 3.11 Virtual Environment ---"
VENV_DIR="venv_boomwhacker"

if [ -d "$VENV_DIR" ]; then
    echo "   Virtual environment '$VENV_DIR' already exists."
    echo "   Removing it to recreate with Python 3.11..."
    rm -rf "$VENV_DIR"
fi

# Create venv with Python 3.11 and --system-site-packages to use system-installed packages
# (numpy, etc.) from dnf
python3.11 -m venv --system-site-packages "$VENV_DIR"
echo "   Created new venv at ./$VENV_DIR using Python 3.11 (with system-site-packages)"

# Activate the venv for the following commands
source "$VENV_DIR/bin/activate"

# Verify we're using Python 3.11
echo "   Python version in venv: $(python --version)"

# --- Step 4: Install Python Libraries ---
echo "--- 📥 Installing Python Packages ---"

# Upgrade pip and setuptools first
pip install --upgrade pip setuptools wheel

# Verify system numpy is available (installed via python3.11-numpy)
echo "   Verifying system numpy availability..."
python -c "import numpy; print(f'✅ System numpy {numpy.__version__} is available')" || {
    echo "   ⚠️  System numpy not found, will install via pip..."
}

# 1. yt-dlp (Downloading YouTube videos)
# 2. basic-pitch (Audio to MIDI)
# 3. whackerhero (The specific Boomwhacker generator tool)
#    Note: Installing directly from GitHub to ensure latest version
echo "   Installing yt-dlp, basic-pitch, and WhackerHero..."

# Install yt-dlp normally
pip install yt-dlp

# Install basic-pitch
# Python 3.11 has binary wheels for numpy 1.23.x, so this should work without building from source
echo "   Installing basic-pitch..."
pip install basic-pitch

# Install moviepy 1.x version
# WhackerHero - ins last years not maintained and requires 1.x version
pip install moviepy==1.0.3

# Installing WhackerHero from the source we found (allejok96/whackerhero)
# Using modern Direct URL requirement syntax instead of deprecated #egg= format
pip install "whackerhero @ git+https://github.com/allejok96/whackerhero.git"

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
