#!/sbin/sh

CHROOT_FILE=/tmp/gnulinux-chroot.tgz
CHROOT_FILES_PATH=/tmp/gnulinux-chroot
ROOTFS=/data/media/_gnulinux

[ ! -d $ROOTFS ] && exit 1
    
mkdir -p ${CHROOT_FILES_PATH}
tar -xzf $CHROOT_FILE -C ${CHROOT_FILES_PATH} || exit 2

mount --bind /dev $ROOTFS/dev
mount --bind /proc $ROOTFS/proc
mount --bind /sys $ROOTFS/sys
mount --bind /tmp $ROOTFS/tmp

chroot $ROOTFS /bin/sh ${CHROOT_FILES_PATH}/hybris/packaging/*/postinstall.sh
ERROR=$?

umount $ROOTFS/tmp
umount $ROOTFS/proc
umount $ROOTFS/dev
umount $ROOTFS/sys

rm -rf ${CHROOT_FILES_PATH}
rm $CHROOT_FILE

exit $ERROR

