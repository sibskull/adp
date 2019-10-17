#!/bin/sh

. adp-functions

SWITCH="$1" # true/false
SOURCE="false"

[ "$SWITCH" = false ] && SOURCE="true"

# Replace the value entered in line 146 (vino-mate)
# key name='use-upnp'
sed -i "146 s|$SOURCE|$SWITCH|" /usr/share/glib-2.0/schemas/org.gnome.Vino.gschema.xml
glib-compile-schemas /usr/share/glib-2.0/schemas
