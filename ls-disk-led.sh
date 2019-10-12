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

# Get ready to run as root if not already and sudo is installed
if [ -n "${SUDO_CND:="$(which sudo)"}" ]; then
     $SUDO_CND -v || exit 2
fi

# Carry out specific functions when asked to by the system
case "$1" in
  start)
    echo "Turning disk activity LEDs on..."
    # The output redirection needs to be in the privilaged process so
    #   the echo to /sys/class/leds/led\:* is wrapped in a /bin/sh
    $SUDO_CND /bin/sh <<EOS
        echo disk-read > /sys/class/leds/led\:hdd1\:red/trigger
        echo disk-write > /sys/class/leds/led\:hdd2\:red/trigger
EOS
    ;;
  stop)
    echo "Turning disk activity LEDs off..."
    # The output redirection needs to be in the privilaged process
    #   so the echo to the /sys is wrapped in a /bin/sh
    $SUDO_CND /bin/sh <<EOS
        echo none > /sys/class/leds/led\:hdd1\:red/trigger
        echo none > /sys/class/leds/led\:hdd2\:red/trigger
EOS
    ;;
  *)
    echo "Usage: /etc/init.d/ls-disk-led {start|stop}"
    exit 1
    ;;
esac

exit 0
