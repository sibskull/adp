#!/bin/sh

. bin/adp-functions

REPO="$1"
TYPE="$2" # ‘branch’ or ‘branches’ removes all branch sources, ‘task’ or ‘tasks’ removes all tasks sources, ‘cdrom’ or ‘cdroms’ removes all cdrom sources

apt-repo rm "$REPO" "$TYPE"
