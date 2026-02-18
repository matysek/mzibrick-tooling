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

### 4. Apply WhackerHero Patch (Recommended)

For better visibility, apply the patch that makes boomwhacker notes bigger:

```bash
./apply-whackerhero-patch.sh

```

This patch increases the note width from 30% to 60% of column width for much better visibility.

> **Note:** If you encounter a `ModuleNotFoundError: No module named 'moviepy.editor'` error, run:
> ```bash
> pip uninstall moviepy
> pip install moviepy==1.0.3
>
> ```
>
>

## Usage

### Using Claude Code Skill (Recommended)

If you're using Claude Code CLI, you can simply ask Claude to generate videos:

```
"Create a boomwhacker video from https://www.youtube.com/watch?v=..."
"Generate a boomwhacker preview for my-song.mp3"
```

Claude will automatically use the `/boomwhackers` skill to help you. The skill is automatically loaded when working in this directory.

### Manual Usage

#### Process a YouTube Video

This downloads the video, generates the play-along notes, and overlays them on top of the original video.

```bash
python3 song_add_boomwhackers_playalong.py "https://www.youtube.com/watch?v=dQw4w9WgXcQ"

```

#### Process a Local File

If you provide a local audio file, it will generate the visualization on a black background.

```bash
python3 song_add_boomwhackers_playalong.py "/path/to/mysong.mp3"

```

#### Preview Mode (10 seconds)

Test with a preview before generating the full video:

```bash
python3 song_add_boomwhackers_playalong.py --preview "INPUT_PATH_OR_URL"

```

## Output

The final video will be saved in the current directory as:

* `Final_Boomwhacker_Video.mp4`

(Temporary files are stored in `bw_project_temp/` and can be deleted after generation).

## Claude Code Integration

This project includes a Claude Code plugin (`.claude/plugins/boomwhackers-plugin/`) that provides the `/boomwhackers` skill. When using Claude Code CLI in this directory, simply ask Claude to create boomwhacker videos and it will automatically help you with the correct commands and workflow.

## Customizations

This repository includes customizations for improved visibility:

### 1. Bigger Notes (WhackerHero Patch)
- A patch file (`whackerhero-bigger-notes.patch`) increases note width from 30% to 60%
- Apply with: `./apply-whackerhero-patch.sh`
- Reapply if you recreate the virtual environment

### 2. One-Octave Range
- Modified `song_add_boomwhackers_playalong.py` to limit notes to 1 octave (±6 semitones) instead of 2 octaves (±12 semitones)
- This reduces the number of columns, giving each note more horizontal space
- Results in clearer, more readable visualizations

## Credits

* **[Basic Pitch](https://github.com/spotify/basic-pitch):** Audio-to-MIDI conversion.
* **[WhackerHero](https://github.com/allejok96/whackerhero):** Boomwhacker visualization tool.
* **[yt-dlp](https://github.com/yt-dlp/yt-dlp):** Media downloader.