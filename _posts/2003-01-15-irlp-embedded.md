---
layout: post
title: IRLP Embedded
date: 2003-01-14 23:02:10
comments: 
lightbox: true
tags:
  - amateurradio
  - electronics
  - irlp
summary: This is the second IRLP node I created. The hardware for this node consisted of a Advantech PCM-4823L single board computer (SBC). This board was powered by an AMD 5x86 processor running at a blazing 133MHz. Most common PC interfaces were included, the notable exception was the lack of video support. The SIMM memory slot was filled with 32MB. Network connectivity was provided by an onboard NE2000 compatible 10base-T ethernet interface. A riser card that converted the PC/104 bus to two ISA slots was installed. This riser would hold the sound card and a temporary video card.
redirect_from:
  - /article/irlp-embedded/
category:
  - Amateur Radio
assets: resources/2003-01-15-irlp-embedded
---

{% include lightbox.html image="dcp01205-400x245.jpg" thumb="dcp01205-150x92.jpg" caption="Enclosure with connectors"  float="right" clear="right" %}
{% include lightbox.html image="dcp01202-400x223.jpg" thumb="dcp01202-150x83.jpg" caption="Front view"  float="right" clear="right" %}
{% include lightbox.html image="dcp01203-400x286.jpg" thumb="dcp01203-150x107.jpg" caption="SBC with riser and HDD installed"  float="right" clear="right" %}
{% include lightbox.html image="dcp01204-400x290.jpg" thumb="dcp01204-150x109.jpg" caption="SBC with riser and HDD installed"  float="right" clear="right" %}
{% include lightbox.html image="dcp01206-400x225.jpg" thumb="dcp01206-150x85.jpg" caption="Temporary video card"  float="right" clear="right" %}
{% include lightbox.html image="dcp01207-400x287.jpg" thumb="dcp01207-150x108.jpg" caption="Ready for operation"  float="right" clear="right" %}
{% include lightbox.html image="dcp01208-400x213.jpg" thumb="dcp01208-150x80.jpg" caption="Rear view"  float="right" clear="right" %}
{% include lightbox.html image="dcp01209-400x304.jpg" thumb="dcp01209-150x114.jpg" caption="IRLP board detail"  float="right" clear="right" %}
{% include lightbox.html image="dcp01210-400x247.jpg" thumb="dcp01210-150x93.jpg" caption="Ready to roll"  float="right" clear="right" %}
{% include lightbox.html image="dcp01437-600x273.jpg" thumb="dcp01437-150x68.jpg" caption="In operation"  float="right" clear="right" %}

This is the second IRLP node I created. The hardware for this node consisted of a Advantech PCM-4823L single board computer (SBC). This board was powered by an AMD 5x86 processor running at a blazing 133MHz. Most common PC interfaces were included, the notable exception was the lack of video support. The SIMM memory slot was filled with 32MB. Network connectivity was provided by an onboard NE2000 compatible 10base-T ethernet interface. A riser card that converted the PC/104 bus to two ISA slots was installed. This riser would hold the sound card and a temporary video card.

The RedHat Linux operating system was installed on a small 2.5" hard disk drive. The drive came from an old retired notebook computer. The intention was to eventually replace the HDD with a CompactFlash card.

The original IRLP hardware board was disected. The LEDs were removed and reinstalled with flexible leads. This allowed the LEDs to be mounted on the front panel of the enclosure to provide status information. The board itself was mounted with double sided foam tape. While not the most elegant solution it worked quite well considering that the board had no room for mounting holes.

A surplus switch mode power supply was utilized to power the IRLP computer.  While the SBC was perfectly happy with a single 5V power source, the sound card required 12V power. Without video card the power consumption of this computer was less than 10 Watt.

On the rear of the enclosure connectors for radio, serial port, network and power were installed. Due to the lack of rear panel real estate a second serial port connector could not be installed. Instead a hole and grommet were provided for access to the serial port. Most of the rear panel space was blocked on the inside by the riser card.

The series of pictures to the right shows the IRLP computer as it was put together. The last picture displays all the various pieces that made up the IRLP and APRS nodes. The stack on the left shows the APRS equipment.  From top to bottem are a 5V power supply for the APRS computer, the APRS computer, the packet node controller, a 12V power supply for the radio and an old Systcoms radio tuned to the local APRS frequency. The stack in the middle of this picture shows the IRLP power supply and computer.  To the right of the IRLP computer the CTCSS tone board is visible. This board was recycled from the previous IRLP system I built. Finally on the right are the Yaesu FT-2200 radio and the power supply.

This assortment of equipment was in operation for several months and performed quite well. The CPU speed and memory capacity of the embedded board were insufficient to run the EchoIRLP sofware which could provide access to the Echolink network. This was the reason for retiring this system eventually in favour of a more powerful PC.

IRLP resources:

* [IRLP Site](http://www.irlp.net)
* [IRLP Node Status](http://status.irlp.net)
* [IRLP Operating Guidelines](http://www.irlp.net/guidelines.html)
