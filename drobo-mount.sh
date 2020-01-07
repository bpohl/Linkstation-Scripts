#!/bin/bash 
# Mount the Drobo if it isn't mounted and if another process isn't
# already trying.

: ${MOUNT_POINT:="/media/Drobo"}
: ${PID_FILE:="/run/drobo-mount.pid"}

if findmnt --df --first "$DROBO_MOUNT_POINT"; then
  echo "Warning: $DROBO_MOUNT_POINT already mounted." >&2
  exit 1
fi

unset old_pid
if ps ${old_pid:=$(cat "$PID_FILE")} 999999999; then
  echo "Warning: drobo-mount already running at PID $old_pid." >&2
  exit 2
fi
echo $$ > "$PID_FILE"

exec mount "$DROBO_MOUNT_POINT"

exit 3
