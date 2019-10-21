#!/bin/sh

ACTION="$1" # nothing/suspend/hibernate

# Replace the value entered in line 125 (mate-power-manager-1.12.1)
# key name="button-suspend"
sed -i "125 s|>.*<|>'$ACTION'<|" /usr/share/glib-2.0/schemas/org.mate.power-manager.gschema.xml
glib-compile-schemas /usr/share/glib-2.0/schemas
