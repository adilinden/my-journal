---
layout: post
title:  "Building Unifi Controller on Raspberry Pi"
date:   2016-03-27 20:42:00
comments: yes
lightbox: no
tags:
  - raspberry pi
  - raspbian
  - opensource
  - embedded
categories:
  - Electronics
---

This post describes the process I uses to install the Unifi Controller software on a Raspberry Pi.  There were a few unusual steps required to address some issues of the particular version I was using.  Hopefully an upgrade is availalbe soon which would eliminate those additional manual steps.

## Versions

Java:             |  Oracle Java 8
Raspbian:         |  2016-02-09-raspbian-jessie-lite
Unifi Controller: |  4.8.12
RPi MAC:          |  b827.eb43.5384

## Prepare SD Card

### Flash the image

Insert the SD card and list the images.

{% highlight bash %}
diskutil list
{% endhighlight %}

Identify the disk (not partition) of the SD card, i.e. disk2.  Unmount the SD card by using the disk identifier (assuming this is disk2).

{% highlight bash %}
diskutil unmountDisk /dev/disk2
{% endhighlight %}

Copy the data to the SD card.

{% highlight bash %}
sudo dd bs=1m if=2016-02-09-raspbian-jessie-lite.img of=/dev/rdisk2
{% endhighlight %}

Since dd does not output anything by default, it is possible to query its progress by sending Ctrl-T.

### Use serial console

Upon successful flashing of the SD card it should be automatically mounted.  A minor edit is needed to support serial console instead of keyboard and monitor.

Edit /Volumes/boot/cmdline.txt and change

{% highlight bash %}
console=ttyAMA0,115200 console=tty1
{% endhighlight %}

to

{% highlight bash %}
console=tty1 console=ttyAMA0,115200
{% endhighlight %}

### Eject SD card

Finally eject the SD card.

{% highlight bash %}
sudo diskutil eject /dev/rdisk2
{% endhighlight %}

## First Boot

Insert the SD card into the Raspberry Pi. Attach the serial console cable. Attach power via the micro USB port.

Start the serial console on the Mac.

{% highlight bash %}
screen /dev/tty.usbserial 115200
{% endhighlight %}

Login using the default credentials of username: pi and password: raspberry.

### Resize the root partition

Determine the partitions we have.

{% highlight bash %}
pi@raspberrypi:~$ ls -al /dev/mm*
brw-rw---- 1 root disk 179, 0 Feb  9 16:06 /dev/mmcblk0
brw-rw---- 1 root disk 179, 1 Feb  9 16:06 /dev/mmcblk0p1
brw-rw---- 1 root disk 179, 2 Feb  9 16:06 /dev/mmcblk0p2
{% endhighlight %}

Determine the partition we need to extend using mount and df.  Most likely the partition to extend will be /dev/mmcblk0p2.

Examine the disk using fdisk.

{% highlight bash %}
pi@raspberrypi:~$ sudo fdisk -c -l /dev/mmcblk0

Disk /dev/mmcblk0: 15.6 GiB, 16777216000 bytes, 32768000 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: dos
Disk identifier: 0x34e4b02c

Device         Boot  Start     End Sectors  Size Id Type
/dev/mmcblk0p1        8192  131071  122880   60M  c W95 FAT32 (LBA)
/dev/mmcblk0p2      131072 2848767 2717696  1.3G 83 Linux
{% endhighlight %}

Now remove the partition using fdisk and recreate with larger size.

{% highlight bash %}
pi@raspberrypi:~$ sudo fdisk -c /dev/mmcblk0

Command (m for help): d
Partition number (1,2, default 2): 2

Partition 2 has been deleted.

Command (m for help): n
Partition type
   p   primary (1 primary, 0 extended, 3 free)
   e   extended (container for logical partitions)
Select (default p): p

Using default response p.
Partition number (2-4, default 2): 2
First sector (2048-32767999, default 2048): 131072
Last sector, +sectors or +size{K,M,G,T,P} (131072-32767999, default 32767999): 

Created a new partition 2 of type 'Linux' and of size 15.6 GiB.

Command (m for help): w
The partition table has been altered.
Calling ioctl() to re-read partition table.
Re-reading the partition table failed.: Device or resource busy

The kernel still uses the old table. The new table will be used at the next reboot or after you run partprobe(8) or kpartx(8).
{% endhighlight %}

Confirm that the new partition starts at the same sector and spans the whole disk using fdisk.

{% highlight bash %}
sudo fdisk -c -l /dev/mmcblk0.
{% endhighlight %}

Gracefully reboot the system

{% highlight bash %}
sudo reboot
{% endhighlight %}

Upon successful restart login, then resize the filesystem to match the partition size.

{% highlight bash %}
sudo resize2fs -p /dev/mmcblk0p2
{% endhighlight %}

We can check the filesystem for errors, to be sure we didn't introduce issues.

{% highlight bash %}
sudo fsck -p /dev/mmcblk0p2
{% endhighlight %}

Confirm success by looking at disks.

### System

Update the system.

{% highlight bash %}
sudo apt-get update
sudo apt-get upgrade
{% endhighlight %}

Set the time zone.

{% highlight bash %}
sudo dpkg-reconfigure tzdata
{% endhighlight %}

### Static IP

Raspbian does its own funky thing for networking.  Best way to add a static IP and keep things somewhat Debian is to edit /etc/network/interfaces

{% highlight bash %}
auto eth0
iface eth0 inet static
    address 172.23.21.15
    netmask 255.255.255.0
    gateway 172.23.21.1
    dns-nameservers 208.67.222.222 208.67.220.220
{% endhighlight %}

then adding the following to /etc/dhcpcd.conf

{% highlight bash %}
denyinterfaces eth0
{% endhighlight %}

## Unifi Controller

### Dependencies

Install the Java JDK.

{% highlight bash %}
sudo apt-get install oracle-java8-jdk
{% endhighlight %}

### Pre-configuration

Create or edit /etc/default/mongodb to read

{% highlight bash %}
# Disable system mongodb
ENABLE_MONGODB=no
DAEMON_OPTS=--smallfiles
{% endhighlight %}

### Installing the Unifi Controller Software

[Installation Using .deb File](#installation-using-deb-file)  
[Installation Using Unifi APT Repo](#installation-using-unifi-apt-repo)  

#### Installation Using .deb File

Download the .deb package from the Uniquity web site.  Note that direct download links are available from the software releases [UBNT Forum](https://community.ubnt.com/t5/UniFi-Updates-Blog/bg-p/Blog_UniFi).

Install package using dpkg and follow with apt-get to install dependencies.

{% highlight bash %}
dpgk -i unifi_4.7.6_all.deb
apt-get install -f
{% endhighlight %}

#### Installation Using Unifi APT Repo

Create /etc/apt/sources.list.d/100-ubnt.list with

{% highlight bash %}
## Debian/Ubuntu
# stable => unifi4
# deb http://www.ubnt.com/downloads/unifi/debian stable ubiquiti
deb http://www.ubnt.com/downloads/unifi/debian unifi4 ubiquiti
{% endhighlight %}

Add the GPG key

{% highlight bash %}
# for Ubiquiti
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv C0A52C50
{% endhighlight %}

Update and install

{% highlight bash %}
# retrieve the latest package information
sudo apt-get update

# install/upgrade unifi-controller
sudo apt-get install unifi
{% endhighlight %}

### Install Additional Fixes Manually

Per relase notes Unifi controller 4.8.12 does not support the Cloud Access feature on Linux/ARM.  It requires that this file be removed.  Without removing this file the controller will not start.

{% highlight bash %}
sudo rm /usr/lib/unifi/lib/native/Linux/armhf/libubnt_webrtc_jni.so
{% endhighlight %}

Per support forum thread controller 4.8.12 crashes on inform from AC AP with latest firmware (4.8.12 bundled) applied.  See [forum thread](https://community.ubnt.com/t5/UniFi-Wireless/Tried-upgrading-to-4-8-12-and-since-then-no-way-to-reach-the/m-p/1475318/) for details.

To address the issue download this file [http://central.maven.org/maven2/org/xerial/snappy/snappy-java/1.1.2/snappy-java-1.1.2.jar](http://central.maven.org/maven2/org/xerial/snappy/snappy-java/1.1.2/snappy-java-1.1.2.jar)

And install.

{% highlight bash %}
sudo cp snappy-java-1.1.2.jar /usr/lib/unifi/lib/snappy-java-1.0.5.jar
{% endhighlight %}

### Configuration

Since Debian automatically starts installed daemons we need to stop the Unifu controller now before tweaking the installation.

{% highlight bash %}
sudo systemctl stop unifi
{% endhighlight %}

Edit /var/lib/unifi/system.properties and add or edit this line:

{% highlight bash %}
unifi.db.extraargs=--smallfiles
{% endhighlight %}

This will prevent the mongodb journal files to grow to some unmanageable size.  It also helps to remove the /var/lib/unifi/db/journal directory, but do this with unifi STOPPED!

Configure the Unifi controller to use Oracle Java 8.

Create or edit /etc/default/unifi

{% highlight bash %}
# Use Oracle Java 8
JAVA_HOME=/usr/lib/jvm/jdk-8-oracle-arm32-vfp-hflt
{% endhighlight %}

Adjust the Java memory allocations.

{% highlight bash %}
sudo sed -i 's@-Xmx1024M@-Xmx384M@' /usr/lib/unifi/bin/unifi.init
{% endhighlight %}

### Startup

Tell systemd that we made changes.

{% highlight bash %}
sudo systemctl daemon-reload
{% endhighlight %}

Startup unifi.

{% highlight bash %}
sudo systemctl start unifi
{% endhighlight %}


## Maintenance

Run the attached script every so often to prune the database. Obtained original script from this [Forum Post](https://help.ubnt.com/hc/en-us/articles/204911424-UniFi-Remove-prune-older-data-and-adjust-mongo-database-size
).

This is how to execute the script:

{% highlight bash %}
mongo --port=27117 < mongo_prune_js.js
{% endhighlight %}

This is the script:

{% highlight java %}
// keep N-day worth of data
var days=7;

// change to false to have the script to really exclude old records
// from the database. While true, no change at all will be made to the DB
var dryrun=true;

var now = new Date().getTime(),
  time_criteria = now - days * 86400 * 1000,
  time_criteria_in_seconds = time_criteria / 1000;

print((dryrun ? "[dryrun] " : "") + "pruning data older than " + days + " days (" + time_criteria + ")... ");

use ace;
var collectionNames = db.getCollectionNames();
for (i=0; i<collectionNames.length; i++) {
  var name = collectionNames[i];
  var query = null;

  if (name === 'event' || name === 'alarm') {
    query = {time: {$lt:time_criteria}};
  }

  // rogue ap
  if (name === 'rogue') {
    query = {last_seen: {$lt:time_criteria_in_seconds}};
  }

  // removes vouchers expired more than '$days' ago
  // active and unused vouchers are NOT touched
  if (name === 'voucher') {
    query = {end_time: {$lt:time_criteria_in_seconds}};
  }

  // guest authorization
  if (name === 'guest') {
    query = {end: {$lt:time_criteria_in_seconds}};
  }

  // if an user was only seen ONCE, $last_seen will not be defined
  // so, if $last_seen not defined, lets use $first_seen instead
  // also check if $blocked or $use_fixedip is set. If true, do NOT purge the
  // entry no matter how old it is. We want blocked/fixed_ip users to continue
  // blocked/fixed_ip
  if (name === 'user') {
    query = { blocked: { $ne: true}, use_fixedip: { $ne: true}, $or: [
        {last_seen: {$lt:time_criteria_in_seconds} },
        {last_seen: {$exists: false}, first_seen: {$lt:time_criteria_in_seconds} }
      ]
    };
  }

  if (query) {
    count1 = db.getCollection(name).count();
    count2 = db.getCollection(name).find(query).count();
    print((dryrun ? "[dryrun] " : "") + "pruning " + count2 + " entries (total " + count1 + ") from " + name + "... ");
    if (!dryrun) {
      db.getCollection(name).remove(query);
      db.runCommand({ compact: name });
    }
  }
}

use ace_stat;
var collectionNames = db.getCollectionNames();
for (i=0; i<collectionNames.length; i++) {
  var name = collectionNames[i];
  var query = null;

  // historical stats (stat.*)
  if (name.indexOf('stat')==0) {
    query = {time: {$lt:time_criteria}};
  }

  if (query) {
    count1 = db.getCollection(name).count();
    count2 = db.getCollection(name).find(query).count();
    print((dryrun ? "[dryrun] " : "") + "pruning " + count2 + " entries (total " + count1 + ") from " + name + "... ");
    if (!dryrun) {
      db.getCollection(name).remove(query);
      db.runCommand({ compact: name });
    }
  }
}

if (!dryrun) db.repairDatabase();
{% endhighlight %}

