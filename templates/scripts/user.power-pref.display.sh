#!/bin/sh

. adp-functions

TIME="$1" # in seconds

gsettings set org.mate.power-manager sleep-display-ac $TIME
