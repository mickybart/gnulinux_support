#!/bin/bash

usage (){
        cat << EOF
Usage for $0 : $0 <android product output>

<android product output> :
        Path to Android product output folder (eg: /home/aosp/out/target/product/nozomi)

EOF
}

die () { echo "ERROR: ${1-UNKNOWN}"; exit 1; }

if [ $# -ne 1 ]; then
        usage
        exit 1
fi

CONFIG_H=$1/headers/private/android_filesystem_config.h

[ -f $CONFIG_H ] || exit -1

cat << EOGEN
# generate during makepkg by generate-android-users.sh 

####
# Variables

$(egrep '^#define AID' $CONFIG_H | sed 's/#define //;s/ \/\*.*//' | egrep -v 'AID_ROOT|AID_NOBODY' | awk '{print $1"="$2}')

####
# Hidden Post install

_post_install(){

	# Create groups

$(egrep '^    { "' $CONFIG_H | sed 's/^    { "//;s/",//;s/, },.*//' | egrep -v 'AID_ROOT|AID_NOBODY' | awk '{ print "\tgroupadd -g $"$2" "$1" &>/dev/null"}')

	# Create users

$(egrep '^    { "' $CONFIG_H | sed 's/^    { "//;s/",//;s/, },.*//' | egrep -v 'AID_ROOT|AID_NOBODY' | awk '{ print "\tuseradd -M -s /usr/bin/nologin -c \"Android ("$2")\" -g $"$2" -u $"$2" "$1" &>/dev/null"}')

} #end post_install()

####
# Hidden Post upgrade

_post_upgrade(){

	# IMPORTANT: we will not take care of uid/gid change and users to delete here.
	#            you need to take that into account into hybris-device.install script

	# Create missing groups

$(egrep '^    { "' $CONFIG_H | sed 's/^    { "//;s/",//;s/, },.*//' | egrep -v 'AID_ROOT|AID_NOBODY' | awk '{ print "\tgetent group "$1" >/dev/null 2>&1 || groupadd -g $"$2" "$1" &>/dev/null"}')

	# Create missing users

$(egrep '^    { "' $CONFIG_H | sed 's/^    { "//;s/",//;s/, },.*//' | egrep -v 'AID_ROOT|AID_NOBODY' | awk '{ print "\tgetent passwd "$1" >/dev/null 2>&1 || useradd -M -s /usr/bin/nologin -c \"Android ("$2")\" -g $"$2" -u $"$2" "$1" &>/dev/null"}')

} #end post_upgrade()

####
# Dump
#
#dump(){
#
#	# dump what is needed
#
#	cat << EOF
#
#		####
#		# Groups
#
$(egrep '^    { "' $CONFIG_H | sed 's/^    { "//;s/",//;s/, },.*//' | egrep -v 'AID_ROOT|AID_NOBODY' | awk '{ print "#\t\tgroupadd -g \\$"$2" "$1}')
#
#		####
#		# Users
#
$(egrep '^    { "' $CONFIG_H | sed 's/^    { "//;s/",//;s/, },.*//' | egrep -v 'AID_ROOT|AID_NOBODY' | awk '{ print "#\t\tuseradd -M -s /usr/bin/nologin -c \"Android ("$2")\" -g \\$"$2" -u \\$"$2" "$1}')
#
#EOF
#
#} # end dump

EOGEN


