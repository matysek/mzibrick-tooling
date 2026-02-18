---
name: boomwhackers
description: This skill should be used when the user asks to "create boomwhacker video", "generate boomwhacker playalong", "make falling notes video", "process with boomwhackers", mentions "boomwhacker visualization", or discusses creating play-along videos from audio/video files.
version: 1.0.0
---

# Boomwhackers Play-Along Video Generator

This skill helps generate Boomwhacker play-along videos with Guitar Hero-style falling notes using AI-powered melody extraction.

## Overview

The boomwhackers script automates the creation of play-along videos by:
1. Extracting audio from YouTube videos or local files
2. Converting audio to MIDI using AI (Spotify's Basic Pitch)
3. Processing MIDI to fit within one octave for better visibility
4. Generating colored falling notes visualization
5. Overlaying the visualization on the original video

## When to Use This Skill

Use this skill when the user wants to:
- Create a boomwhacker play-along video from a YouTube URL
- Generate falling notes visualization from a local audio/video file
- Process music for educational purposes with visual note guidance
- Create preview videos (first 10 seconds only)

## Prerequisites

Before running the boomwhackers script:
1. The virtual environment must be activated
2. The whackerhero patch should be applied for better visibility

## Commands

### Generate Full Video

```bash
cd /var/home/mzibrick/Projects/personal/mzibrick-tooling/boomwhackers
source venv_boomwhacker/bin/activate
python3 song_add_boomwhackers_playalong.py "INPUT_PATH_OR_URL"
```

### Generate Preview (10 seconds)

```bash
cd /var/home/mzibrick/Projects/personal/mzibrick-tooling/boomwhackers
source venv_boomwhacker/bin/activate
python3 song_add_boomwhackers_playalong.py --preview "INPUT_PATH_OR_URL"
```

### Apply WhackerHero Patch (if needed)

```bash
cd /var/home/mzibrick/Projects/personal/mzibrick-tooling/boomwhackers
./apply-whackerhero-patch.sh
```

## Input Types

1. **YouTube URL**:
   - Example: `"https://www.youtube.com/watch?v=dQw4w9WgXcQ"`
   - Downloads video and audio automatically

2. **Local File**:
   - Example: `"/path/to/song.mp3"` or `"./video.webm"`
   - Supports audio (.mp3, .wav, .m4a) and video (.mp4, .webm, .avi) formats

## Output

- **Full video**: `Final_Boomwhacker_Video.mp4`
- **Preview**: `Preview_Boomwhacker_Video.mp4`
- **Temporary files**: Stored in `bw_project_temp/` (can be deleted after)

## Features and Customizations

### Enhanced Visibility
This setup includes two customizations for better visibility:

1. **Bigger Notes**: Note width increased from 30% to 60% of column width
2. **One-Octave Range**: Notes limited to 12 semitones instead of 24 semitones
   - Fewer columns = more space per note
   - All notes are octave-transposed to fit within the range

### Color Scheme
Standard Boomwhacker Chroma-Notes colors:
- C: Red, C#: Orange, D: Orange-yellow, D#: Yellow
- E: Yellow, F: Yellow-green, F#: Green, G: Cyan
- G#: Blue, A: Purple, A#: Purple-pink, B: Magenta

### Processing Pipeline
1. **Audio Extraction**: Downloads or reads local file
2. **MIDI Conversion**: Uses Spotify's Basic Pitch AI model
3. **Key Detection**: Transposes to simple keys (C, G, D, A, E, or B major/minor)
4. **Octave Normalization**: Centers notes around median pitch within 1-octave window
5. **Visualization**: Generates falling notes with WhackerHero
6. **Compositing**: Overlays on original video (or black background for audio files)

## Common Workflows

### Quick Preview
When user wants to test before generating full video:
```bash
python3 song_add_boomwhackers_playalong.py --preview "INPUT"
```
This processes only the first 10 seconds and prompts whether to continue with full video.

### Direct Full Generation
When user is confident about the input:
```bash
python3 song_add_boomwhackers_playalong.py "INPUT"
```

### Batch Processing
For multiple files, run the script in a loop:
```bash
for file in *.mp3; do
    python3 song_add_boomwhackers_playalong.py "$file"
done
```

## Troubleshooting

### Virtual Environment Not Activated
If commands fail with "command not found":
```bash
source venv_boomwhacker/bin/activate
```

### MoviePy Module Error
If you see `ModuleNotFoundError: No module named 'moviepy.editor'`:
```bash
pip uninstall moviepy
pip install moviepy==1.0.3
```

### Patch Not Applied
If notes appear small, apply the patch:
```bash
./apply-whackerhero-patch.sh
```

### MIDI Generation Failed
Basic Pitch requires clear melodic content. If MIDI generation fails:
- Try a different section of the audio
- Ensure audio quality is good
- Check that the file isn't corrupted

## Files and Locations

- **Main Script**: `song_add_boomwhackers_playalong.py`
- **Setup Script**: `setup_env.sh`
- **Patch Script**: `apply-whackerhero-patch.sh`
- **Patch File**: `whackerhero-bigger-notes.patch`
- **Virtual Environment**: `venv_boomwhacker/`
- **Temp Directory**: `bw_project_temp/`
- **WhackerHero Library**: `venv_boomwhacker/lib/python3.11/site-packages/whackerhero.py`

## Best Practices

1. **Always use preview mode first** for new content
2. **Keep source files** in case you need to regenerate
3. **Clean up temp directory** periodically to save disk space
4. **Use descriptive filenames** if processing multiple videos
5. **Activate virtual environment** at the start of each session

## Example Usage

### Example 1: YouTube Video
```bash
cd /var/home/mzibrick/Projects/personal/mzibrick-tooling/boomwhackers
source venv_boomwhacker/bin/activate
python3 song_add_boomwhackers_playalong.py --preview "https://www.youtube.com/watch?v=VIDEO_ID"
# Review Preview_Boomwhacker_Video.mp4, then decide whether to generate full video
```

### Example 2: Local Audio File
```bash
cd /var/home/mzibrick/Projects/personal/mzibrick-tooling/boomwhackers
source venv_boomwhacker/bin/activate
python3 song_add_boomwhackers_playalong.py "mysong.mp3"
# Output: Final_Boomwhacker_Video.mp4 with notes on black background
```

### Example 3: Local Video File
```bash
cd /var/home/mzibrick/Projects/personal/mzibrick-tooling/boomwhackers
source venv_boomwhacker/bin/activate
python3 song_add_boomwhackers_playalong.py "myvideo.webm"
# Output: Final_Boomwhacker_Video.mp4 with notes overlaid on original video
```

## Implementation Details

When helping users with this skill:

1. **Always check if in correct directory** before running commands
2. **Always activate virtual environment** first
3. **Use preview mode** unless user specifically asks for full video
4. **Provide full paths** or explain relative paths clearly
5. **Mention output filename** so user knows what to look for
6. **Suggest cleanup** of temp files after successful generation
7. **If first time use**, recommend applying the patch for better visibility
