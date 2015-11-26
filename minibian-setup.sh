#!/bin/bash
#
# Copyright (c) 2015 Thomas Szteliga <ts@websafe.pl>, <https://websafe.pl/>
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

# http://devlog.websafe.pl/2015/11/24/minibian-on-raspberry-pi-and-pi2-quickstart/

#
WLAN_SSID=${WLAN_SSID:-$1}
WLAN_PASS=${WLAN_PASS:-$2}
TIMEZONE=${TIMEZONE:-Europe/Warsaw}

#
if [ -z "${WLAN_PASS}" ];
then
  echo -e "Usage:\n"
  echo -e "  ${0} <wlan-ssid> <wlan-password>\n"
  exit
else
  echo "WLAN SSID: \"${WLAN_SSID}\""
  echo "WLAN PASSPHRASE: \"${WLAN_PASS}\""
  echo "TIMEZONE: \"${TIMEZONE}\""
  echo ""
  echo "Press [Enter] to confirm and continue or [Ctrl+C] to abort."
  read dummy
fi

#
apt-get -y update
apt-get -y upgrade

#
apt-get -y install apt-utils apt-file raspi-config \
  usbutils wpasupplicant crda mc

#
cat <<EOF >> /etc/network/interfaces

auto wlan0
allow-hotplug wlan0
iface wlan0 inet dhcp
wpa-conf /etc/wpa_supplicant/wpa_supplicant.conf

EOF

#
wpa_passphrase "${WLAN_SSID}" "${WLAN_PASS}" \
  >> /etc/wpa_supplicant/wpa_supplicant.conf

#
ifup wlan0

#
cat /usr/share/zoneinfo/${TIMEZONE} \
  > /etc/localtime

#
sed -e 's#^exit 0#/bin/dmesg -n 1\n\nexit 0#g' \
  -i /etc/rc.local

#
update-alternatives --remove-all editor
update-alternatives --install \
  /usr/bin/editor editor /usr/bin/mcedit 10

#
raspi-config --expand-rootfs

#
cat /proc/partitions

#
partprobe /dev/mmcblk0

#
cat /proc/partitions

#
resize2fs /dev/mmcblk0p2

#
apt-get -y install rpi-update 
PRUNE_MODULES=1 rpi-update

#
rm -rf /boot.bak
apt-get clean
rm -rf ~/{.cache,.config,.local}
rm -f ~/{.bash_history,.selected_editor}

#
shutdown -r +1
