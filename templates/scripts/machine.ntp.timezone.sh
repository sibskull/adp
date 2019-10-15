#!/bin/sh

. adp-functions

ZONE="$1" # example: Europe/Moscow

timedatectl set-timezone "$ZONE"
