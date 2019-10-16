#!/bin/sh

. adp-functions

STATUS="$1" # client/always/never

# Replace the value entered in line 128 (vino-mate)
# key name='icon-visibility'
sed -i "128 s|>.*<|>'$STATUS'<|" /usr/share/glib-2.0/schemas/org.gnome.Vino.gschema.xml
glib-compile-schemas /usr/share/glib-2.0/schemas
