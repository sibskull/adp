#!/bin/sh

. adp-functions

LOGIN="$1" #account name
HOMEDIR=$(python3 -c "import pwd; print(pwd.getpwnam('$LOGIN').pw_dir)")

# Deny the user access to the system and prevent starting new processes.
passwd --lock "$LOGIN"
# Find all the running user processes and terminate them.
killall -9 -u "$LOGIN"
# Create a backup file of the local user's account.
mkdir -p /user-backups
tar jcvf /user-backups/"$LOGIN"-backup.tar.bz2 "$HOMEDIR"
# Remove an account of the local user.
userdel -r "$LOGIN"
