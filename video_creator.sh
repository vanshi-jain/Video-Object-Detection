#!/bin/bash

# Check if the directory argument is provided
if [ -z "$1" ]; then
  echo "Usage: create_clips.sh <directory_with_images>"
  exit 1
fi

# Directory containing the images
input_dir="$1"
# Ensure the directory exists
if [ ! -d "$input_dir" ]; then
  echo "Error: Directory '$input_dir' does not exist."
  exit 1
fi

# Total number of images (count files matching pattern)
total_images=$(ls "$input_dir"/rgb_*.jpg 2>/dev/null | wc -l)
if [ "$total_images" -eq 0 ]; then
  echo "Error: No images matching 'rgb_*.jpg' found in directory '$input_dir'."
  exit 1
fi

# Images per video clip
images_per_clip=50
# Frame rate
frame_rate=10

# Get the base name of the current folder (e.g., "Camera_0")
camera_name=$(basename "$input_dir")
# Get the name of the parent folder (e.g., "morning")
scene_name=$(basename "$(dirname "$(dirname "$(dirname "$input_dir")")")")
# Define the output folder
output_folder="$(dirname "$(dirname "$(dirname "$input_dir")")")/videos"

mkdir -p "$output_folder"

# Loop through batches of images
for ((i=0; i<$total_images; i+=$images_per_clip)); do
  # Determine the start and end range of images for the current clip
  start=$(printf "%05d" $((i))) # Start index, padded with zeros

  # Generate output filename
  clip_number=$(printf "%05d" $((i / $images_per_clip + 1)))
  output_file="${output_folder}/${scene_name}_${camera_name}_clip_${clip_number}.mp4"

  # Create the video for the current batch
  ffmpeg -framerate $frame_rate -start_number $start -i "$input_dir/rgb_%05d.jpg" \
         -vframes $images_per_clip -vf "scale=trunc(iw/2)*2:trunc(ih/2)*2" -c:v libx264 -pix_fmt yuv420p $output_file

done
