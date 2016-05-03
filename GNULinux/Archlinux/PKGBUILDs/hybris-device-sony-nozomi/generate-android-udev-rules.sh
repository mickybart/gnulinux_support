#!/bin/bash

usage (){
        cat << EOF
Usage for $0 : $0 <android root output>

<android root output> : 
        Path to Android output folder (eg: /home/aosp/out/target/product/nozomi/root)

EOF
}

die () { echo "ERROR: ${1-UNKNOWN}"; exit 1; }

if [ $# -ne 1 ]; then
        usage
        exit 1
fi

####
# init

ANDROID_OUT_PRODUCT=$1

if [ ! -d "$ANDROID_OUT_PRODUCT/" ]; then
	usage
	die "$ANDROID_OUT_PRODUCT is not a available. please build the boot image"
fi

[ ! -f "$ANDROID_OUT_PRODUCT/ueventd.rc" ] && die "ueventd.rc not found ! plese build the boot image"
HARDWARE=$(basename $(ls -1 $ANDROID_OUT_PRODUCT/ueventd.*.rc | head -1) | cut -d. -f2)
[ -z "$HARDWARE" ] && die "ueventd.<hardware>.rc not found ! plese build the boot image"

RULES_ANDROID=600-android-system.rules
RULES_HARDWARE=601-android-system-$HARDWARE.rules

####
# ueventd.rc

cat << EOF > $RULES_ANDROID
# BASE RULES
#
# Support Android (system/core/int/device.c) /dev structure
# log_* moved to /dev/alog/* instead of /dev/log/* because /dev/log is used by glibc (see bionic libhybris patch)

ACTION=="add", SUBSYSTEM=="graphics", SYMLINK+="graphics/%k", OWNER="root", GROUP="graphics", MODE="0660"
ACTION=="add", SUBSYSTEM=="drm", SYMLINK+="dri/%k", OWNER="root", GROUP="graphics", MODE="0666"
ACTION=="add", SUBSYSTEM=="oncrpc", SYMLINK+="oncrpc/%k", OWNER="root", GROUP="system", MODE="0660"
ACTION=="add", SUBSYSTEM=="adsp", SYMLINK+="adsp/%k", OWNER="system", GROUP="audio", MODE="0660"
ACTION=="add", SUBSYSTEM=="msm_camera", SYMLINK+="msm_camera/%k", OWNER="system", GROUP="system", MODE="0660"
ACTION=="add", SUBSYSTEM=="mtd", SYMLINK+="mtd/%k"
ACTION=="add", SUBSYSTEM=="block", SYMLINK+="block/%k"
ACTION=="add", SUBSYSTEM=="misc", KERNEL=="log_main", SYMLINK+="alog/main", OWNER="root", GROUP="log", MODE="0666"
ACTION=="add", SUBSYSTEM=="misc", KERNEL=="log_events", SYMLINK+="alog/events", OWNER="root", GROUP="log", MODE="0666"
ACTION=="add", SUBSYSTEM=="misc", KERNEL=="log_radio", SYMLINK+="alog/radio", OWNER="root", GROUP="log", MODE="0666"
ACTION=="add", SUBSYSTEM=="misc", KERNEL=="log_system", SYMLINK+="alog/system", OWNER="root", GROUP="log", MODE="0666"

# Extra permissions set from system/core/rootdir/ueventd.rc

EOF

cat $ANDROID_OUT_PRODUCT/ueventd.rc | grep ^/dev|sed -e 's/^\/dev\///'|awk '{printf "ACTION==\"add\", KERNEL==\"%s\", OWNER=\"%s\", GROUP=\"%s\", MODE=\"%s\"\n",$1,$3,$4,$2}' | sed -e 's/\r//' | egrep -v '"graphics/|"dri/|"oncrpc/|"adsp/|"msm_camera/|"log/' >> $RULES_ANDROID

####
# ueventd.<hardware>.rc

cat << EOF > $RULES_HARDWARE
# RULES for $HARDWARE
# 
# Based on root/ueventd.$HARDWARE.rc

EOF

cat $ANDROID_OUT_PRODUCT/ueventd.$HARDWARE.rc | grep ^/dev|sed -e 's/^\/dev\///'|awk '{printf "ACTION==\"add\", KERNEL==\"%s\", OWNER=\"%s\", GROUP=\"%s\", MODE=\"%s\"\n",$1,$3,$4,$2}' | sed -e 's/\r//' >> $RULES_HARDWARE

####
# check base rules override from ueventd.$HARDWARE.rc

sed -i 's|KERNEL=="graphics/\(.*\)|SUBSYSTEM=="graphics", KERNEL=="\1, SYMLINK+="graphics/%k"|' $RULES_HARDWARE
sed -i 's|KERNEL=="dri/\(.*\)|SUBSYSTEM=="drm", KERNEL=="\1, SYMLINK+="dri/%k"|' $RULES_HARDWARE
sed -i 's|KERNEL=="oncrpc/\(.*\)|SUBSYSTEM=="oncrpc", KERNEL=="\1, SYMLINK+="oncrpc/%k"|' $RULES_HARDWARE
sed -i 's|KERNEL=="adsp/\(.*\)|SUBSYSTEM=="adsp", KERNEL=="\1, SYMLINK+="adsp/%k"|' $RULES_HARDWARE
sed -i 's|KERNEL=="msm_camera/\(.*\)|SUBSYSTEM=="msm_camera", KERNEL=="\1, SYMLINK+="msm_camera/%k"|' $RULES_HARDWARE
sed -i 's|KERNEL=="mtd/\(.*\)|SUBSYSTEM=="mtd", KERNEL=="\1, SYMLINK+="mtd/%k"|' $RULES_HARDWARE

####
# hw_random

sed -i 's|ACTION=="add", KERNEL=="hw_random"\(.*\)|ACTION=="add", KERNEL=="hw_random"\1, SYMLINK+="hw_random"|' $RULES_ANDROID
sed -i 's|ACTION=="add", KERNEL=="hw_random"\(.*\)|ACTION=="add", KERNEL=="hw_random"\1, SYMLINK+="hw_random"|' $RULES_HARDWARE

if ! grep -q 'hw_random' $RULES_ANDROID && ! grep -q 'hw_random' $RULES_HARDWARE; then

	cat << EOF >> $RULES_ANDROID

# hw_random is named hwrng by systemd-udev so we need a symlink hw_random
ACTION=="add", SUBSYSTEM=="misc", KERNEL=="hw_random", SYMLINK+="hw_random"
EOF

fi


