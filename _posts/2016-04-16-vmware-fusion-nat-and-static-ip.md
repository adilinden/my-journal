---
layout: post
title: VMware Fusion NAT and static IP
date: 2016-04-16 22:15:29 -0500
comments: yes
tags:
  - vmware
  - osx
category:
  - Sysadmin
---
VMware Fusion is a great product to virtualize machines on a Mac.  This post explains how to provide the same IP  address to the guest OS via DHCP and how to enable port forwarding.

### Static DHCP IP Address

Make sure the VM is shutdown, not suspended.  Open advanced options in VM settings.  Copy the MAC address, it should something similar to this:

    00:0C:29:8C:FF:0B

Modify `/Library/Preferences/VMware Fusion/vmnet8/dhcpd.conf` (use sudo) and add a static host entry.  Pay attention to the address pool and pick the right network for the fixed address.

    host myVM {
        hardware ethernet 00:0C:29:8C:FF:0B;
        fixed-address  192.168.178.80;
    }

### Port Forwarding

In this example I am forwarding local port 9889 to guest VM port 3389 for remote access to RDP on the gueat OS.

Modify `/Library/Preferences/VMware Fusion/vmnet8/nat.conf` (use sudo) and add a static port forwarding entry to our host.  This needs to go into the `[incomingtcp]` section.

    9889 = 192.168.178.80:3389

To restart the vmnet service execute the following commands in the terminal

    sudo /Applications/VMware\ Fusion.app/Contents/Library/vmnet-cli --stop
    sudo /Applications/VMware\ Fusion.app/Contents/Library/vmnet-cli --start

That's it... 
