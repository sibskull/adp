#!/bin/sh

. adp-functions

# Set user theme
THEME="$1"
ICON="$2"
PANEL_POSITION="$3" # top/bottom
WINDOW_DECORATION="$4"

gsettings set org.mate.interface gtk-theme "$THEME"
gsettings set org.mate.interface icon-theme "$ICON"
gsettings set org.mate.panel.toplevel:/org/mate/panel/toplevels/bottom/ orientation "$PANEL_POSITION"
gsettings set org.mate.Marco.general theme "$WINDOW_DECORATION"
