#!/bin/sh

# Set screensaver mode/theme
MODE="$1" # blank-only/random/single
THEME="$2"

# Replace the value entered (mate-screensaver-1.12.0)
# key name="mode"
sed -i "19 s|>.*<|>'$MODE'<|" /usr/share/glib-2.0/schemas/org.mate.screensaver.gschema.xml
# key name="themes"
sed -i "24 s|>.*<|>['$THEME']<|" /usr/share/glib-2.0/schemas/org.mate.screensaver.gschema.xml

glib-compile-schemas /usr/share/glib-2.0/schemas
