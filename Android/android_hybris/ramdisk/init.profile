####
# USB
# Those information can be found into /init.<hardware>.usb.rc file

USB_IDVENDOR=0fce
USB_IDPRODUCT=7169
USB_IPRODUCT="Xperia S"
USB_ISERIAL="CB511W1UFR"

####
# /Data
#
# The system will be installed into the well known Android partition /data
#
# How to determine the device name :
#     Search the /data partition name (under Android look into the file /fstab.<hardware>)
#
#     eg : /dev/block/platform/msm_sdcc.1/by-num/p14   /data   [...]
#     
#     Than run under Android:
#       ls -l /dev/block/platform/msm_sdcc.1/by-num/p14
#       (output will look like: [...] p14 -> /dev/block/mmcblk0p14)
#
#     Now run 'cat /proc/partition' and you should see mmcblk0p14 (without /dev/block)
#     So mmcblk0p14 is the name to set into DATA_DEVICE
#     
# IMPORTANT: mmcblk0p14 is just an example. Replace with your value
#   
DATA_DEVICE="mmcblk0p14"

####
# Leds
#
# Brightness file of the red notification led.
# Will be used if the boot failed.
# This is NOT mandatory.
#NOTIFICATION_RED_LEDS=/sys/class/leds/red/brightness

####
# Possible override but should not be used
#
#Network interface used to set the ip (10.15.19.82) in case of an issue during boot
#(by default we will only try with usb0 or rndis0)
#USB_IFACE=
#
#Telnet port during early boot failure
#TELNET_PORT=23
#
#Location of the OS under /data
#DATA_ROOTFS=/data/media/_gnulinux/
#
#USB Manufacturer during early boot
#USB_IMANUFACTURER="GNU/Linux Device"
#
# see /init script for more details
