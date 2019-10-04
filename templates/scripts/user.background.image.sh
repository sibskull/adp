#!/bin/sh

. bin/adp-functions

# Set background image for user
IMAGE="$1"
LOCATION="$2"

# Copy image from location
IMAGE_PATH="$(xdg-user-dir PICTURES)/.$IMAGE"
adp_copy_file "$LOCATION" "$IMAGE" "$IMAGE_PATH"

gsettings set org.mate.background picture-filename "$IMAGE_PATH"
