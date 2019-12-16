#!/bin/bash

### BEGIN INIT INFO
# Provides:          ls-led-control
# Required-Start:    
# Required-Stop:     
# Default-Start:     1 2 3 4 5
# Default-Stop:      
# Short-Description: Linkstation Disk Activity LEDs
# Description:       Sets disk read/write activity trigger on LS disk LEDs.
### END INIT INFO

## Send all output to STDERR, could be log later
exec 1>&2

# Load the config file
: ${LED_CONFIG:="$(dirname "$0")/../$(basename "$0").conf"}
if ! [ -f "$LED_CONFIG" ]; then
  echo "ERROR: Config file $LED_CONFIG not found."
  exit 1
fi
eval $(grep '=' "$LED_CONFIG")

: ${PATH='/sbin:/usr/sbin:/bin:/usr/bin'}
: ${DESC="Linkstation Disk Activity LEDs"}
: ${LED_ROOT:='/sys/class/leds'}

# Define LSB functions.
. /lib/lsb/init-functions


# Get ready to run as root if not already and sudo is installed
function writable_or_sudo () {
  #[ -w "$led_hdd1_red" ] && [ -w "$led_hdd2_red" ] && return 0
  if [ -n "${SUDO_CMD:="$(which sudo)"}" ]; then
    $SUDO_CMD -v  || return 4
    return 0
  fi
  log_failure_msg "Permission denied: sudo not installed."
  return 4
}


# Turn a line of config into variables
function parse_config () {
  IFS=${2:-$old_IFS}
  eval $(printf 'LED=%s Func=%s Start=%s Stop=%s' $1)
  LED_Path="$LED_ROOT/$LED/$Func"
  return 0
}


# Loop over the configs and format as and echo the value to the LED
function construct_settings () {
  old_IFS=$IFS; IFS=$'\n'
  for led_setting in $(grep -P -v '^\s*(#.*|.*=.*)*$' "$LED_CONFIG"); do
    parse_config "$led_setting"
    val="$Stop"
    [[ "$1" == 'on' ]] && val="$Start"
    echo "echo $val > '$LED_Path' || exit 1"
  done
  return 0
}


# Set the LED devices
function do_something () {
  # The output redirection needs to be in the privileged process so
  #   the echo to /sys/class/leds/led\:* is wrapped in a /bin/sh
  state=${1:-"off"}
  if (
    $SUDO_CMD /bin/sh -c "$(construct_settings $state)"
  )
  then
    log_success_msg "Turned LEDs $state"
  else
    log_failure_msg "Failed turning LEDs $state"
  fi
}


# Show the status of all listed LEDs
function do_status () {
  old_IFS=$IFS; IFS=$'\n'
  for led_setting in $(grep -P -v '^\s*(#.*|.*=.*)*$' "$LED_CONFIG"); do
    parse_config "$led_setting"
    triggers="$(cat "$LED_Path")"
    triggers="${triggers##*[}"
    log_success_msg "$LED $Func: ${triggers%%]*}"
  done
  return 0
}


# Carry out specific functions when asked to by the system
case "$1" in
  start)
    writable_or_sudo && do_something on
    ;;
  stop)
    writable_or_sudo && do_something off
    ;;
  restart|force-reload)
    writable_or_sudo && do_something off && do_something on
    ;;
  status)
    do_status
    ;;
  '')
    echo "Usage: $0 {start|stop|restart|force-reload|status}"
    exit 2
    ;;
  *)
    log_failure_msg "Unrecognized or supported command $1"
    exit 3
    ;;
esac

exit  # Exit code is that of whatever happened last
