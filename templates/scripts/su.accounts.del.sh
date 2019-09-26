#!/bin/sh

. adp-functions

USER="$1" #account name

# Deny the user access to the system and prevent starting new processes.
passwd --lock $USER
# Find all the running user processes and terminate them.
killall -9 -u $USER
# To create a backup file of the local user's account.
mkdir -p /user-backups
tar jcvf /user-backups/$USER-backup.tar.bz2 /home/$USER
# Remove an account of the local user.
userdel --remove $USER
