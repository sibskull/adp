#!/bin/sh

. adp-functions

# Install CA certificate for user
CERT="$1"
LOCATION="$2"
TITLE="$3" #For example, url or name cert in DB

NSSDB="$HOME/.pki/nssdb"
mkdir -p $NSSDB

# Copy cert from location
CERT_PATH="$NSSDB/$CERT"
adp_copy_file "$LOCATION" "$CERT" "$CERT_PATH"

#for chromium
if [ ! -f "$NSSDB/cert9.db" ]; then
  certutil -N -d sql:$NSSDB --empty-password
fi
certutil -d sql:"$NSSDB" -D -n "$TITLE"
certutil -d sql:"$NSSDB" -A -t TC -n "$TITLE" -i "$CERT_PATH"

#for firefox
FIREFOX_DIR="$HOME/.mozilla/firefox"
if [ -d "$FIREFOX_DIR" ]; then
  FIREFOX_NSSDB="$(find $FIREFOX_DIR -type d -name *.default)"
  if [ "$FIREFOX_NSSDB" != "" ]; then
    certutil -d sql:"$FIREFOX_NSSDB" -D -n "$TITLE"
    certutil -d sql:"$FIREFOX_NSSDB" -A -t TC -n "$TITLE" -i "$CERT_PATH"
  fi
fi
