minibian-setup.sh
=================

A simple Bash script for automated setup of a stock [MINIBIAN] installation.


Usage
-----

~~~~ bash
cd /tmp
wget --content-disposition http://git.io/vBRfm
sh minibian-setup.sh "MY-WLAN-SSID" "MY-WLAN-PASSPHRASE"
~~~~


What next?
----------

If your `wlan0` is not working after rebooting, you're probably missing kernel
firmware for your wireless network adapter.

Just check `dmesg` for entries looking like:

> r8188eu 1-1.5:1.0: **Firmware** _rtlwifi/rtl8188eufw.bin_ **not available**


and use `apt-file` to find the corresponding package containing this firmware:

~~~~ bash
apt-file update
apt-file find rtl8188eufw.bin
~~~~


which will result in:

~~~~ shell
firmware-realtek: /lib/firmware/rtlwifi/rtl8188eufw.bin
~~~~


and then install the required package:

~~~~ bash
apt-get -y install firmware-realtek
~~~~


Now unplug and reinsert the wireless adapter or reboot.



[MINIBIAN]: https://minibianpi.wordpress.com/

