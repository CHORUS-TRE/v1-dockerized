#!/bin/bash

# Create a function to load docker image
load_image() {
    local image_path=$1

    echo "loading image $image_path"
    # Load the docker image
    docker load -i "$image_path"
}

# Function to find and load all .tgz files in a directory recursively
load_images_from_directory() {
    local directory=$1

    # Find all .tgz files in the directory and load them
    find "$directory" -type f -name "*.tgz" | while read -r image_path; do
        load_image "$image_path"
    done
}

# Check if directory is provided as argument
if [ $# -eq 0 ]; then
    echo "Please provide a directory to load images from."
    exit 1
fi

# Call the load_images_from_directory function
load_images_from_directory "$1"