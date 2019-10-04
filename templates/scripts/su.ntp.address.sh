#!/bin/sh

. bin/adp-functions

ADDRESS="$1" # you can specify multiple addresses with a space

sed "2i\'$ADDRESS'" /etc/systemd/timesyncd.conf
