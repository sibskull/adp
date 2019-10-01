#!/bin/sh

. adp-functions

PORT="$1" # the port number

if (echo $([[ $(grep -ru "#Port" /etc/openssh/sshd_config) == '#Port'* ]]) = 0); then
	sed -n 's|#Port|Port $PORT|w output' /etc/openssh/sshd_config
else 
	sed -n 's|Port|Port $PORT|w output' /etc/openssh/sshd_config
fi
