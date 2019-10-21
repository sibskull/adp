#!/bin/sh

STATUS="$1" # never/low/charge/present/always

# Replace the value entered in line 339 (mate-power-manager-1.12.1)
# key name="icon-policy"
sed -i "339 s|>.*<|>'$STATUS'<|" /usr/share/glib-2.0/schemas/org.mate.power-manager.gschema.xml
glib-compile-schemas /usr/share/glib-2.0/schemas
