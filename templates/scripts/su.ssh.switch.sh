#!/bin/sh

. adp-functions

SWITCH="$1" # true/false

if $SWITCH=true {systemctl start sshd}
else {systemctl stop sshd}
fi
