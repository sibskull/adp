#!/bin/sh

. adp-functions

CASE="$1" # true/false

timedatectl set-NTP $CASE
