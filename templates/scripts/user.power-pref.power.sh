#!/bin/sh

. adp-functions

ACTION="$1" # nothing/suspend/hibernate/shutdown/interactive

gsettings set org.mate.power-manager button-power $ACTION
