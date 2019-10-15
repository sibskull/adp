#!/bin/sh

. adp-functions

# minimum password length
LENGTH1="$1"
LENGTH2="$2"
LENGTH3="$3"
LENGTH4="$4"
LENGTH5="$5"

#echo "minlen = $LENGTH" >> /etc/security/pwquality.conf
sed "s|min=.*|min=$LENGTH1,$LENGTH2,$LENGTH3,$LENGTH4,$LENGTH5" /etc/passwdqc.conf
