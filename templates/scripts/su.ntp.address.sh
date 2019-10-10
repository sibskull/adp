#!/bin/sh

. adp-functions

ADDRESS="$*" # you can specify multiple addresses with a space

conf="/etc/systemd/timesyncd.conf"

if (grep -ru "^#NTP" $conf); then
    sed -i "s|^#NTP=.*|NTP=$ADDRESS|" $conf
elif (grep -ru "^NTP" $conf); then
    sed -i "s|^NTP=.*|NTP=$ADDRESS|" $conf
else
    echo "NTP=$ADDRESS" >> $conf
fi

systemctl restart systemd-timesyncd
