---
layout: post
title: Servo Tester
date: 2006-11-11 23:36:10
comments: 
lightbox: true
tags:
  - electronics
  - embedded
  - pic
  - r/c
  - servotester
summary: I needed a device to test R/C servos. Hooking up receiver, battery, servos and then running the transmitter with the antenna extended inside the house was awkward. I thought this could be a nice little project for some microcontroller. After a long abstinence from PIC assembler, I downloaded the latest MPLAB release and programmed away. Here it is, the first cut of my servo tester.
redirect_from:
  - /article/pic-servo-tester/
category:
  - Electronics
assets: resources/2006-11-12-pic-servo-tester
---

{% include lightbox.html image="servo-tester-a-400x259.jpg" thumb="servo-tester-a-150x97.jpg" caption="Serpac C-6"  float="right" %}

I needed a device to test R/C servos. Hooking up receiver, battery, servos and then running the transmitter with the antenna extended inside the house was awkward. I thought this could be a nice little project for some microcontroller. After a long abstinence from PIC assembler, I downloaded the latest MPLAB release and programmed away. Here it is, the first cut of my servo tester.

Unfortunately my old parallel port PIC programmer was no longer supported. Since serial ports appear to be a dying breed, a USB programmer was needed. The PICkitII looked like an inexpensive but decent programmer. With support for nearly all current (and many old) PIC devices it was ordered from DigiKey. The PICkitII worked out well, it even supported powering the target from the host PC's USB port.

{% include lightbox.html image="servo-tester-a-layout-657x470.png" thumb="servo-tester-a-layout-150x107.png" caption="Layout"  float="right" %}

A small device to control a standard R/C servo eliminating the need of R/C radio equipment. This device would be useful not only for testing servos but also for installing servos in planes, to adjust center position and throw. Manual control of the servo would be needed as well as a quick way to center a servo. A future enhancement could be an automatic exerciser mode that continuously sweeps the servo at variable speed.

**Hardware:**
Some button were needed to control servo movement, up key, center key and down key. Some LED's to indicate servo position and connectors to hookup power and one or two servos. In my assortment of electronic parts I found some key switches of unknow origin. I also had a good quantity of LED's on hand. A translucent green Serpac C-6 enclosure promised a small compact device. A PIC16F676 and a few resistors and capacitors completed the list of parts.

After sketching the schematic on some graph paper, the board layout was designed using the Eagle layout editor. The board was produced using the toner transfer method. Printing the layout onto Epson glossy photo paper with a Dell 1710n printer provided a crisp and flawless image. The paper was ironed onto a freshly scrubbed and cleaned copper clad board. Etching with some well aged Ammonium Persulfate took forever despite heating and agitation. It still resulted in a very good looking board.

{% include lightbox.html image="servo-tester-a-board-400x299.jpg" thumb="servo-tester-a-board-150x112.jpg" caption="Circuit Board"  float="right" %}

This initial version of the software only implemented the manual control of the servo. The exercising function was left for future development. The software runs in a continuous timed loop to generate the output PPM pulses. Timer 1 is used as accurate time base rather then a software delay loop. The hardware was designed to enable the use of the PWM module, even though this first cut of the software does not require or use the PWM functionality.

**Version 1.0**
History:
* First public release

Files:
* [Source Code]({{ site.baseurl }}/{{ page.assets }}/servo-tester-16f676-20061029.asm)
* [Eagle board]({{ site.baseurl }}/{{ page.assets }}/servo-tester-a.brd)
* [Printable board layout]({{ site.baseurl }}/{{ page.assets }}/servo-tester-a.pdf)
* Schematic Diagram to be added some time
