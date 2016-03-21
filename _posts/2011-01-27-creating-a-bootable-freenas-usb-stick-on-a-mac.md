---
layout: post
title: Creating a Bootable FreeNAS USB Stick on a Mac
date: 2011-01-27 17:13:52
comments: Yes
tags:
  - mac
  - osx

redirect_from:
  - /article/creating-a-bootable-freenas-usb-stick-on-a-mac/
category:
  - Sysadmin
assets: resources/2011-01-27-creating-a-bootable-freenas-usb-stick-on-a-mac
---

Obtain the FreeNAS image. For this example I am using FreeNAS-amd64-embedded-0.7.2.5543.img. Have a USB stick on hand that hopefully supports booting.

Insert the USB stick into the MAC USB port. Open a terminal to find out which device the USB stick is.

    diskutil list


The output should be something like:

    /dev/disk0
       #:                       TYPE NAME                    SIZE       IDENTIFIER
       0:      GUID_partition_scheme                        *500.1 GB   disk0
       1:                        EFI                         209.7 MB   disk0s1
       2:                  Apple_HFS Macintosh HD            280.1 GB   disk0s2
       3:                  Apple_HFS Data                    219.5 GB   disk0s3
    /dev/disk2
       #:                       TYPE NAME                    SIZE       IDENTIFIER
       0:     FDisk_partition_scheme                        *4.0 GB     disk2
       1:             Windows_FAT_32 KINGSTON                4.0 GB     disk2s1


Since I am using a Kingston USB sick "disk2" is the device. This translates to "/dev/disk2".  Next unmount the disk:

    diskutil unmountDisk /dev/disk2


Then write the FreeNAS image to the USB stick:

    gunzip -c FreeNAS-amd64-embedded-0.7.2.5543.img | dd of=/dev/disk2


This should result in output like this:

    147168+0 records in
    147168+0 records out
    75350016 bytes transferred in 108.529822 secs (694279 bytes/sec)


Next eject the disk. This should ensure all data is written to the USB stick before we remove it.

    diskutil eject /dev/disk2


Finally, remove the USB stick from the USB port.


