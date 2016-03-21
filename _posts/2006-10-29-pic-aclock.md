---
layout: post
title: Microchip PIC Analog Clock
date: 2006-10-28 20:25:51
comments: Yes
lightbox: true
tags:
  - clock
  - electronics
  - embedded
  - pic
summary: During the summer of 1998 I built yet another PIC based clock. I had an old LED analog clock kicking around. It was a CMOS logic design built from an ELV (a German electronics magazine) kit. The clock lost its time every single time there was the slightest brownout, it bothered me to no end. So I set out to reuse some of the parts and built a PIC based replacment. The most significant item on the feature list was a low power time keeping mode to keep the time ticking but the display dark during AC power loss. What can I say, it actually worked! The clock was able to keep time for several minutes running on just a larger capacitor (where the schematic says 'battery').
redirect_from:
  - /article/pic-aclock/
category:
  - Electronics
assets: resources/2006-10-29-pic-aclock
---

{% include lightbox.html image="aclock_face_400x345.jpg" thumb="aclock_face_150x129.jpg" caption="Clock face"  float="right" %}

During the summer of 1998 I built yet another PIC based clock. I had an old LED analog clock kicking around. It was a CMOS logic design built from an ELV (a German electronics magazine) kit. The clock lost its time every single time there was the slightest brownout, it bothered me to no end. So I set out to reuse some of the parts and built a PIC based replacment. The most significant item on the feature list was a low power time keeping mode to keep the time ticking but the display dark during AC power loss. What can I say, it actually worked! The clock was able to keep time for several minutes running on just a larger capacitor (where the schematic says 'battery').


The design utilized the PIC16C73A processor. The additional I/O ports were needed to drive the 80 LEDs on the face of the clock. The LEDs were arranged in a matrix like fashion and multiplexed. The main circuit was layed out on a protoboard. The LEDs were hot glued to the aluminium face plate and handwired using wirewrap wire. I had doubts about the longevity of the 'mess of wires' but the clock is still in working condition, 8 years later.

Files:

* [Circuit diagram]({{ site.baseurl }}/{{ page.assets }}/aclock_schematic.pdf)
* [Source code]({{ site.baseurl }}/{{ page.assets }}/aclock.asm)
* [Include file]({{ site.baseurl }}/{{ page.assets }}/16c73a.inc)
* [Hex file]({{ site.baseurl }}/{{ page.assets }}/aclock.hex)

{% include lightbox.html image="aclock_rear_400x454.jpg" thumb="aclock_rear_150x170.jpg" caption="Back of clock"  float="left" %}
{% include lightbox.html image="aclock_component_400x317.jpg" thumb="aclock_component_150x119.jpg" caption="Components"  float="left" %}
