#!/bin/sh

. adp-functions

# Remove CA certificate for user
TITLE="$1" #For example, url or name cert in DB

#for chromium
NSSDB="$HOME/.pki/nssdb"
certutil -d sql:"$NSSDB" -D -n "$TITLE"

#for firefox
FIREFOX_NSSDB="$(find "$HOME/.mozilla/firefox" -type d -name *.default)"
[ "$FIREFOX_NSSDB" != "" ] && certutil -d sql:"$FIREFOX_NSSDB" -D -n "$TITLE"
