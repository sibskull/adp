#!/bin/sh

. bin/adp-functions

LENGTH="$1" # minimum password length

#echo "minlen = $LENGTH" >> /etc/security/pwquality.conf
sed -i "s|min=disabled,24,11,8,7|min=disabled,$LENGTH,$LENGTH,$LENGTH,$LENGTH|" /etc/passwdqc.conf
