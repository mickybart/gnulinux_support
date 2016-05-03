#!/sbin/sh

IMAGE=/data/gnulinux.tgz
DESTINATION=/data/media/_gnulinux

if [ -d $DESTINATION ]; then
        mv $DESTINATION $DESTINATION-$(date '+%s')
fi

mkdir -p $DESTINATION
tar --numeric-owner -xzf $IMAGE -C $DESTINATION
ERROR=$?

rm $IMAGE

exit $ERROR

