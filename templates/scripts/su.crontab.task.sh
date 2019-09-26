#!/bin/sh

. adp-functions

SCRIPT="$1" # path to your script
PERIOD="$2" # daily/hourly/monthly/weekly

cp -a $SCRIPT /etc/cron.$PERIOD/
