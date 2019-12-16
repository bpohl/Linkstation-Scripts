#! /bin/bash 

### BEGIN INIT INFO
# Provides:          ls-disk-led
# Required-Start:    
# Required-Stop:     
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Linkstation Disk Activity LEDs
# Description:       Sets disk read/write activity trigger on LS disk LEDs.
### END INIT INFO

## Send all output to STDERR, could be log later
exec 1>&2

# Location of the LEDs
led_hdd1_red='/sys/class/leds/led:hdd1:red/trigger'
led_hdd2_red='/sys/class/leds/led:hdd2:red/trigger'

# Get ready to run as root if not already and sudo is installed
function writable_or_sudo () {
  [ -w "$led_hdd1_red" ] && [ -w "$led_hdd2_red" ] && return 0
  if [ -n "${SUDO_CMD:="$(which sudo)"}" ]; then
    $SUDO_CMD -v  || exit 2
    return 0
  fi
  echo "Permission denied: sudo not installed."
  return 3
}

# Set the LED devices to trigger on drive activity
function do_start () {
  echo "Turning disk activity LEDs on..."
  # The output redirection needs to be in the privilaged process so
  #   the echo to /sys/class/leds/led\:* is wrapped in a /bin/sh
  (
    $SUDO_CMD /bin/sh <<EOS
      echo disk-read > $led_hdd1_red  || exit 4
      echo disk-write > $led_hdd2_red || exit 5
EOS
  )
}

# Set the LED devices to stay off
function do_stop () {
  echo "Turning disk activity LEDs off..."
  # The output redirection needs to be in the privilaged process so
  #   the echo to /sys/class/leds/led\:* is wrapped in a /bin/sh
  (
    $SUDO_CMD /bin/sh <<EOS
      echo none > $led_hdd1_red || exit 6
      echo none > $led_hdd2_red || exit 7
EOS
  )
}

# Carry out specific functions when asked to by the system
case "$1" in
  start)
    writable_or_sudo && do_start
    ;;
  stop)
    writable_or_sudo && do_stop
    ;;
  restart)
    writable_or_sudo && do_stop && do_start
    ;;
  status)
    # Find the active trigger in square brackets
    echo "led:hdd1:red trigger: $(cut -d'[' -f2 "$led_hdd1_red" | cut -d']' -f1)"
    echo "led:hdd2:red trigger: $(cut -d'[' -f2 "$led_hdd2_red" | cut -d']' -f1)"
    ;;
  *)
    echo "Usage: /etc/init.d/ls-disk-led {start|stop|restart|status}"
    exit 1
    ;;
esac

exit  # Exit code is that of whatever happened last
