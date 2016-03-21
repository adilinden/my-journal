---
layout: post
title: Debian "Wheezy" On The BeagleBone
date: 2013-01-30 23:14:53
comments: 
tags:
  - arm
  - beaglebone
  - debian
  - electronics
  - embedded
  - opensource
  - programming

redirect_from:
  - /article/beaglebone-debian-wheezy/
category:
  - Electronics
assets: resources/2013-01-31-beaglebone-debian-wheezy
---

In my [previous post](beaglebone-first-impressions) about the BeagleBone I described how I installed Debian "Squeeze".  I had tried Debian "Wheezy" but it failed.  Today I retried the install of Debian "Wheezy" with the difference being of using a 4GB micro SD card.  Installing a different Debian release is very simple, just replace the mk_mmc.sh command with this instead:
{% highlight bash %}
    ./mk_mmc.sh --mmc /dev/sdb --uboot bone --distro wheezy-armhf
{% endhighlight %}
Since this is a netinstall procedure, it is important that the host system is prepared to provide ethernet connectivity via USB, or that an ethernet cable is connected to the BeagleBone.
