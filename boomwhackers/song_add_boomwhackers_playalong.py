import os
import sys
import subprocess
import glob
from PIL import Image

def run_command(cmd):
    """Helper to run shell commands and handle errors."""
    try:
        subprocess.check_call(cmd, shell=True)
    except subprocess.CalledProcessError as e:
        print(f"Error running command: {cmd}")
        sys.exit(1)

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
        cmd_vid = f'yt-dlp -f "bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]" -o "{video_out}" "{user_input}"'
        run_command(cmd_vid)
        video_path = video_out

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

def main():
    if len(sys.argv) < 2:
        print("Usage: python3 boom_gen.py <YouTube_URL_or_File_Path>")
        sys.exit(1)

    user_input = sys.argv[1]
    
    # Create a temporary workspace
    work_dir = "bw_project_temp"
    if not os.path.exists(work_dir):
        os.makedirs(work_dir)

    # 1. Get Video and Audio
    video_bg, audio_input = get_input_files(user_input, work_dir)

    # 2. Audio to MIDI (Basic Pitch)
    print("--- Converting Audio to MIDI (Basic Pitch) ---")
    # basic-pitch command: basic-pitch <output_dir> <input_audio>
    run_command(f'basic-pitch "{work_dir}" "{audio_input}"')
    
    # Find the generated MIDI file (name is unpredictable)
    midi_files = glob.glob(os.path.join(work_dir, "*.mid"))
    if not midi_files:
        print("Error: MIDI generation failed.")
        sys.exit(1)
    midi_file = midi_files[0]
    print(f"MIDI Generated: {midi_file}")

    # 3. Generate WhackerHero Video (Black Background)
    print("--- Generating Boomwhacker Visuals ---")
    
    # Create a pure black image for WhackerHero background
    bg_image_path = os.path.join(work_dir, "black_bg.jpg")
    img = Image.new('RGB', (1920, 1080), color = 'black')
    img.save(bg_image_path)

    whacker_output = os.path.join(work_dir, "whacker_layer.mp4")
    
    # Run whackercmd
    # Syntax: whackercmd -a <audio> -i <image> <midi> <output>
    # Note: We use the extracted audio to ensure sync
    run_command(f'whackercmd -a "{audio_input}" -i "{bg_image_path}" "{midi_file}" "{whacker_output}"')

    # 4. Composite (Overlay)
    final_output = "Final_Boomwhacker_Video.mp4"
    print("--- Compositing Final Video ---")

    if video_bg:
        print("Overlaying Boomwhackers on top of original video...")
        # Complex Filter Explanation:
        # [0:v] -> Input 0 (Background Video)
        # [1:v] -> Input 1 (Whacker Video with Black BG)
        # blend=all_mode='screen' -> Makes black pixels transparent, keeps colored bars
        cmd_combine = (
            f'ffmpeg -i "{video_bg}" -i "{whacker_output}" '
            f'-filter_complex "[0:v]scale=1920:1080:force_original_aspect_ratio=decrease,pad=1920:1080:(ow-iw)/2:(oh-ih)/2[bg];'
            f'[1:v]scale=1920:1080[fg];'
            f'[bg][fg]blend=all_mode=\'screen\':shortest=1[out]" '
            f'-map "[out]" -map 0:a -c:v libx264 -crf 23 -preset fast "{final_output}" -y'
        )
        run_command(cmd_combine)
    else:
        print("No video background detected. Saving WhackerHero output directly.")
        os.rename(whacker_output, final_output)

    # 5. Cleanup
    print(f"--- Done! Saved as {final_output} ---")
    print(f"To clean up temp files, run: rm -rf {work_dir}")

if __name__ == "__main__":
    main()