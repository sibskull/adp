#!/bin/sh

. adp-functions

# Set the screen resolution and the refresh rate of the monitor for user
RESOLUTION="$1" # 1920x1080
RATE="$2" # 75.00
ROTATE="$3" # left/right/normal/inverted
OUTPUT="$4" # monitor output (HDMA1/VGA1/DVI1/LVDS1)

if [ "x$OUTPUT" == "x" ]; then
  OUTPUT=""
else
  OUTPUT="--output $OUTPUT"
fi

# Set the screen resolution on startup
sed -i '/^xrandr.*/d' $HOME/.xprofile # remove old record
echo "xrandr -s $RESOLUTION -r $RATE -o $ROTATE $OUTPUT" >> $HOME/.xprofile
