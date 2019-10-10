#!/bin/sh

. adp-functions

ADDRESS="$1" # you can specify multiple addresses with a space

#sed -i "2i\ ""$ADDRESS""" /etc/systemd/timesyncd.conf

conf="/etc/systemd/timesyncd.conf"

if (grep -ru "^#NTP" $conf); then
    sed -i "s|^#NTP=.*|NTP=$ADDRESS|" $conf
elif (grep -ru "^NTP" $conf); then
    sed -i "s|^NTP=.*|NTP=$ADDRESS|" $conf
else
    echo "NTP=$ADDRESS" >> $conf
fi

systemctl restart systemd-timesyncd
