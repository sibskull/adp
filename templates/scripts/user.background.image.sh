#!/bin/sh

. adp-functions

# Set background image for user
LOCATION="$1"

# Copy image from location
IMAGE_PATH="$(xdg-user-dir PICTURES)/.background.${LOCATION##*.}"
adp_copy_file "$LOCATION" "$IMAGE_PATH"

gsettings set org.mate.background picture-filename "$IMAGE_PATH"
