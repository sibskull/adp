#!/bin/sh

. adp-functions

GROUP="$1"
PASSWD="$2"

#You need to pass the encrypted password for the utility. If you pass the password in the clear, then nothing will not work.
#generate random characters for the encryption password
PASSWD_RANDOM=$(openssl rand -base64 32)
#generate the password
PASSWD_ENCRYPT=$(perl -e 'print crypt($PASSWD, $PASSWD_RANDOM),"\n"')

usergroup $PASSWD_ENCRYPT $GROUP
