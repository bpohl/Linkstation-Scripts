#!/bin/bash
# Creates a unique mountpoint for a sshfs share and mounts the remote disk.
#
#  ssh-mount.sh [user@]host:[/dir/path]
#

# Set some defaults
: ${FUSE_ROOT:="/media/$USER/sshfs"}
: ${FUSE_USER:="$USER"}
: ${FUSE_PRUNE:='true'}
  
# Make a nice way out
function egress () {
  echo "Usage:  ssh-mount.sh [-h|--help] [user@]host:[/dir/path]"
  exit $1
}

# Catch any options
case $1 in
  -h|--help) egress 0 ;;
  --prune)   FUSE_PRUNE='true' ;;
  --noprune) FUSE_PRUNE='false' ;;
esac

# Prune the mountpoint root if allowed to
FUSE_ROOT="$(realpath --canonicalize-missing "$FUSE_ROOT")" 
"${FUSE_PRUNE,,}" && find "$FUSE_ROOT" \
                          -mount -empty -type d -delete 2>/dev/null

# Use Perl to parse the destination better than Bash can
eval $(perl -e '$_ = shift; chomp; my @path = m/^(?:(.+)@)?(.*?)(?::(.*))?$/; foreach (@ARGV) { printf(": \${%s:=\"%s\"}\n", $_, shift(@path)); }' "$1" REMOTE_USER SERVER REMOTE_DIR || echo "err=$?")

# If the Perl doesn't work, try it with Bash
if [ -n "$err" ]; then
  : ${REMOTE_USER:="${1%%@*}"}
  REMOTE_USER="${REMOTE_USER##*:}"
  SERVER="${1##*@}"
  SERVER="${SERVER%%:*}"
  : ${REMOTE_DIR:="${1#*:}"}
  REMOTE_PATH="${REMOTE_DIR%%[@:]*}"
fi
: ${REMOTE_USER:="$USER"}
: ${SERVER:="localhost"}
: ${REMOTE_PATH:=""}

# Find and source the fuse.lib
PATH="$(dirname "$0")":"$PATH"
. "$(which fuse.lib)"

# Assemble the mountpoint path
: ${FUSE_MOUNTPOINT:="${FUSE_ROOT}/${SERVER}/${REMOTE_USER}/${REMOTE_DIR}"}
REMOTE_PATH="${1:-"${REMOTE_USER}@${SERVER}:${REMOTE_DIR}"}"

# Create the mountpoint
FUSE_MOUNTPOINT="$(realpath --canonicalize-missing "$FUSE_MOUNTPOINT")"
if ! fuse-mountpoint "$FUSE_MOUNTPOINT"; then
  echo "Could not create mountpoint at ${FUSE_MOUNTPOINT}." >&2
  exit 1
fi

# Try to mount the remote directory
if [ "$(ls -A "$FUSE_MOUNTPOINT")" ]; then
  if mounted="$(mount | grep "$FUSE_MOUNTPOINT")"; then
    cat <<EOS >&2
Error: The directory "${FUSE_MOUNTPOINT}" 
       is being used as a mountpoint:
       
$mounted

EOS
    exit 1
  else
    cat <<EOS >&2
Error: The directory "${FUSE_MOUNTPOINT}" 
       is not being used as a mountpoint but is not empty.  Check and 
       clear the directory or set the path manually by setting the 
       FUSE_MOUNTPOINT environment variable.
EOS
    exit 2
  fi
else
  echo "Mountpoint: $FUSE_MOUNTPOINT"
  /usr/bin/sshfs "$REMOTE_PATH" "$FUSE_MOUNTPOINT" && echo "Mounted."
fi

exit
