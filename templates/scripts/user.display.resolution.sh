#!/bin/sh

. adp-functions

# Set the screen resolution and the refresh rate of the monitor for user
RESOLUTION="$1" # 1920x1080
RATE="$2" # 75.00
ROTATE="$3" # left/right/normal/inverted
OUTPUT="$4" # monitor output (HDMA1/VGA1/DVI1/LVDS1)

# Set the screen resolution on startup
echo "xrandr -s $RESOLUTION -r $RATE -o $ROTATE --output $OUTPUT" >> "$HOME"/.xprofile
