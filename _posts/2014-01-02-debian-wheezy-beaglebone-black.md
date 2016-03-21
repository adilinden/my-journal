---
layout: post
title: Building Debian Wheezy (7.3) for Beaglebone Black
date: 2014-01-01 19:31:54
comments: Yes
lightbox: true
tags:
  - arm
  - beaglebone
  - debian
  - embedded
  - opensource
  - shell
summary: Just some quick and dirty instructions on how I built a Beaglebone Black disk image from scratch. This provides a read-only root filesystem.
redirect_from:
  - /article/debian-wheezy-beaglebone-black/
category: Electronics
assets: resources/2014-01-02-debian-wheezy-beaglebone-black
---

{% include lightbox.html image="IMG_1285-600x450.jpg" thumb="IMG_1285-150x150.jpg" caption="Beaglebone Black"  float="right" %}

Just some quick and dirty instructions on how I built a Beaglebone Black disk image from scratch. A big thanks to Robert C. Nelson for the Open Source tools and instructions at [Linux Arm on Beaglebone Black][] that this relies on.

I am sharing the steps I performed here because I built a read-only root filesystem. It is not perfect as it throws a couple of errors during the boot sequence. But those errors are by no means fatal and can be ignored.

**Setting up pre-requisites**

Same packages are needed in order to build.
{% highlight bash %}
apt-get install git
git config --global user.email un@b.com
git config --global user.name "User Name"
{% endhighlight %}

Packages needed for the device tree compiler
{% highlight bash %}
apt-get install bison build-essential flex git-core
{% endhighlight %}

Packages needed for the kernel build
{% highlight bash %}
apt-get install device-tree-compiler lzma lzop u-boot-tools libncurses5-dev
{% endhighlight %}

For disk formatting.
{% highlight bash %}
apt-get install dosfstools
{% endhighlight %}

**Setting up cross compile environment**

Our build machine is Debian Wheezy x86_64. Linaro gcc is 32-bit and needs additional 32-bit binaries.
{% highlight bash %}
dpkg --add-architecture i386
apt-get update
apt-get install libc6:i386 libstdc++6:i386 libncurses5:i386 zlib1g:i386
{% endhighlight %}

Install Linaro gcc compiler for ARM.
{% highlight bash %}
wget -c https://launchpad.net/linaro-toolchain-binaries/trunk/2013.10/+download/gcc-linaro-arm-linux-gnueabihf-4.8-2013.10_linux.tar.xz
tar xJf gcc-linaro-arm-linux-gnueabihf-4.8-2013.10_linux.tar.xz
export CC=`pwd`/gcc-linaro-arm-linux-gnueabihf-4.8-2013.10_linux/bin/arm-linux-gnueabihf-
${CC}gcc --version
{% endhighlight %}

The last command should provide this kind of output. Otherwise there is a library install issue.
{% highlight bash %}
arm-linux-gnueabihf-gcc ...
{% endhighlight %}

**Building U-Boot**

Obtain u-boot sources.
{% highlight bash %}
git clone git://git.denx.de/u-boot.git
cd u-boot/
{% endhighlight %}

Patch U-Boot
{% highlight bash %}
wget -c https://raw.github.com/eewiki/u-boot-patches/master/v2013.10/0001-am335x_evm-uEnv.txt-bootz-n-fixes.patch
patch -p1 < 0001-am335x_evm-uEnv.txt-bootz-n-fixes.patch
{% endhighlight %}

Or get patched sources.
{% highlight bash %}
git clone https://github.com/adilinden/u-boot.git
cd u-boot/
git checkout v2013.10 -b tmp
{% endhighlight %}

Build U-Boot
{% highlight bash %}
make ARCH=arm CROSS_COMPILE=${CC} distclean
make ARCH=arm CROSS_COMPILE=${CC} am335x_evm_config
make ARCH=arm CROSS_COMPILE=${CC}
cd ..
{% endhighlight %}

**Build the device tree compiler**

Upgrade device tree compiler package. If this script throws an error about 'sudo: not found', then just manual install those packages. Still need to run the script!
{% highlight bash %}
wget -c https://raw.github.com/RobertCNelson/tools/master/pkgs/dtc.sh
chmod +x dtc.sh
./dtc.sh
{% endhighlight %}

**Build the kernel**

Get Kernel. (This isn't really necessary as the next step would clone the kernel repo. But I wanted a local kernel repo for other tasks, too.)
{% highlight bash %}
git cone git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git
{% endhighlight %}

Get the kernel build scripts.
{% highlight bash %}
git clone git://github.com/RobertCNelson/linux-dev.git
cd linux-dev/
cp system.sh.sample system.sh
{% endhighlight %}

Edit the script to clone out local kernel repo. Edit the following lines to read like this:
{% highlight bash %}
CC=~/gcc-linaro-arm-linux-gnueabihf-4.8-2013.10_linux/bin/arm-linux-gnueabihf-
LINUX_GIT=~/linux-stable/
{% endhighlight %}

Build the kernel (3.8).
{% highlight bash %}
git checkout origin/am33x-v3.8 -b tmp-3.8
./build_kernel.sh
cd ..
{% endhighlight %}

**Prepare the SD card**

We are using a HD partition to experiment. Be careful here and be sure what disk device you are using. Very easy to nuke the local filesystem and require a rebuild of the build machine.
{% highlight bash %}
export DISK=/dev/sdc
{% endhighlight %}

Erase the disk.
{% highlight bash %}
dd if=/dev/zero of=${DISK} bs=1M count=16
{% endhighlight %}

Create partition layout.
{% highlight bash %}
fdisk $DISK
Command: n
Select: p
Partition: 1
First:
Last: +48M
Command: t
Hex Code: e
Command: a
Partition: 1
Command: n
Select: p
Partition: 2
First:
Last: +1024M
Command: w
{% endhighlight %}

This is what we want.
{% highlight bash %}
Device Boot      Start         End      Blocks   Id  System
/dev/sdd1   *        2048      100351       49152    e  W95 FAT16 (LBA)
/dev/sdd2          100352     7626751     3763200   83  Linux
{% endhighlight %}

Format partitions.
{% highlight bash %}
mkfs.vfat -F 16 ${DISK}1 -n boot
mkfs.ext4 ${DISK}2 -L rootfs -O ^has_journal
{% endhighlight %}

Make partition mount points.
{% highlight bash %}
mkdir -p /tmp/boot/
mkdir -p /tmp/rootfs/
{% endhighlight %}

Mount volumes.
{% highlight bash %}
mount ${DISK}1 /tmp/boot/
mount ${DISK}2 /tmp/rootfs/
{% endhighlight %}

Install bootloader.
{% highlight bash %}
cp -v ./u-boot/MLO /tmp/boot/
cp -v ./u-boot/u-boot.img /tmp/boot/
{% endhighlight %}

Create /tmp/boot/uEnv.txt
{% highlight bash %}
#u-boot eMMC specific overrides; Angstrom Distribution (BeagleBone Black) 2013-06-20
kernel_file=zImage
initrd_file=uInitrd

loadzimage=load mmc ${mmcdev}:${mmcpart} ${loadaddr} ${kernel_file}
loadinitrd=load mmc ${mmcdev}:${mmcpart} 0x81000000 ${initrd_file}; setenv initrd_size ${filesize}
loadfdt=load mmc ${mmcdev}:${mmcpart} ${fdtaddr} /dtbs/${fdtfile}
#

console=ttyO0,115200n8
mmcroot=/dev/mmcblk0p2 ro
mmcrootfstype=ext4 rootwait fixrtc

##To disable HDMI/eMMC...
#optargs=capemgr.disable_partno=BB-BONELT-HDMI,BB-BONELT-HDMIN,BB-BONE-EMMC-2G

##3.1MP Camera Cape
#optargs=capemgr.disable_partno=BB-BONE-EMMC-2G

mmcargs=setenv bootargs console=${console} root=${mmcroot} rootfstype=${mmcrootfstype} ${optargs}

#zImage:
uenvcmd=run loadzimage; run loadfdt; run mmcargs; bootz ${loadaddr} - ${fdtaddr}

#zImage + uInitrd: where uInitrd has to be generated on the running system.
#boot_fdt=run loadzimage; run loadinitrd; run loadfdt
#uenvcmd=run boot_fdt; run mmcargs; bootz ${loadaddr} 0x81000000:${initrd_size} ${fdtaddr}
{% endhighlight %}

Install root filesystem.
{% highlight bash %}
wget -c https://rcn-ee.net/deb/minfs/wheezy/debian-7.3-minimal-armhf-2013-12-18.tar.xz
tar xJvpf ./debian-7.3-minimal-armhf-2013-12-18.tar.xz
tar xpf debian-7.3-minimal-armhf-2013-12-18/armhf-rootfs-debian-wheezy.tar -C /tmp/rootfs
{% endhighlight %}

Copy the kernel.
{% highlight bash %}
cp -v ./linux-dev/deploy/*.zImage /tmp/boot/zImage
mkdir -p /tmp/boot/dtbs/
tar xfov ./linux-dev/deploy/*-dtbs.tar.gz -C /tmp/boot/dtbs/
tar xfov ./linux-dev/deploy/*-firmware.tar.gz -C /tmp/rootfs/lib/firmware/
tar xfov ./linux-dev/deploy/*-modules.tar.gz -C /tmp/rootfs/
{% endhighlight %}

Edit /tmp/rootfs/etc/fstab.
{% highlight bash %}
/dev/mmcblk0p2   /           ext4   ro,noatime                0   0
/dev/mmcblk0p1   /boot/uboot vfat   ro,user,umask=000         0   0
tmpfs            /tmp        tmpfs  nodev,nosuid,size=10m     0   0
tmpfs            /var/log    tmpfs  nodev,nosuid,size=10m     0   0
tmpfs            /var/tmp    tmpfs  nodev,nosuid,size=10m     0   0
{% endhighlight %}

Edit /tmp/rootfs/etc/networking/interfaces.
{% highlight bash %}
# interfaces(5) file used by ifup(8) and ifdown(8)
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet dhcp

allow-hotplug usb0
iface usb0 inet dhcp
{% endhighlight %}

Edit /tmp/rootfs/etc/inittab.
{% highlight bash %}
T0:23:respawn:/sbin/getty -L ttyO0 115200 vt102
{% endhighlight %}

Create /tmp/rootfs/etc/init/serial.conf.
{% highlight bash %}
start on stopped rc RUNLEVEL=[2345]
stop on runlevel [!2345]
 
respawn
exec /sbin/getty 115200 ttyO0
{% endhighlight %}

Be done with SD card.
{% highlight bash %}
sync
umount /tmp/rootfs
umount /tmp/boot
{% endhighlight %}

**After system is installed**

Boot Beaglebone Black with the new SD card. Use the serial console cable to access the root prompt. The username/password are root/root.

To make permanent changes the root filesystem needs to be mounted read-write. This is easily done:
{% highlight bash %}
mount -o remount,rw /
{% endhighlight %}

Enjoy!

[Linux Arm on Beaglebone Black]: http://eewiki.net/display/linuxonarm/BeagleBone+Black

