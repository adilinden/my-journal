---
layout: post
title: TinyUPS Daemon
date: 2002-03-18 00:20:51
comments: 
tags:
  - c
  - programming

redirect_from:
  - /article/tinyups-daemon/
category:
  - Coding
assets: resources/2002-03-18-tinyups-daemon
---

For some variety I occassionally install [FreeBSD](http://www.freebsd.org). However, I couldn't find any UPS control software that fit my needs. So I studied the sources of various Linux centric UPS daemons such as genpowerd and powerd. TinyUPS Daemon is what I call the result of my efforts.

An Uninterruptible Power Supply is required. Any UPS supporting dumb signalling should work but it has only been tested with an [APC](http://www.apc.com) Back-UPS and the cable shown.

    /*
    * UPS Side                           Serial Port Side
    * 9 Pin Male                         9 Pin Female
    *
    * Shutdown UPS 1 <---------------> 3 TX  (high = kill power)
    * Line Fail    2 <---------------> 1 DCD (high = power fail)
    * Ground       4 <---------------> 5 GND
    * Low Battery  5 <----+----------> 6 DSR (low = low battery)
    *                     `---|  |---> 4 DTR (cable power)
    */


The project is hosted on [GitHub](http://github.com/adilinden/tinyupsd/).

Install by cloning the git repo

    git clone https://github.com/adilinden/tinyupsd.git

Install by downloading the latest tarball at [tinyupsd tarball](https://github.com/adilinden/tinyupsd/archive/master.tar.gz)

