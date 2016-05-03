#!/bin/sh

#Files extracted by chroot.sh are in this path
CHROOT_FILES_PATH=/tmp/gnulinux-chroot

pacman -Rcs --noconfirm $(pacman -Qo /boot/zImage | cut -d' ' -f5) linux-firmware mkinitcpio
pacman -U --noconfirm ${CHROOT_FILES_PATH}/hybris/packaging/archlinux/*.pkg.tar.xz

ln -s /usr/lib/systemd/system/usb-tethering.service /etc/systemd/system/multi-user.target.wants/

groupmod -g 100000 alarm
usermod -g 100000 -u 100000 alarm
chgrp -R alarm /home/alarm/

