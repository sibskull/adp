#!/bin/sh

. adp-functions

SWITCH="$1" # true (allow access) / false (deny access)
USER="$2"
GROUP="$3"

conf="/etc/openssh/sshd_config"

if [ "$SWITCH" = true ]; then
{
if (grep -ru "^#AllowUsers" $conf); then
    sed -i "s|^#AllowUsers.*|AllowUsers $USER|" $conf
elif (grep -ru "^AllowUsers" $conf); then
    sed -i "s|^AllowUsers.*|AllowUsers $USER|" $conf
else
    echo "AllowUsers $USER" >> $conf
fi

if (grep -ru "^#AllowGroups" $conf); then
    sed -i "s|^#AllowGroups.*|AllowGroups $GROUP|" $conf
elif (grep -ru "^AllowGroups" $conf); then
    sed -i "s|^AllowGroups.*|AllowGroups $GROUP|" $conf
else
    echo "AllowGroups $GROUP" >> $conf
fi
}
else
{
if (grep -ru "^#DenyUsers" $conf); then
    sed -i "s|^#DenyUsers.*|DenyUsers $USER|" $conf
elif (grep -ru "^DenyUsers" $conf); then
    sed -i "s|^DenyUsers.*|DenyUsers $USER|" $conf
else
    echo "DenyUsers $USER" >> $conf
fi

if (grep -ru "^#DenyGroups" $conf); then
    sed -i "s|^#DenyGroups.*|AllowGroups $GROUP|" $conf
elif (grep -ru "^DenyGroups" $conf); then
    sed -i "s|^DenyGroups.*|AllowGroups $GROUP|" $conf
else
    echo "DenyGroups $GROUP" >> $conf
fi
}
fi

systemctl restart sshd
