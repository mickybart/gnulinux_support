#Archlinux ARM

[TOC]

##OTA
Flashing procedure can be specific per device so please refer to your ROM maintainer to flash your archlinux ota zip file.

A general flashing method is described in the `main.md` document if needed.

##Installation
###Quick overview
Archlinux for Android devices follow the spirit of Archlinux.
So once flashed, your device will reboot on a black screen and your system will be minimal without any specific packages installed about Android on it except `hybris-usb` and `dhcp`.

Those 2 packages are part of the OTA zip file to permit you to access your device with an usb cable.

###Connect your device
- Plug your device with the USB cable to your computer
- Check that an IP on the subnet 10.15.19.0/24 is set on your usb/ethernet interface (should be 10.15.19.100 or more)
- Connect to your device with `ssh alarm@10.15.19.82` *(passwd: alarm)*
- Now run `su -` *(passwd: root)*

**Don't forget to change root and alarm password**

###Internet access
Your device will need an internet access* (that can be done offline too but this solution is not documented)*.
To do that, we will [share the Internet connection](https://wiki.archlinux.org/index.php/Internet_sharing) of your computer. Please refer to your OS provider to apply the right procedure.

Once done, under your Android device run :
```
ip route add default via 10.15.19.100  #(adapt the IP)

cat << EOF > /etc/resolv.conf
nameserver 8.8.8.8
nameserver 8.8.4.4
EOF
```

Once done you can check that everything is fine by doing :
```
ping -4 www.archlinux.org
```

###Packages for base system
```
pacman -Syu
pacman -S sudo base-devel
pacman -S ttf-dejavu
```

Configure root permission for alarm user (already member of wheel group) with `visudo` or 
`sed -i 's|^# %wheel ALL=(ALL) NOPASSWD: ALL|%wheel ALL=(ALL) NOPASSWD: ALL|' /etc/sudoers`

Now let's go to install yaourt from AUR:
```
<ctrl+d> #to go back with alarm user
curl -L https://aur.archlinux.org/cgit/aur.git/snapshot/package-query.tar.gz -o package-query.tar.gz
tar -xzvf package-query.tar.gz
cd package-query
makepkg -s
sudo pacman -U --asdeps package-query-*.pkg.tar.xz

cd ..
curl -L https://aur.archlinux.org/cgit/aur.git/snapshot/yaourt.tar.gz -o yaourt.tar.gz
tar -xzvf yaourt.tar.gz
cd yaourt
makepkg
sudo pacman -U yaourt-*.pkg.tar.xz
```

Install rsync and git:
```
yaourt -S rsync git
```

To speed up compilation with distcc for ARM, please read archlinuxarm [documentation](https://archlinuxarm.org/wiki/Distcc_Cross-Compiling)

###Packages for Android device, Qt/Kwin, ...
**IMPORTANT: do not install packages built for another device. Some of them are really specific to your device and Android version (eg: libhybris, hybris-linux, hybris-device, ...). Please never install a kernel not adapted for your device (hybris-linux) !**

####Manual
**to run with alarm user**

Get PKGBUILDs from gnulinux_support to your device. eg:
```
cd ~
git clone https://github.com/mickybart/gnulinux_support
cp -r gnulinux_support/GNULinux/Archlinux/PKGBUILDs .
cd PKGBUILDs
```

Compilation step by step:
```
####
# Core

#hybris-linux-?-? that you need
cd hybris-linux-<brand>-<device>
#if not included, copy the hybris-linux.tgz that matching the device.
makepkg -s
sudo pacman -U --asdeps hybris-linux-*.pkg.tar.xz
cd ..

#schroot-hybris
cd schroot-hybris
makepkg -s
sudo pacman -U --asdeps schroot*.pkg.tar.xz
cd ..

#systemd-legacy
#compile it only if you need it. Check PKGBUILD of hybris-device-?-?
cd systemd-legacy
makepkg -s
sudo pacman -U --asdeps {libsystemd,systemd-legacy}-2*.pkg.tar.xz
sudo pacman -U systemd-sysvcompat*.pkg.tar.xz
cd ..

#hybris-device-?-? that you need
cd hybris-device-<brand>-<device>
#if not included, copy the hybris-device.tgz that matching the device.
makepkg -s
sudo pacman -U hybris-device-*.pkg.tar.xz
cd ..

#mesa-hybris
cd mesa-hybris
makepkg -s --skippgpcheck
sudo pacman -U mesa-hybris-*.pkg.tar.xz
cd ..

#libhybris_ext
cd libhybris-ext-git
makepkg -s
sudo pacman -U libhybris-ext-*.pkg.tar.xz
cd ..

#hybris-ready
cd hybris-ready
makepkg -s
sudo pacman -U hybris-ready-0.*.pkg.tar.xz
cd ..

sudo systemctl enable hybris-ready.service

####
# Qt and Kwin

#If you want to install all Qt5 group:
#sudo pacman -S qt5

cd qt5-wayland-compositor
makepkg -s
sudo pacman -U qt5-wayland-compositor-*.pkg.tar.xz
cd ..

cd qt5-qpa-hwcomposer-plugin
makepkg -s
sudo pacman -U qt5-qpa-hwcomposer-plugin-*.pkg.tar.xz
cd ..

cd qt5-qpa-surfaceflinger-plugin
makepkg -s
sudo pacman -U qt5-qpa-surfaceflinger-plugin-*.pkg.tar.xz
cd ..

cd kwin-hybris
makepkg -s
sudo pacman -U kwin-hybris-*.pkg.tar.xz
cd ..

####
# Boot Animation
# EXPERIMENTAL
cd hybris-ready
sudo pacman -U --asdeps hybris-ready-bootanim-0.*.pkg.tar.xz
cd ..
```

####AUR (yaourt)
**to run with alarm user**
```
####
# Core

yaourt -S hybris-ready hybris-device-<brand>-<device>  #(eg: hybris-device-sony-nozomi)

sudo systemctl enable hybris-ready.service

####
# Qt and Kwin

yaourt -S hybris-ready-qt5-qpa-meta
yaourt -S hybris-ready-plasma-support-meta

####
# Boot Animation
# EXPERIMENTAL
yaourt -S hybris-ready-bootanim
```

####Binaries
For now, binaries package are not released in a repository but if your device maintainer provides some binaries you can download and install them.

###Reboot
```
sudo systemctl isolate reboot
```

###Tests
####Kernel
Check if everything is fine with `dmesg`

####Android boot
Check Android logs (only if you have started hybris-ready.service) :
```
sdroid
logcat
<ctrl+c>
<ctrl+d>
```

####hybris
```
sudo -i
cd /opt/android/hybris/bin

#Don't run test like test_hwcomposer, test_glesv2... if you are using surfaceflinger (test_sf / test_ui)
#For more details on those tests check upstream documentation

./test_egl
./test_egl_configs
./test_vibrator
./test_...
```

####QML
Display a qml application (use OpenGL ES) :
```
git clone https://github.com/mickybart/hybris-ready-bootanim
cd hybris-ready-bootanim/bootanim
qmlscene-qt5 archlinux.qml
<ctrl+c>
```

####Kwin
Start a kwin wayland session with an application :
```
# install plasma-meta, kcalc... or alternative to have everything needed for this test.
sudo pacman -S plasma-meta kcalc

#dbus (do it only once)
export $(dbus-launch)

#We need to override this value to wayland. Kwin will use the right backend automatically (see kwin_wayland --help).
export QT_QPA_PLATFORM=wayland
kwin_wayland --libinput --xwayland /usr/bin/kcalc
<ctrl+c>

#Why not a full plasma session if plasma is installed ?
#you don't need to override QT_QPA_PLATFORM in this case
startplasmacompositor
```

##And now ?
Just install what you needs as on any GNU/Linux system !
We just build solid base to work on but the best is to come ! :)

##TODO - Developers section
###hybris-kernel
- [ ] 1. Integrate a flashing procedure during package update (custom per device) + *see if we can protect customer from itself to flash a wrong package*
- [ ] 2. Integrate a solution to create the boot.img + size limit check
- [ ] 3. kernel source compilation (+ prebuild gcc from AOSP) ??

With implementation of the first 2 points, it will be possible to create boot.img outside the Android build process.

For point 3, defconfig file should be part of hybris-kernel package. This point is not mandatory and we can works with a prebuilt kernel from AOSP. As every devices have a specific kernel that maybe doesn't make a lot of interest to do it.

###mkinitrd
*(dependency to point 1 and 2 of hybris-kernel)*
Use mkinitrd solution to generate an initramfs with specific hooks (crypto, snapshot, recovery, ...)

The important part is to create a minimal graphical interface that will permit us to handle some specific hooks like :
- enter a password to uncrypt the device
- boot on a snapshot (for device with btrfs)
- select the ROM to boot on (kexec + hard reboot)
- ...

This can be something like a new recovery solution oriented for GNU/Linux needs. Maybe based on TWRP or from scratch with Qt/QML ? (code size constraints are low if we use some space under /system that is uncrypted on Android devices. So /data will be able to be fully crypted - included binaries)

###kwin/libinput
- [ ] fix issue with libinput that doesn't seems to be initilized by kwin_wayland (`kwin_wayland --libinput --xwayland`)

###sddm
sddm is using QML/Qt and so it is a good fit to have a display manager.
- [ ] Check compatibility with Qt hwcomposer/surfacefinger backend or study a wayland support in addition of Xorg
- [ ] Convergence : theme for portrait mode
- [ ] Virtual keyboard

###Plasma-Mobile / Ofono / ...
- [ ] Provide a mobile phone experience

###Website for archlinux phone

- [ ] Discuss with archlinuxarm team to check if they can share some space (wiki/repositories/infra) for this project in their own website.
- [ ] Documentation into the archlinux wiki (mainly a rewrite of this one)
- [ ] Create our own archlinuxphone website and infrastructure (ONLY if it is not possible to be integrated into the archlinuxarm project)

