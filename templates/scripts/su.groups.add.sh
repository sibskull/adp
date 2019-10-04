#!/bin/sh

. bin/adp-functions

GROUP="$1"
PASSWD="$2"

#You need to pass the encrypted password for the utility. If you pass the password in the clear, then nothing will not work.
#To generate a password hash using crypt and python3.
PASSWD_ENCRYPT=$(python3 -c "import random,string,crypt;
randomsalt = ''.join(random.sample(string.ascii_letters,8));
print crypt.crypt('$PASSWD', '\$6\$%s\$' % randomsalt)")

groupadd -p "$PASSWD_ENCRYPT" "$GROUP"
