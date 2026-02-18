# Boomwhackers Plugin for Claude Code

This plugin provides a skill for generating Boomwhacker play-along videos with AI-powered melody extraction and Guitar Hero-style falling notes visualization.

## Installation

This plugin is automatically loaded when working in the boomwhackers project directory.

## Skills Included

### `/boomwhackers` - Generate Play-Along Videos

Automatically activates when you ask Claude to:
- "Create boomwhacker video"
- "Generate boomwhacker playalong"
- "Make falling notes video"
- "Process with boomwhackers"

Or discuss creating educational play-along videos from audio/video files.

## Features

- AI-powered melody extraction using Spotify's Basic Pitch
- Guitar Hero-style falling notes with standard Boomwhacker colors
- Automatic key transposition to simple keys
- One-octave range for better visibility
- Enhanced note size (60% width) for easier viewing
- Support for YouTube URLs and local audio/video files
- Preview mode for testing (10 seconds)

## Quick Start

Simply ask Claude to:
- "Create a boomwhacker video from [YouTube URL]"
- "Generate a boomwhacker playalong for [file.mp3]"
- "Make a preview of [video] with boomwhackers"

Claude will automatically use the skill to help you generate the video.

## Manual Invocation

You can also invoke the skill directly:
```
/boomwhackers
```

## Examples

"Create a boomwhacker preview video from https://www.youtube.com/watch?v=..."

"Generate a boomwhacker playalong for my-song.mp3"

"Make falling notes visualization for this video file"

## Output

- **Full videos**: `Final_Boomwhacker_Video.mp4`
- **Previews**: `Preview_Boomwhacker_Video.mp4`

## Dependencies

- Python 3.10+ virtual environment (`venv_boomwhacker`)
- FFmpeg
- Basic Pitch (AI model)
- WhackerHero (visualization library)
- yt-dlp (for YouTube downloads)

All dependencies are installed via `./setup_env.sh`
