# GNU/Linux for Android devices

[TOC]

## Quick overview
GNU/Linux for Android devices is a project to create a convergence between the desktop and the mobile/phablet... so to build new mobile OS based on existing GNU/Linux systems with the most common parts possible.

We share some common base between mer-hybris (SailfishOS) and Ubuntu Touch but the architecture and integration are not the same. This architecture is described in the section below and should fit for a lot of distributions. Archlinux ARM Phone is the first one to use this architecture.

So a new OS in the mobile world dominate by Android and iOS ? yes and no.
Archlinux, Fedora, Debian... those systems already exist, are stable and can run on a mobile phone. Graphical interface need to be adapated of course but keep in mind some project like [plasma-mobile](http://plasma-mobile.org/). KDE Team try to create some guideline about convergence for developers.

Imagine that your cell phone can become your core device ! Plug it to a big screen and this is your workstation ! Plug it to an empty laptop (no CPU, no RAM...) and this is your laptop ! Move everywhere and this is just your mobile phone !

This is what motivate this project.

Applications are critical on a mobile platform and we hope to support Android application as soon as possible.

Our reference device is a [Sony Xperia S](https://en.wikipedia.org/wiki/Sony_Xperia_S).
Our reference GNU/Linux distribution is [Archlinux](https://www.archlinux.org/) ([archlinuxarm](https://archlinuxarm.org/)).

## Architecture
### Schema
![architecture](https://github.com/mickybart/gnulinux_support/tree/master/Docs/res/architecture.png)

### Constraints
First of all, the libc used into Android (bionic) is not the same than the one used by GNU/Linux (glibc).
A lot of proprietary softwares (drivers, rild,...) are compiled for Android and so are not reusable directly into GNU/Linux.

Hopefuly some project like libhybris permit to use the Android Hardware from a GNU/Linux environment.

### Android and libhybris
libhybris is one of the most important library because it permit to use the Android Hardware from GNU/Linux.
To work, we need to use a modified version of Android. The Android section will provide more detail about those modifications and how to port them to a forked AOSP system like CyanogenMod.

### schroot
The Android integration inside the GNU/Linux system is done with a chroot solution. Precisely we are using a modified schroot that permit to support an Android environment.
This approch is different than the two other known implementation from SailfishOS and Ubuntu Touch.
As every implementation, there are some pros and cons.

schroot permit to isolate the Android environment and to support legacy stuff like /etc symlink. That permit to simplify the Android portage job.
In the same time, we share some filesystem with the GNU/Linux system (eg: /proc, /dev) so it is possible, for example, to use properties directy from GNU/Linux and Android (getprop/setprop).

schroot permit to join the chroot and to run commands when we want (session support). So it is possible to create some services or commands that can be run from GNU/Linux to interact easily with Android into the chroot.

This solution permit to have a clean rootfs. Only a symlink /vendor and /system are present on the rootfs due to some libs constraints.

### Hwcomposer and SurfaceFlinger
For the renderer, we can use hwcomposer (hwc) direcly but we support SurfaceFlinger too.
It is possible that some device are not working with the direct use of hwc implementation and so that the device will need some troubleshooting and bug fixes.
So to avoid the frustration of the black screen we decided to support the native composer (SurfaceFlinger) of Android as a possibilty. A backend plugin for Qt 5 and Kwin are available.

### Wayland
We are using wayland on top of Android Hw. libhybris is compiled with a support of libwayland that replace the mesa implementation to be compatible with Android devices.

We are using Kwin as our wayland server.

### Systemd
We are using systemd as init.

Android init is fully integrated as a service controlled by systemd. cgroups are used to track Android process and permit to cleanly stop Android environment inside GNU/Linux environment.

Due to old kernel (3.4) used on a lot of Android devices, we are using a modified systemd version that bring back the support to load firmware from userspace by systemd-udev request. This version is not mandatory and devices with recent kernel can use the upstream systemd.

## Android
##### GNULINUX\_SUPPORT
For remember, we need a modified Android version. To do that we have introduced GNULINUX_SUPPORT as a define for C/C++ and as a boolean variable for Makefiles.

```
Inside a Makefile:

ifeq ($(GNULINUX_SUPPORT),true)
# make rules for GNU/Linux Android
else
# make rules for Android
endif

Inside a C/C++ code:

#ifdef GNULINUX_SUPPORT
/* code for GNU/Linux Android */
#else
/* code for Android */
#endif

```

So GNULINUX_SUPPORT permit to have a common AOSP code to build an Android system or a modified Android system for GNU/Linux.

That will permit custom ROM based on AOSP like CyanogenMod, Omnirom and others to integrate those patches upstream. So devices porters will be able to focus only on the device tree to adapt it for GNU/Linux.

##### AOSP 5.1.1
We have created a [local_manifest.xml](https://github.com/mickybart/android_manifest/tree/gnulinux-support-5.1) that can be used to add GNULINUX_SUPPORT for AOSP 5.1.1.

Please to find modified repositories:
- [bionic](https://github.com/mickybart/android_bionic/tree/gnulinux-support-5.1)
- [build](https://github.com/mickybart/android_build/tree/gnulinux-support-5.1)
- [frameworks/native](https://github.com/mickybart/android_frameworks_native/tree/gnulinux-support-5.1)
- [system/core](https://github.com/mickybart/android_system_core/tree/gnulinux-support-5.1)

##### AOSP 6.0
TODO

##### CyanogenMod 12.1 / 13.0
Nothing is ported yet because we have no device with CyanogenMod (CM) but we hope that patches done for AOSP will be ported upstream to CM in the future.

##### Android 4.x
We are not supporting any patches for Android 4.x mainly because this version is not supported anymore by Google.
That doesn't mean that it is not possible to use it. Of course the device hardware need to be enough powerful to support a GNU/Linux system.
We will not define what powerful means because it depends of the distribution used, if you want the graphical stack, etc. For exemple if you want a GNU/Linux system with console only to be able to send SMS, share 3G, etc... an old device can fit :)

For example, this project is developped with a Sony Xperia S phone (that was released with Android 2.3 and at the end with Android 4.1.)

## GNU/Linux
##### Archlinux
Fully supported ([Documentation](https://github.com/mickybart/gnulinux_support/tree/master/Docs/archlinux.md)).
TODO: Archlinux wiki documentation

##### What about others ?
To be fully compatible with this project, the heavy work has to be done by packagers of every distributions. The effort is to port packages based on the archlinux implementation to other distribution packaging system (.deb, .rpm, ...).

To simplify this works, the target distribution needs to support:
- ARM architecture
- systemd
- Qt 5.6
- plasma 5.6

To support OTA build, distributions need to be defined in the [gnulinux_support project](https://github.com/mickybart/gnulinux_support/tree/master/Android/android_hybris/packaging)

## Supported device
### Installation
**IMPORTANT: We are not responsible of any damage caused to your device. This is up to you to check that everything is done in the right way. Please discuss with the ROM maintainer before if needed**

Procedure can be slightly different per device so you should read specific instruction provided by the ROM maintainer.

The general procedure would be similar to this one :
- Download the zip file for your device
- Upload the zip file to your Android device
- Reboot into the recovery (eg: TWRP) to install the zip file
- Reboot into the system

For 'minimal' distribution, extra steps can be needed :
- Connect your device by usb to your computer
- Connect by ssh to your device (default ip should be 10.15.19.82)
- Continue the installation by following distribution instruction

### Source
Follow instruction of the maintainer of your device to compile Android with GNULINUX_SUPPORT and to create the OTA package.
you can read the New device section to have a better understanding of the process.

## New device
On this section, you will discover how to port a new device.

### Android version
First of all, your device need to have a working Android version to start from.

==*It is not mandatory that the installed Android system on your device matches the Android system used for the GNU/Linux support **BUT** you need to be sure that firmware levels are the same between those versions.*==

Now you need to check in Android section if your Android version is already supported. If this is not the case, you can port patches to your Android version by `git cherry-pick` patches done for AOSP 5.1.1 or 6.0.

Refer to Android/AOSP 5.1.1 or Android/AOSP 6.0 where you will find all the repositories that need your attention.

If possible try to push upstream your patches but don't forget to respect the GNULINUX_SUPPORT implementation (read Android/GNULINUX_SUPPORT)

### Device tree
On the device tree you need to create a new gnulinux product that will set GNULINUX_SUPPORT to true.

Please edit or create the 3 files below :
*(Don't forget to replace device_name by the name of your device)*

`vim device/<company_name>/<device_name>/gnulinux_<device_name>.mk`

```
    GNULINUX_SUPPORT := true
    GNULINUX_OTA_OS := archlinux
    GNULINUX_OTA_ARCH := armv7
    $(call inherit-product, device/<company_name>/<device_name>/aosp_<device_name>.mk)
    PRODUCT_NAME := gnulinux_<device_name>
```
`vim device/<company_name>/<device_name>/vendorsetup.sh`
```
    [...]
    add_lunch_combo gnulinux_<device_name>-userdebug
```

`vim device/<company_name>/<device_name>/AndroidProduct.mk`
```
[...]
        $(LOCAL_DIR)/gnulinux_<device_name>.mk
```

Once done, you will have to adapt what need to be for compatibility with GNU/Linux. That can be:
- Rename mount path to /dev/block/mmcblk0p... (platform path not yet supported)
- Remove SELinux context for mount options (not yet supported)
- Remove usb management because it will not be handle by Android *(nothing to do if everything is part of init.usb.rc)*
- Set the defconfig file for GNU/Linux kernel *(see Kernel section)*
- Define the BOARD_HYBRIS_RAMDISK_INIT_PROFILE and init.profile file

To help you, you can check commits done for Nozomi device:
- [new GNU/Linux product](https://github.com/mickybart/device_sony_nozomi/commit/c75945f71ef93b6615b117ecef4324fad3940236)
- [GNU/Linux: Nozomi adaptation](https://github.com/mickybart/device_sony_nozomi/commit/f93afcffc44ff151730c23af5bc65a82f55ece76)

### Kernel
Due to incompatible features, you can't use directly the Android kernel and you will have to change some parameters.

To adapt the kernel, you can compile it outside of you AOSP project by following the [Google guide](http://source.android.com/source/building-kernels.html) or directly inside your AOSP project.

To help you, under your AOSP repository, you can use the command `gnulinux_support/GNULinux/kernel-check/mer_verify_kernel_config <path to .config file>` to verify and adapt the `.config` file

This file is located inside AOSP project under `out/target/product/<device>/obj/KERNEL_OBJ/.config` or if you are compiling the kernel outside, directly to the root of your kernel.

**IMPORTANT: CONFIG_AUDIT and SELinux:**
```
mer_verify_kernel_config can complain about CONFIG_AUDIT but keep it to y if your kernel is set with SELinux.
For this case, you will have to add extra parameters not checked by the tool :
CONFIG_SECURITY_SELINUX_BOOTPARAM=y
CONFIG_SECURITY_SELINUX_BOOTPARAM_VALUE=1
And to add selinux=0 to the CMDLINE of your Kernel
```

**Common issue:**
if gnulinux_support/GNULinux/kernel-check/ is empty, rerun `repo sync --fetch-submodules`


### Compilation
First of all you need to prepare your enviroment for Android compilation.
Please, read the Google [documentation](http://source.android.com/source/requirements.html) or the one of your custom AOSP ROM.

For a pure AOSP 5.1.1 that will look like this :

```
BRANCH=gnulinux-support-5.1
DEVICE=<device name>
URL=https://github.com/mickybart/android_manifest

repo init -u $URL -b $BRANCH

mkdir .repo/local_manifests/
ln -s ../manifests/local_manifest.xml .repo/local_manifests/local_manifest.xml

repo sync --fetch-submodules

source build/envsetup.sh
lunch gnulinux_$DEVICE-userdebug

# build the ota package for the distribution reported by 'lunch'
make otapackage

# build hybris-*.tgz needed for your distribution and device
make hybris
```

Once done, you should have those files under out/target/product/... folder:
- hybris-device.tgz
- hybris-linux.tgz
- "ota_name".zip (eg: archlinux-armv7-nozomi.zip)

**IMPORTANT: cleanup**

If you need to regenerate hybris-\*.tgz files after some modifications, it is safer to delete some files prior under out/target/product/"device"/ folder : `rm -rf hybris-* ramdisk.img`


### Installation
**IMPORTANT: We are not responsible of any damage caused to your device. This is up to you to check that everything is fine and will fit for your device (specially the kernel part).**

- Create a backup of your device.
- Fash the ota file
- Reboot

For 'minimal' distribution, extra steps can be needed :
- Connect your device by usb to your computer
- Connect by ssh to your device (default ip should be 10.15.19.82)

In case of a boot issue, you should see the red notification led if it is configured in the init.profile of the device tree.
To debug the boot sequence, it is possible to connect with telnet to the device by doing those tasks :
- Connect your device by usb to your computer
- run `lsusb -v | grep iSerial`  (you should see something like 'Debug: telnet 10.15.19.82:23 (no dhcp)')
- Configure your computer network interface to be on the same lan than your device (that should be 10.15.19.0/24)
- Connect by telnet to your device (`telnet 10.15.19.82 23`). You will have some information to troubleshoot the issue once logged.

### GNU/Linux packaging
You should now be able to connect on your device and so it is time to create your binaries packages specific to your device and Android version. This is where we will used files generated by `make hybris`.

Per distribution:
- [archlinux](https://github.com/mickybart/gnulinux_support/tree/master/Docs/archlinux.md)


## Source code
### Projects

Android :
- manifest ([5.1.1](https://github.com/mickybart/android_manifest/tree/gnulinux-support-5.1))
- build ([5.1.1](https://github.com/mickybart/android_build/tree/gnulinux-support-5.1))
- bionic ([5.1.1](https://github.com/mickybart/android_bionic/tree/gnulinux-support-5.1))
- frameworks/native ([5.1.1](https://github.com/mickybart/android_frameworks_native/tree/gnulinux-support-5.1))
- system/core ([5.1.1](https://github.com/mickybart/android_system_core/tree/gnulinux-support-5.1))
- [gnulinux_support](https://github.com/mickybart/gnulinux_support)

GNU/Linux Core :
- [kwin-hybris](https://github.com/mickybart/kwin) (with SurfaceFlinger backend)
- [libhybris_ext](https://github.com/mickybart/libhybris_ext) (With custom compatibility support)
- [qt5-qpa-hwcomposer-plugin](https://github.com/mickybart/qt5-qpa-hwcomposer-plugin) (With Qt 5.6 support)
- [qt5-qpa-surfaceflinger-plugin](https://github.com/mickybart/qt5-qpa-surfaceflinger-plugin)
- [schroot](https://github.com/mickybart/schroot) (With Android support)
- systemd-legacy (With userspace firmware loading for old kernel)

Archlinux Integration :
- [PKGBUILDs](https://github.com/mickybart/gnulinux_support/tree/master/GNULinux/Archlinux/PKGBUILDs) (hybris-ready, hybris-usb, mesa-hybris, schroot-hybris, hybris-device-sony-nozomi, hybris-linux-sony-nozomi, kwin-hybris, schroot-hybris, ...)

### Upstream ?
This project is in an early stage and so we have to prove that our solution is working and of quality.

We are developing everything with a future upstream support in mind so the code released should be able to be pushed upstream directly or with minor adaptation. We are working for convergence between GNU/Linux desktop and the mobile/tablet so this is not to maintain fork of projects in a long term :)

Some of them are already be pushed but not necessary approved/committed yet.

We will update this section with our progress on this topic.

## Authors
Michaël Serpieri <mickybart@pygoscelis.org>
