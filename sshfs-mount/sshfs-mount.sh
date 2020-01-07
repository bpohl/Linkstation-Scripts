#!/bin/bash -x
# Creates a unique mountpoint for a sshfs share and mounts the remote disk.
#
#  ssh-mount.sh [user@]host:[/dir/path]
#

: ${REMOTE_USER:="${1%%@*}"}
REMOTE_USER="${REMOTE_USER##*:}"
: ${REMOTE_USER:="$USER"}
SERVER="${1##*@}"
SERVER="${SERVER%%:*}"
: ${SERVER:="localhost"}
: ${FUSE_USER:="$USER"}
: ${REMOTE_PATH:="${1#*:}"}
REMOTE_PATH="${REMOTE_PATH%%[@:]*}"

# Find and source the fuse.lib
PATH="$(dirname "$0")":"$PATH"
. "$(which fuse.lib)"

# Assemble the mountpoint path
: ${FUSE_MOUNTPOINT:="${FUSE_ROOT}/${SERVER}/${REMOTE_USER}/${REMOTE_PATH}"}
REMOTE_PATH="${1:-"${REMOTE_USER}@${SERVER}:${REMOTE_PATH}"}"

# Create the mountpoint
if ! fuse-mountpoint "$FUSE_MOUNTPOINT"; then
  echo "Could not create mountpoint at ${FUSE_MOUNTPOINT}." >&2
  exit 1
fi

# Try to mount the remote directory
echo "Mountpoint: $FUSE_MOUNTPOINT"
/usr/bin/sshfs "$REMOTE_PATH" "$FUSE_MOUNTPOINT" && echo "Mounted."

exit
