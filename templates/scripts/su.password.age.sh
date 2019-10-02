#!/bin/sh

. adp-functions

AGE="$1" # end date of password expiration

chage --lastday "$AGE"
