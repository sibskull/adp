#!/bin/sh

. adp-functions

STATUS="$1" # never/low/charge/present/always

gsettings set org.mate.power-manager icon-policy $STATUS
