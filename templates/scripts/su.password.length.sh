#!/bin/sh

. adp-functions

LENGTH="$1" # minimum password length

echo "minlen = $LENGTH" >> /etc/security/pwquality.conf
# /etc/passwdqc.conf
# Можно ли сделать через libpasswdqc?
