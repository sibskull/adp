#!/bin/sh

. bin/adp-functions

KERNEL="$1" # std-def/un-def

update-kernel -t "$KERNEL"
