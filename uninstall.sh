#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root (use sudo)" 1>&2
   exit 1
fi

is_Raspberry=$(cat /proc/device-tree/model | awk  '{print $1}')
if [ "x${is_Raspberry}" != "xRaspberry" ] ; then
  echo "Sorry, this drivers only works on raspberry pi"
  exit 1
fi

uname_r=$(uname -r)

echo "remove dtbos"
rm  /boot/overlays/wm8960-soundcard.dtbo || true

#unset dtoverlays
sed -i -e 's:dtparam=i2c_arm=on:#dtparam=i2c_arm=on:g'  /boot/firmware/config.txt || true
sed -i '/dtoverlay=wm8960-soundcard/d' /boot/firmware/config.txt || true

echo "remove alsa configs"
rm -rf  /etc/wm8960-soundcard/ || true


echo "disabled service "
systemctl disable wm8960-soundcard.service 

echo "remove wm8960-soundcard"
rm  /usr/bin/wm8960-soundcard || true
rm  /lib/systemd/system/wm8960-soundcard.service || true

echo "remove dkms"
dkms remove wm8960-soundcard/1.0 --all
rm  -rf /var/lib/dkms/wm8960-soundcard || true

echo "remove kernel modules"
rm  /lib/modules/${uname_r}/kernel/sound/soc/codecs/snd-soc-wm8960.ko || true
rm  /lib/modules/${uname_r}/kernel/sound/soc/codecs/snd-soc-wm8960-soundcard.ko || true

sed -i '/i2c-dev/d' /etc/modules
sed -i '/snd-soc-wm8960/d' /etc/modules
sed -i '/snd-soc-wm8960-soundcard/d' /etc/modules

echo "------------------------------------------------------"
echo "Please reboot your raspberry pi to apply all settings"
echo "Thank you!"
echo "------------------------------------------------------"
