---
layout: post
title: Arduino Duemilanove
date: 2012-01-07 23:53:19
comments: Yes
lightbox: true
tags:
  - arduino
  - avr
  - electronics
summary: For some reason I had an ATmega168 and an ATmega328 sitting in my parts bins. To put them to use a couple bare PCB were ordered from a Chinese vendor on eBay. The boards I received were in superb condition. Most surface mount components were 0805 size, except for the FDTI chip of course.
redirect_from:
  - /article/arduino-duemilanove/
category:
  - Electronics
assets: resources/2012-01-08-arduino-duemilanove
---

{% include lightbox.html image="Duemilanove_1.jpg" thumb="Duemilanove_1-150x150.jpg" caption="Assembled Arduino Duemilanove"  float="left" %}

For some reason I had an ATmega168 and an ATmega328 sitting in my parts bins. To put them to use a couple bare PCB were ordered from a Chinese vendor on eBay. The boards I received were in superb condition. Most surface mount components were 0805 size, except for the FDTI chip of course.

The first component placed was the FTDI chip. It was soldered using the drag and wick method using my old rosin core solder. Since placing these I have received some new tips for my trusty Weller WTCP. I also acquired some no clean flux and solder. I am hoping to eliminate the wick when soldering SMD. The remainder of the SMD components were easily placed using the magnifier I received for Christmas. I can place 0805 components without magnifier but having the light and magnifications is much less strain on the eyes. The magnifier lamp also helps to place components accurately and nicely lined up. I choose to power the board strictly via USB. Therefore none of the regulator parts or power switching parts were populated. Just a small wire to permanently connect VUSB to VCC was needed to always power via USB.
<!-- more -->
I used the AVRISP mkII to burn the bootloader into the ATmega168 and ATmega328. I thought performing this function via the Arduino environment would be easy. The first attempt with the ATmega168 went flawless. However, when I went to program the ATmega328 some errors were printed and the programming aborted. After some digging around the [Arduino Forum](http://arduino.cc/forum/) I discovered that the Arduino Duemilanove used the ATmega328P, not the ATmega328. When attempting to program the chip I had reported a device ID that differed from what was expected. Fortunately I found the instruction to modify the Arduino environment to allow using the ATmega328. Unfortunately I did not make any notes on the process.

I do not like having bare boards laying around. Especially not once an Arduino has some shields stacked on it. The quest for an enclosure began. It didn't take long and I realized that these board could fit nicely into small Lock'n'Lock containers. They are in plenty supply in the Walmart food storage container isle. The plastic is very easily drilled or cut. Perfect to keep these boards safe from children and pets.

{% include lightbox.html image="Duemilanove_2.jpg" thumb="Duemilanove_2-150x150.jpg" caption="USB Access"  float="left" %}
{% include lightbox.html image="Duemilanove_3.jpg" thumb="Duemilanove_3-150x150.jpg" caption="In Lock'n'Lock"  float="left" %}
{% include lightbox.html image="LocknLock.jpg" thumb="LocknLock-150x150.jpg" caption="Lock'n'Lock"  float="left" %}
