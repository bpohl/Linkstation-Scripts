#!/bin/bash
# List what is going on with the Drobo mount

: ${DROBO_MOUNTPOINT:="/media/Drobo"}
: ${PID_FILE:="/run/drobo-mount.pid"}

echo "PID File: $(cat "$PID_FILE")"
ps ww -a | head -n 1
ps ww -au root | grep "$DROBO_MOUNTPOINT" | grep -v grep

echo
lsblk
