#!/bin/sh

. adp-functions

LOGIN="$1" #account name
COMMENT="$2" #comment for the account
PASSWD="$3" #the password for the account

useradd -c "$COMMENT" "$LOGIN"
echo "$PASSWD" | passwd "$LOGIN" --stdin
