#!/bin/sh

. adp-functions

SWITCH="$1" # true/false

gsettings set org.gnome.Vino view-only $SWITCH
