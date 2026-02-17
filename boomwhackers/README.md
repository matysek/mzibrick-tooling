# Boomwhackers Play-Along Generator

This tool automates the creation of **Boomwhackers play-along videos**. It takes a YouTube video (or local audio file), uses AI to extract the melody as MIDI, generates a falling-note visualization using the standard Chroma-Notes color scheme, and overlays it onto the original video.

Designed for **Fedora Silverblue** (using Toolbox) but works on any standard Linux distribution.

## Features

* **YouTube Integration:** Downloads video and audio automatically using `yt-dlp`.
* **AI Transcription:** Converts audio to MIDI using Spotify's **Basic Pitch** model.
* **Visualization:** Generates "Guitar Hero" style falling notes with correct Boomwhacker colors.
* **compositing:** Overlays the notes onto the original video using FFmpeg (Screen Blend Mode) for a professional look.

## Prerequisites

* **Python 3.10+**
* **FFmpeg** (for video processing)
* **Toolbox** (Required for Fedora Silverblue / Kinoite users)

## Installation

### 1. Setup Environment

It is recommended to run this inside a Toolbox container to keep your system clean.

```bash
# Enter your toolbox (Silverblue users)
toolbox enter

# Clone the repository
git clone https://github.com/matysek/mzibrick-tooling.git
cd mzibrick-tooling/boomwhackers

```

### 2. Install Dependencies

Run the provided setup script. This installs system packages (ffmpeg, portaudio) and creates a Python virtual environment.

```bash
chmod +x setup_env.sh
./setup_env.sh

```

### 3. Activate Virtual Environment

```bash
source venv_boomwhacker/bin/activate

```

> **Note:** If you encounter a `ModuleNotFoundError: No module named 'moviepy.editor'` error, run:
> ```bash
> pip uninstall moviepy
> pip install moviepy==1.0.3
> 
> ```
> 
> 

## Usage

### Process a YouTube Video

This downloads the video, generates the play-along notes, and overlays them on top of the original video.

```bash
python3 song_add_boomwhackers_playalong.py "https://www.youtube.com/watch?v=dQw4w9WgXcQ"

```

### Process a Local File

If you provide a local audio file, it will generate the visualization on a black background.

```bash
python3 song_add_boomwhackers_playalong.py "/path/to/mysong.mp3"

```

## Output

The final video will be saved in the current directory as:

* `Final_Boomwhacker_Video.mp4`

(Temporary files are stored in `bw_project_temp/` and can be deleted after generation).

## Credits

* **[Basic Pitch](https://github.com/spotify/basic-pitch):** Audio-to-MIDI conversion.
* **[WhackerHero](https://github.com/allejok96/whackerhero):** Boomwhacker visualization tool.
* **[yt-dlp](https://github.com/yt-dlp/yt-dlp):** Media downloader.