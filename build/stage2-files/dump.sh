#!/bin/bash

# Create a function to save docker image
joinByChar() {
  local IFS="$1"
  shift
  echo "$*"
}

save_image() {
    local image_name=$1
    echo "dumping image $image_name"
    # Split the image name into parts based on /
    IFS='/' read -r -a name_parts <<< "$image_name"

    # Get the last part (this will be the filename)
    local filename="${name_parts[-1]}"

    # Get the directory path (all parts except the last one)
    #local directory_path="./${name_parts[*]:0:${#name_parts[@]}-1}"
    unset name_parts[-1]
    directory_path=$(joinByChar "/" "${name_parts[@]}")

    # Create directory for saving the image if it doesn't exist
    if [ -n "$directory_path" ]; then
        mkdir -p "$directory_path"
	directory_path="$directory_path/"
    fi

    # Save the docker image
    docker save -o "$directory_path$filename.tgz" "$image_name"
}

# Get all named local Docker images
docker images --format "{{.Repository}}:{{.Tag}}" | while read -r image; do
    # Call the save_image function
    save_image "$image"
done