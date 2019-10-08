#!/bin/sh

# On/off lock on activation the screensaver
STATE="$1"

[ "$STATE" = "true" ] && gsettings set org.mate.screensaver idle-activation-enabled true
gsettings set org.mate.screensaver lock-enabled "$STATE"
