---
layout: post
title: Create ISO image from CD/DVD with Mac OS X
date: 2010-10-19 13:15:22
comments: 
tags:
  - mac
  - osx

redirect_from:
  - /article/create-iso-mac-os-x/
category:
  - Sysadmin
assets: resources/2010-10-19-create-iso-mac-os-x
---

Some quick instructions on how to create an ISO image from a CD or DVD using Mac OS X. But sadly this has failed in creating iso images of some disks, such as Microsoft installer disks.

1. Insert source CD/DVD
2. Open a Terminal, to determine the CD/DVD drive drive, using the following command:
        $ drutil status
         Vendor   Product           Rev 
         OPTIARC  DVD RW AD-5960S   2AP5
        
                   Type: CD-ROM               Name: /dev/disk1
               Sessions: 1                  Tracks: 1 
           Overwritable:   00:00:00         blocks:        0 /   0.00MB /   0.00MiB
             Space Free:   00:00:00         blocks:        0 /   0.00MB /   0.00MiB
             Space Used:   65:11:67         blocks:   293392 / 600.87MB / 573.03MiB
            Writability: 
3. Unmount the disk with the following command:
        $ diskutil unmountDisk /dev/disk1
        Disk /dev/disk1 unmounted
4. Create the ISO file with the dd utility (may take some time):
        $ dd if=/dev/disk1 of=file.iso bs=2048
5. Test the ISO image by mounting the new file (or open with Finder):
        $ hdid file.iso
6. The ISO image can then be burnt to a blank CD/DVD.
