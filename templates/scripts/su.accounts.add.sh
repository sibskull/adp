#!/bin/sh

. adp-functions

USER="$1" #account name
COMMENT="$2" #comment for the account
PASSWD="$3" #the password for the account
ADDITIONAL_GROUPS="$4" #add user to additional groups separated by commas
TIME_LIMIT="$5" #specify the date the account lockout if it is temporary (DD:MM:YYYY)
SHELL="$6" #command shell for a user (path to shell)

useradd -G "$ADDITIONAL_GROUPS" -p "$PASSWD" -s "$SHELL" -e "$TIME_LIMIT" -c "$COMMENT" "$USER"
