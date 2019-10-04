#!/bin/sh

. bin/adp-functions

SWITCH="$1" # true/false
SOURCE="true"

[ "$SWITCH" = true ] && SOURCE="false"

# Replace the value entered in line 10 (vino-mate)
sed -i "10 s|$SOURCE|$SWITCH|" /usr/share/glib-2.0/schemas/org.gnome.Vino.gschema.xml
glib-compile-schemas /usr/share/glib-2.0/schemas
