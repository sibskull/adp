#!/bin/sh

TIME="$1" # in seconds

# Replace the value entered in line 305 (mate-power-manager-1.12.1)
# key name="sleep-computer-ac"
sed -i "305 s|>.*<|>$TIME<|" /usr/share/glib-2.0/schemas/org.mate.power-manager.gschema.xml
glib-compile-schemas /usr/share/glib-2.0/schemas
