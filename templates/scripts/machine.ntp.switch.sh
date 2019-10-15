#!/bin/sh

. adp-functions

SWITCH="$1" # true/false

timedatectl set-ntp "$SWITCH"
