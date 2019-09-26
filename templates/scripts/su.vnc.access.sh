#!/bin/sh

. adp-functions

SWITCH="$1" # true/false

# Replace the value entered in line 22
sed "22 s|false|$SWITCH|" /usr/share/glib-2.0/schemas/org.gnome.Vino.gschema.xml
#sed " s||$SWITCH|" /usr/share/vino/vino-preferences.ui
