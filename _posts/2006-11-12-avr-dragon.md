---
layout: post
title: AVR Dragon
date: 2006-11-12 03:26:24
comments: 
lightbox: true
tags:
  - avr
  - electronics
  - embedded
summary: The Atmel AVR Dragon is a new programmer for Atmel AVR 8-bit Microcontrollers. I obtained this little beast because my old AVRISP serial programmer was useless due to lack of serial hardware on my PC. The Dragon was quite inexpensive and readily available at DigiKey. It promised to not only provide ISP (In-circuit Serial Programming), but also JTAG, debugWire and high voltage programming for AVR device. It arrived in a very stylish red little box, but no cables, enclosure or anything else for that matter. After some searching I came across the Serpac H-65 enclosure. It proved to be a perfect fit for "my" Dragon.
redirect_from:
  - /article/avr-dragon/
category: 
  - Electronics
assets: resources/2006-11-12-avr-dragon
---

{% include lightbox.html image="dragon-655x400.jpg" thumb="dragon-200x122.jpg" caption="Dragon in Serpac H-65"  float="left" %}

The Atmel AVR Dragon is a new programmer for Atmel AVR 8-bit Microcontrollers. I obtained this little beast because my old AVRISP serial programmer was useless due to lack of serial hardware on my PC. The Dragon was quite inexpensive and readily available at DigiKey. It promised to not only provide ISP (In-circuit Serial Programming), but also JTAG, debugWire and high voltage programming for AVR device. It arrived in a very stylish red little box, but no cables, enclosure or anything else for that matter. After some searching I came across the [Serpac H-65](http://serpac.com/products_h-65.htm) enclosure. It proved to be a perfect fit for "my" Dragon.

The [Serpac H-65](http://serpac.com/products_h-65.htm)  in translucent grey was purchased from DigiKey. The translucent grey allowed for great visibility of the status LED's of the Dragon. The enclosure had board mounting pegs that were made for the Dragon board. The Dragon board was just wide enough to sit on the edge of these pegs. Screws in those pegs ensured the board was held down tight and could not slip off. To prevent shorts (the head of one screw was uncomfortably close to the RAM chip on the Dragon board) nylon transistor mounting hardware parts were used as washers and spacers. A hole for the USB connector was cut into one end and notches for the target programming cables were cut into the other end.

I had planned on using this particular Dragon for ISP, JTAG and debugWire use only. Therfore a ZIF socket was not installed and no consideration was given as to how a ZIF socket would fit into this case.
