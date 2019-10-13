# Linkstation-Scripts
Scripts and tools for use with [Debian\_on\_Buffalo](https://github.com/1000001101000/Debian_on_Buffalo) installed NAS boxes.

I wanted a place to stash any scripts I write to configure my Buffalo LS220D NAS and make them available to others.  I have only the one Linkstation so that is the only one the scripts are tested on, but since these Linkstation and Terastation devices share so much the scripts should be good examples if they don't work outright.

## Scripts

### ls\_disk\_led

A script run at boot by init to make the disk LEDs flash on disk access.  Even though there are two LEDs, marked one for each drive, there doesn't seem to be triggers that distinguish between the drives.  Therefor, the disk1 light is read activity and disk2 light is wright activity.

The script itself needs to run with root privileges, which it will when executed by init.  To be able to run it from a regular user account, you will need `sudo` installed.

##### Installation

1\. Download the scrip and make sure it is executable.

    chmod +x ls_disk_led.sh

2\. Copy it to where ever you like, though I chose `/usr/local/sbin`.

3\. Make a link to the script from the `/etc/init.d` directory named simply `ls-disk-led` (without `.sh`) and then use `update-rc.d` to set it to start as a service.

    sudo ln -s /usr/local/sbin/ls-disk-led.sh /etc/init.d/ls-disk-led
    sudo update-rc.d ls-disk-led defaults

4\. Reboot.

## Acknowledgments

[1000001101000](https://github.com/1000001101000) for  [Debian\_on\_Buffalo](https://github.com/1000001101000/Debian_on_Buffalo) 
