#!/bin/sh

. bin/adp-functions

ZONE="$1" # example: Europe/Moscow

timedatectl set-timezone "$ZONE"
