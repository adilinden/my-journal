---
layout: post
title: Microchip PIC Room Thermostat
date: 2006-10-04 00:36:56
comments: Yes
lightbox: true
tags:
  - electronics
  - embedded
  - pic
  - thermostat
summary: During spring and summer of 1998 I developed my second project utilizing a Microchip PIC processor. The primary purpose was to explore character LCD displays and 2-wire bus (I2C) devices with a Microchip PIC microcontroller. The project was a digital room thermostat with multiple setpoints at different times of the day.
redirect_from:
  - /article/pic-thermostat/
category:
  - Electronics
assets: resources/2006-10-04-pic-thermostat
---

{% include lightbox.html image="thermostat_component_400x330.jpg" thumb="thermostat_component_150x124.jpg" caption="Component side of protoboard"  float="right" %}

During spring and summer of 1998 I developed my second project utilizing a Microchip PIC processor. The primary purpose was to explore character LCD displays and 2-wire bus (I2C) devices with a Microchip PIC microcontroller. The project was a digital room thermostat with multiple setpoints at different times of the day.

{% include lightbox.html image="thermostat_lcd_400x333.jpg" thumb="thermostat_lcd_150x125.jpg" caption="Assembled with LCD Display"  float="left" %}

The hardware consisted of a Microchip PIC16F84 microcontroller, a Dallas DS1621 temperature sensor, a Dallas DS1307 realtime clock, a Linear LT1173 switched mode voltage regulator and a surplus LCD display. The schematic diagram and pictures provide information on the design and assembly on a prototyping board. The realtime clock chip was powered by a lithium cell for timekeeping and storing of settings in non-volatile memory. The switched mode voltage regulator was selected over a linear regulator to minimize heating of the circuit. Because the temperature sensor was located on the board, power consumption and heat production of the circuit needed to be kept to a minimum.

{% include lightbox.html image="thermostat_solder_400x323.jpg" thumb="thermostat_solder_150x121.jpg" caption="Solder side of protoboard"  float="right" %}

The software was written in MPLAB assembler. Although familiar with 2-wire devices, this was my first opportunity to explore the I2C bus on a PIC microcontroller. Since the PIC16F84 contained no I2C serial hardware the I2C bus was bit-banged on general purpose I/O pins. To save on I/O line requirements the LCD display was connected in 4-bit mode and the input keys were multiplexed with the LCD signal lines.

All relevant files for the project are provided here. Keep in mind that this is an educational project rather then a finished product. So some things may not work as advertised or not work at all. The project has been placed here for historic purposes. I sincerely doubt I will ever get back to finishing it.

Files:

* [Schematic diagram]({{ site.baseurl }}/{{ page.assets }}/thermostat_schematic.pdf)
* [MPASM Source Code]({{ site.baseurl }}/{{ page.assets }}/th_stat.asm)
* [MPASM Header File for PIC16F84]({{ site.baseurl }}/{{ page.assets }}/16f84adi.inc)
* [HEX File for PIC16F84]({{ site.baseurl }}/{{ page.assets }}/th_stat.hex)
