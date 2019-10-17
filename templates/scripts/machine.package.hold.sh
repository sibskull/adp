#!/bin/sh

. adp-functions

PACKAGES="$*" # list of frozen packages

for package in $PACKAGES; do
cat > /etc/apt/apt.conf.d/hold-$package.conf << EOF
RPM::Hold {
        "^$package";
};
EOF
done
