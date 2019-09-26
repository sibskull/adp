#!/bin/sh

. adp-functions

FILE="$1"
USER="$2"
GROUP="$3"

chown "$GROUP":"$USER" $FILE
