#!/bin/sh

. adp-functions

LOGIN="$1"; shift #account name
GROUPS="$*" #groups list

for group in $GROUPS; do
    gpasswd -d $LOGIN $group
done
