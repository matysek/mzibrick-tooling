#!/usr/bin/env python3

import os
import sys
import subprocess
import glob
import argparse
import statistics
from PIL import Image
import mido
from music21 import converter, key

def run_command(cmd, capture_output=False):
    """Helper to run shell commands and handle errors."""
    try:
        if capture_output:
            result = subprocess.run(cmd, shell=True, check=True, 
                                  capture_output=True, text=True)
            return result.stdout
        else:
            # Let output stream normally for real-time feedback
            subprocess.check_call(cmd, shell=True)
    except subprocess.CalledProcessError as e:
        print(f"\n❌ Command failed: {cmd}")
        raise

def get_nodejs_path():
    """Get Node.js executable path if available."""
    # Try common node executable names
    for node_cmd in ['node', 'nodejs']:
        try:
            result = subprocess.run(['which', node_cmd], 
                                   capture_output=True, text=True, check=True)
            node_path = result.stdout.strip()
            if node_path:
                return node_path
        except (subprocess.CalledProcessError, FileNotFoundError):
            continue
    return None

def get_input_files(user_input, work_dir):
    """
    Determines if input is URL or file. 
    Downloads from YT if needed.
    Returns: (path_to_video, path_to_audio)
    """
    video_path = ""
    audio_path = ""

    if user_input.startswith("http"):
        print(f"--- Downloading from YouTube: {user_input} ---")
        # Download Video (Best MP4)
        video_out = os.path.join(work_dir, "video_bg.mp4")
        # Use more flexible format selection
        # Explicitly specify Node.js as JS runtime if available
        node_path = get_nodejs_path()
        js_runtime_flag = f'--js-runtimes node:{node_path} ' if node_path else ""
        cmd_vid = (
            f'yt-dlp --no-warnings {js_runtime_flag}'
            f'-f "bestvideo[ext=mp4]+bestaudio[ext=m4a]/bestvideo+bestaudio/best[ext=mp4]/best" '
            f'-o "{video_out}" "{user_input}"'
        )
        try:
            run_command(cmd_vid)
            video_path = video_out
        except subprocess.CalledProcessError:
            print("\n⚠️  YouTube download failed. Possible reasons:")
            print("  1. Video may be unavailable (private, deleted, or region-locked)")
            print("  2. yt-dlp may need a JavaScript runtime (install nodejs or deno)")
            print("  3. Network connectivity issues")
            print("\nTo install a JS runtime for better YouTube support:")
            print("  - Node.js: Install via your package manager (e.g., 'dnf install nodejs')")
            print("  - Deno: See https://deno.land/")
            print("\nYou can also try downloading the video manually and providing the file path.")
            sys.exit(1)

        # Extract Audio (MP3) for Basic Pitch
        audio_out = os.path.join(work_dir, "audio_input.mp3")
        cmd_aud = f'ffmpeg -i "{video_out}" -vn -acodec libmp3lame -q:a 2 "{audio_out}" -y'
        run_command(cmd_aud)
        audio_path = audio_out

    else:
        print(f"--- Processing Local File: {user_input} ---")
        input_abs = os.path.abspath(user_input)
        
        # Check if input is video or audio
        mime_type = subprocess.check_output(f'file --mime-type -b "{input_abs}"', shell=True).decode().strip()
        
        if "video" in mime_type:
            video_path = input_abs
            # Extract audio
            audio_out = os.path.join(work_dir, "audio_input.mp3")
            cmd_aud = f'ffmpeg -i "{video_path}" -vn -acodec libmp3lame -q:a 2 "{audio_out}" -y'
            run_command(cmd_aud)
            audio_path = audio_out
        else:
            # It's just audio, no video background available
            audio_path = input_abs
            video_path = None # Will imply black background later

    return video_path, audio_path

def process_midi(midi_path, output_path):
    """
    Process MIDI file with key transposition and octave limiting.

    Args:
        midi_path: Path to input MIDI file
        output_path: Path to save processed MIDI file
    """
    print("--- Processing MIDI (Transposition & Octave Limiting) ---")

    # Define target keys (simplest keys for Boomwhackers)
    # Format: (key_name, semitone_value)
    target_keys = {
        'C major': 0,
        'G major': 7,
        'D major': 2,
        'A minor': 9,
        'E minor': 4,
        'B minor': 11
    }

    # Step 1: Detect key using music21
    try:
        score = converter.parse(midi_path)
        detected_key = score.analyze('key')
        detected_key_name = f"{detected_key.tonic.name} {detected_key.mode}"

        # Map detected key to semitone value
        key_to_semitone = {
            'C': 0, 'C#': 1, 'D-': 1, 'D': 2, 'D#': 3, 'E-': 3, 'E': 4,
            'F': 5, 'F#': 6, 'G-': 6, 'G': 7, 'G#': 8, 'A-': 8, 'A': 9,
            'A#': 10, 'B-': 10, 'B': 11
        }
        detected_semitone = key_to_semitone.get(detected_key.tonic.name, 0)

        # Find closest target key
        min_distance = 12
        best_target_name = 'C major'
        best_target_semitone = 0

        for target_name, target_semitone in target_keys.items():
            # Calculate distance (considering circular nature of semitones)
            distance = (target_semitone - detected_semitone) % 12
            if distance > 6:
                distance = 12 - distance

            if distance < min_distance:
                min_distance = distance
                best_target_name = target_name
                best_target_semitone = target_semitone

        # Calculate transposition
        transpose_semitones = (best_target_semitone - detected_semitone) % 12
        if transpose_semitones > 6:
            transpose_semitones -= 12

        print(f"   Detected key: {detected_key_name}")
        print(f"   Transposing to: {best_target_name} ({transpose_semitones:+d} semitones)")

    except Exception as e:
        print(f"   ⚠️  Key detection failed: {e}")
        print("   Proceeding without transposition...")
        transpose_semitones = 0

    # Step 2: Load MIDI with mido and transpose
    mid = mido.MidiFile(midi_path)

    # Collect all notes for octave analysis
    all_notes = []
    for track in mid.tracks:
        for msg in track:
            if msg.type == 'note_on' and msg.velocity > 0:
                all_notes.append(msg.note)

    if not all_notes:
        print("   ⚠️  No notes found in MIDI file")
        # Just copy the file
        mid.save(output_path)
        return

    # Step 3: Calculate 1-octave window
    median_pitch = statistics.median(all_notes)
    # Center the 1-octave window (12 semitones) around median
    window_min = int(median_pitch - 6)
    window_max = int(median_pitch + 6)

    # Get note names for display
    note_names = ['C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B']
    min_note_name = note_names[window_min % 12] + str(window_min // 12 - 1)
    max_note_name = note_names[window_max % 12] + str(window_max // 12 - 1)

    print(f"   Restricting notes to range: {min_note_name} ({window_min}) to {max_note_name} ({window_max})")

    # Step 4: Apply transposition and octave limiting
    for track in mid.tracks:
        for msg in track:
            if msg.type in ('note_on', 'note_off'):
                # Apply transposition
                msg.note += transpose_semitones

                # Apply octave limiting
                while msg.note < window_min:
                    msg.note += 12
                while msg.note > window_max:
                    msg.note -= 12

                # Clamp to valid MIDI range (0-127)
                msg.note = max(0, min(127, msg.note))

    # Save processed MIDI
    mid.save(output_path)
    print(f"   Processed MIDI saved: {output_path}")

def trim_audio(input_path, output_path, duration_seconds=10):
    """
    Extract first N seconds of audio using FFmpeg.

    Args:
        input_path: Path to input audio file
        output_path: Path to save trimmed audio
        duration_seconds: Duration to extract (default 10 seconds)
    """
    cmd = f'ffmpeg -i "{input_path}" -t {duration_seconds} -acodec copy "{output_path}" -y'
    run_command(cmd)
    print(f"   Trimmed audio to {duration_seconds} seconds: {output_path}")

def process_video(user_input, work_dir, preview_mode=False, output_filename=None):
    """
    Process a video or audio file to create a Boomwhacker play-along video.

    Args:
        user_input: YouTube URL or file path
        work_dir: Working directory for temporary files
        preview_mode: If True, process only first 10 seconds
        output_filename: Custom output filename (optional)

    Returns:
        Path to the generated video file
    """
    # 1. Get Video and Audio
    video_bg, audio_input = get_input_files(user_input, work_dir)

    # If preview mode, trim the audio to 10 seconds
    if preview_mode:
        print("--- Preview Mode: Processing first 10 seconds ---")
        audio_preview = os.path.join(work_dir, "audio_preview.mp3")
        trim_audio(audio_input, audio_preview, duration_seconds=10)
        audio_to_process = audio_preview
    else:
        audio_to_process = audio_input

    # 2. Audio to MIDI (Basic Pitch)
    print("--- Converting Audio to MIDI (Basic Pitch) ---")
    # basic-pitch command: basic-pitch <output_dir> <input_audio>
    run_command(f'basic-pitch "{work_dir}" "{audio_to_process}"')

    # Find the generated MIDI file (name is unpredictable)
    midi_files = glob.glob(os.path.join(work_dir, "*.mid"))
    if not midi_files:
        print("Error: MIDI generation failed.")
        sys.exit(1)
    midi_file = midi_files[0]
    print(f"MIDI Generated: {midi_file}")

    # 3. Process MIDI (Transpose and Limit Octaves)
    processed_midi = os.path.join(work_dir, "processed.mid")
    process_midi(midi_file, processed_midi)

    # 4. Generate WhackerHero Video (Black Background)
    print("--- Generating Boomwhacker Visuals ---")

    # Create a pure black image for WhackerHero background
    bg_image_path = os.path.join(work_dir, "black_bg.jpg")
    img = Image.new('RGB', (1920, 1080), color = 'black')
    img.save(bg_image_path)

    whacker_output = os.path.join(work_dir, "whacker_layer.mp4")

    # Run whackercmd
    # Syntax: whackercmd -a <audio> -i <image> <midi> <output>
    # Note: We use the extracted audio to ensure sync
    run_command(f'whackercmd -a "{audio_to_process}" -i "{bg_image_path}" "{processed_midi}" "{whacker_output}"')

    # 5. Composite (Overlay)
    if output_filename is None:
        output_filename = "Preview_Boomwhacker_Video.mp4" if preview_mode else "Final_Boomwhacker_Video.mp4"

    print("--- Compositing Final Video ---")

    if video_bg:
        print("Overlaying Boomwhackers on top of original video...")
        # Complex Filter Explanation:
        # [0:v] -> Input 0 (Background Video)
        # [1:v] -> Input 1 (Whacker Video with Black BG)
        # colorkey=0x000000 -> Makes black pixels transparent, preserving original colors
        cmd_combine = (
            f'ffmpeg -i "{video_bg}" -i "{whacker_output}" '
            f'-filter_complex "[0:v]scale=1920:1080:force_original_aspect_ratio=decrease,pad=1920:1080:(ow-iw)/2:(oh-ih)/2[bg];'
            f'[1:v]colorkey=0x000000:similarity=0.01:blend=0.0,scale=1920:1080[fg];'
            f'[bg][fg]overlay=shortest=1[out]" '
            f'-map "[out]" -map 0:a -c:v libx264 -crf 23 -preset fast "{output_filename}" -y'
        )
        run_command(cmd_combine)
    else:
        print("No video background detected. Saving WhackerHero output directly.")
        import shutil
        shutil.copy(whacker_output, output_filename)

    return output_filename

def main():
    # Parse command-line arguments
    parser = argparse.ArgumentParser(
        description='Generate Boomwhacker play-along videos from YouTube URLs or local files',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog='''
Examples:
  %(prog)s "https://youtube.com/watch?v=..."
  %(prog)s /path/to/song.mp3
  %(prog)s --preview "https://youtube.com/watch?v=..."
        '''
    )
    parser.add_argument('input', help='YouTube URL or path to local audio/video file')
    parser.add_argument('-p', '--preview', action='store_true',
                        help='Generate a 10-second preview before processing the full video')

    args = parser.parse_args()

    # Create a temporary workspace
    work_dir = "bw_project_temp"
    if not os.path.exists(work_dir):
        os.makedirs(work_dir)

    if args.preview:
        # Generate preview
        print("\n========== GENERATING PREVIEW ==========")
        preview_output = process_video(args.input, work_dir, preview_mode=True)
        print(f"\n--- Preview generated: {preview_output} ---")

        # Ask user if they want to continue
        while True:
            response = input("\nContinue with full video? (y/n): ").strip().lower()
            if response in ['y', 'yes']:
                print("\n========== GENERATING FULL VIDEO ==========")
                # Clean up MIDI files from preview
                for midi_file in glob.glob(os.path.join(work_dir, "*.mid")):
                    os.remove(midi_file)
                final_output = process_video(args.input, work_dir, preview_mode=False)
                print(f"\n--- Done! Saved as {final_output} ---")
                break
            elif response in ['n', 'no']:
                print(f"\nPreview saved as {preview_output}")
                print("Exiting without generating full video.")
                break
            else:
                print("Please enter 'y' or 'n'")
    else:
        # Process full video directly
        final_output = process_video(args.input, work_dir, preview_mode=False)
        print(f"\n--- Done! Saved as {final_output} ---")

    print(f"To clean up temp files, run: rm -rf {work_dir}")

if __name__ == "__main__":
    main()