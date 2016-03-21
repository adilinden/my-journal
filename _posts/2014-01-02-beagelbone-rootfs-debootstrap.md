---
layout: post
title: Building a Beagelbone rootfs using debootstrap
date: 2014-01-01 22:31:56
comments: Yes
tags:
  - beaglebone
  - debian
  - opensource
  - programming
  - shell

redirect_from:
  - /article/beagelbone-rootfs-debootstrap/
category:
  - Coding
  - Electronics
assets: resources/2014-01-02-beagelbone-rootfs-debootstrap
---

The instructions in my [previous post][] about building an image for the Beagelbone Black rely on a pre-packaged root filesystem. Here are a few simple steps on how I build my own rootfs.

We need:
{% highlight bash %}
apt-get install debootstrap qemu-user-static
{% endhighlight %}

Run debootstrap, need to be root for all of these tasks.
{% highlight bash %}
mkdir -p /tmp/rootfs
debootstrap --no-check-gpg     --arch=armhf     --include=ssh     --foreign     wheezy /tmp/rootfs http://ftp.ca.debian.org/debian
{% endhighlight %}

Now perform any customizations needed. I.e. the rootfs changes in the [previous post][] instructions could be performed now.

Copy the qemu binary to the chroot future chroot.
{% highlight bash %}
cp /usr/bin/qemu-arm-static /tmp/rootfs/usr/bin/
{% endhighlight %}

Now chroot to the new install and run second stage debootstrap. Also create a place to mount uboot and create an archive of the file system.
{% highlight bash %}
chroot /tmp/rootfs /bin/bash
/debootstrap/debootstrap --second-stage
mkdir /boot/uboot
tar cpf archive.tar --exclude=qemu-arm-static --exclude=archive.tar .
exit
{% endhighlight %}

Cleanup.
{% highlight bash %}
rm /tmp/rootfs/usr/bin/qemu-arm-static
{% endhighlight %}

Now we have a complete proper root filesystem. The tar archive is at /tmp/rootfs/archive.tar.

Enjoy!

[previous post]: debian-wheezy-beaglebone-black
