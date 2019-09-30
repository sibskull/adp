#!/bin/sh

. adp-functions

PASSWORD="$1"
USERS="$2" # who is allowed to login (comma separated)

# make backup
mkdir /etc/grub.d.backup
cp /etc/grub.d/* /etc/grub.d.backup

ENCRYPT_PASSWORD=$(grub-mkpasswd-pbkdf2 | echo "$PASSWORD" | grep -o '[^:]*')
echo "set superusers="root","$USERS"" >> /etc/grub.d/40_custom
echo "password_pbkdf2 root $ENCRYPT_PASSWORD" >> /etc/grub.d/40_custom
echo "export superusers" >> /etc/grub.d/40_custom

sed -i "s,${CLASS},${CLASS} --users "$USERS"," /etc/grub.d/10_linux

update-grub
