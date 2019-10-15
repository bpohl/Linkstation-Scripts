#! /bin/bash

### BEGIN INIT INFO
# Provides:          off-switch
# Required-Start:    
# Required-Stop:     
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Make the power switch work
# Description:       Have moving the power switch to OFF call shutdown
### END INIT INFO

## Send all output to STDERR, could be log later
exec 1>&2

## Set variable defaults
: ${DAEMON:=/usr/sbin/thd}
: ${NAME:="$(basename "$0")"}
: ${PIDFILE:="/var/run/$NAME.pid"}

# Exit if the package is not installed
if [ ! -x "$(which "$DAEMON")" ]; then
  echo "TriggerHappy package ($DAEMON) not installed..."
  exit 6
fi

## Util functions
function rm_pidfile () {
  rm "$PIDFILE" && echo " Deleted!"
  [ -f "$PIDFILE" ] && echo " Failed to delete it!" && exit 3
}

## Action functions

# Stop the process
function do_start () {
  echo "Starting a TriggerHappy process just to handle shutdown..."

  do_status
  case $? in
    41)
      echo
      exit 4
      ;;
    42) rm_pidfile;;
  esac

  triggers="$(grep -A 100 '^### TRIGGERS' "$0" | grep -v "^#")"
  echo -e "\nPreparing to use triggers:\n$triggers"
  exec -a "$NAME" "$DAEMON" --daemon                          \
            --triggers <(echo -e "$triggers") \
            --pidfile "$PIDFILE"              \
            /dev/input/event*                 \
      || exit 2
}

# Stop the process
function do_stop () {
  echo "Killing the shutdown thd process..."
  do_status
  case $? in
    41)
      if kill "$(cat "$PIDFILE")"; then
        echo " Killed!"
      else
        echo " Process didn't die!"
        exit 5
      fi
      ;;
    42)
      rm_pidfile
      ;;
    43)
      echo -e "\nCheck if the thd daemon is running and kill it manually."
      ;;
  esac
}

# Status
function do_status () {
  if [ -f "$PIDFILE" ]; then
      echo "PID file $PIDFILE contains $(cat "$PIDFILE")"
      if ps $(cat "$PIDFILE") >/dev/null; then
        echo -n "  and the process is running..."
        return 41
      else
        echo -n "  but the process isn't running..."
        return 42
      fi
  else
    echo -n "PID file $PIDFILE does not exist..."
    return 43
  fi
}


## Carry out specific functions when asked to by the system
case "$1" in
  start)
    do_start
    ;;
  stop)
    do_stop
    ;;
  restart)
    do_stop
    sleep 10 &
    while ps $! >/dev/null && [ -f "$PIDFILE" ]; do sleep 1; done
    do_start
    ;;
  status)
    do_status 
    echo
    ;;
  *)
    echo "Usage: $(basename "$0") {start|stop|restart|status}"
    exit 1
    ;;
esac

exit 0


## Everything after the '### TRIGGER' tag is read as the triggers file
### TRIGGERS
#
# Shutdown when the power switch is turned to Off
KEY_ESC   0   /usr/sbin/shutdown -h now
#
# Turn the function LED on and off for testing the switch trigger
#KEY_ESC   0   echo 0 > /sys/class/leds/led\:function\:white/brightness
#KEY_ESC   1   echo 1 > /sys/class/leds/led\:function\:white/brightness
