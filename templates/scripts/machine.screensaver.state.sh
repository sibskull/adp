#!/bin/sh

# On/off on activation the screensaver
SWITCH="$1" # true/false
SOURCE="true"

[ "$SWITCH" = "true" ] && SOURCE="false"

# Replace the value entered in line 9 (mate-screensaver-1.12.0)
# key name="idle-activation-enabled"
sed -i "9 s|$SOURCE|$SWITCH|" /usr/share/glib-2.0/schemas/org.mate.screensaver.gschema.xml
glib-compile-schemas /usr/share/glib-2.0/schemas
