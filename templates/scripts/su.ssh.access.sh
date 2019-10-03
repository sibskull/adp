#!/bin/sh

. adp-functions

USER="$1"
GROUP="$2"

conf="/etc/openssh/sshd_config"

if (grep -ru "^#AllowUsers" $conf); then
    sed -i "s|^#AllowUsers.*|AllowUsers $USER|" $conf
elif (grep -ru "^AllowUsers" $conf); then
    sed -i "s|^AllowUsers.*|AllowUsers $USER|" $conf
else
    echo "AllowUsers $USER" >> $conf
fi

if (grep -ru "^#AllowGroups" $conf); then
    sed -i "s|^#AllowGroups.*|AllowGroups $GROUP|" $conf
elif (grep -ru "^AllowGroups" $conf); then
    sed -i "s|^AllowGroups.*|AllowGroups $GROUP|" $conf
else
    echo "AllowGroups $GROUP" >> $conf
fi
