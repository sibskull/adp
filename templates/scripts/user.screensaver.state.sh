#!/bin/sh

# On/off on activation the screensaver
STATE="$1"

gsettings set org.mate.screensaver idle-activation-enabled "$STATE"
