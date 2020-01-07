#!/bin/bash 
# Mount the Drobo if it isn't mounted and if another process isn't
# already trying.

: ${DROBO_MOUNTPOINT:="/media/Drobo"}
: ${PID_FILE:="/run/drobo-mount.pid"}

[ "$1" == "-q" ] && exec >/dev/null

# No use if the disk is already mounted
if findmnt --df --first "$DROBO_MOUNTPOINT"; then
  echo "$DROBO_MOUNTPOINT already mounted." 
  exit 1
fi

# Make sure another process isn't already trying
unset old_pid
if ps ${old_pid:=$(cat "$PID_FILE")} 999999999; then
  echo "Drobo mounting script already running at PID $old_pid." 
  exit 2
fi
echo $$ > "$PID_FILE"

# Let the mount command take over the process
echo "Mounting $DROBO_MOUNTPOINT" >&2
exec mount "$DROBO_MOUNTPOINT"

# Should never get here
exit 3
