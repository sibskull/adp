#!/bin/sh

. adp-functions

ADDRESS="$1"

timedatectl --host="$ADDRESS"
