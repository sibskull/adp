#!/bin/sh

ACTION="$1" # nothing/suspend/hibernate/shutdown/interactive

# Replace the value entered in line 135 (mate-power-manager-1.12.1)
# key name="button-power"
sed -i "135 s|>.*<|>'$ACTION'<|" /usr/share/glib-2.0/schemas/org.mate.power-manager.gschema.xml
glib-compile-schemas /usr/share/glib-2.0/schemas
