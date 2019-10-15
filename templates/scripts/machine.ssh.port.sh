#!/bin/sh

. adp-functions

PORT="$1" # the port number

conf="/etc/openssh/sshd_config"

if (grep -ru "^#Port" $conf); then
    sed -i "s|^#Port.*|Port $PORT|" $conf
elif (grep -ru "^Port" $conf); then
    sed -i "s|^Port.*|Port $PORT|" $conf
else
    echo "Port $PORT" >> $conf
fi
