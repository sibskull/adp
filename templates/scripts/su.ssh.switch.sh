#!/bin/sh

. adp-functions

SWITCH="$1" # true/false

if [ "$SWITCH" = true ]; then
	systemctl start sshd
else
	systemctl stop sshd
fi
