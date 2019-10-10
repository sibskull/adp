#!/bin/sh

. adp-functions

USER="$1"
PASSWORD="$2"
PORT="$3"
HOST="$4"

# within the key
# the first method
ssh-copy-id -f -p "$PORT" "$USER":"$PASSWORD"@"$HOST"
# the second method
#cat > ~/.ssh/id_rsa.pub | ssh "$USER":"$PASSWORD"@"$HOST" "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys"
#ssh "$USER":"$PASSWORD"@"$HOST":"$PORT"
