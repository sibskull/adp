#!/bin/sh

# Set screensaver mode/theme
MODE="$1" # blank-only/random/single
THEME="$2"

gsettings set org.mate.screensaver mode $MODE
[ "$MODE" = "single" ] && gsettings set org.mate.screensaver themes "['$THEME']"
