#!/bin/sh

. bin/adp-functions

# in days
MAX_AGE="$1"
WARN_AGE="$2"

conf="/etc/login.defs"
#MAX_AGE
if (grep -ru "^#PASS_MAX_DAYS" $conf); then
    sed -i "s|^#PASS_MAX_DAYS.*|PASS_MAX_DAYS $MAX_AGE|" $conf
elif (grep -ru "^PASS_MAX_DAYS" $conf); then
    sed -i "s|^PASS_MAX_DAYS.*|PASS_MAX_DAYS $MAX_AGE|" $conf
else
    echo "PASS_MAX_DAYS $MAX_AGE" >> $conf
fi
#WARN_AGE
if (grep -ru "^#PASS_WARN_AGE" $conf); then
    sed -i "s|^#PASS_WARN_AGE.*|PASS_WARN_AGE $WARN_AGE|" $conf
elif (grep -ru "^PASS_WARN_AGE" $conf); then
    sed -i "s|^PASS_WARN_AGE.*|PASS_WARN_AGE $WARN_AGE|" $conf
else
    echo "PASS_WARN_AGE $WARN_AGE" >> $conf
fi
