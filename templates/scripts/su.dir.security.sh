#!/bin/sh

. adp-functions

DIR="$1"
USER="$2"
GROUP="$3"

chown -R "$GROUP":"$USER" $DIR
