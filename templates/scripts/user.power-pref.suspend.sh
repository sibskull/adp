#!/bin/sh

. adp-functions

ACTION="$1" # nothing/suspend/hibernate

gsettings set org.mate.power-manager button-suspend $ACTION
