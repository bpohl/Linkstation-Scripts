# Linkstation-Scripts
Scripts and tools for use with [Debian\_on\_Buffalo](https://github.com/1000001101000/Debian_on_Buffalo) installed NAS boxes.

I wanted a place to stash any scripts I write to configure my Buffalo LS220D NAS and make them available to others.  I have only the one Linkstation so that is the only one the scripts are tested on, but since these Linkstation and Terastation devices share so much the scripts should be good examples if they don't work outright.

## Scripts

### ls-disk-led

A script run at boot by init to make the disk LEDs flash on disk access.  Even though there are two LEDs, marked one for each drive, there doesn't seem to be triggers that distinguish between the drives.  Therefor, the disk1 light is read activity and disk2 light is write activity.

The script itself needs to run with root privileges, which it will when executed by init.  To be able to run it from a regular user account, you will need `sudo` installed.


### off-switch

Makes turning the power switch to the OFF position execute the command `shutdown -h now`.

The package [TriggerHappy](http://manpages.ubuntu.com/manpages/bionic/man1/thd.1.html) is needed to watch for the switch state to change.  Install TriggerHappy with:

    apt install TriggerHappy


## Installation

Unless otherwise noted above, most of these scripts are meant to be handled by the init to provide a service.  Refer to the documentation for [update-rc.d](https://manpages.debian.org/testing/init-system-helpers/update-rc.d.8.en.html) for more detail, but the general steps are listed below.  The name `service-name` is used for the service name and `service-name.sh` refers to the scrip file.

1\. Download the scrip and make sure it is executable.

    chmod +x service-name.sh

2\. Copy it to where ever you like, though I chose `/usr/local/sbin`.

3\. Make a link to the script from the `/etc/init.d` directory named simply `service-name` (without `.sh`) and then use `update-rc.d` to set it to start as a service.

    sudo ln -s /usr/local/sbin/service-name.sh /etc/init.d/service-name
    sudo update-rc.d service-name defaults

4\. Reboot.


## Acknowledgments

[1000001101000](https://github.com/1000001101000) for  [Debian\_on\_Buffalo](https://github.com/1000001101000/Debian_on_Buffalo) 
