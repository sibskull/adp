#!/bin/sh

. adp-functions

STATUS="$1" # client/always/never

gsettings set org.gnome.Vino icon-visibility $STATUS
