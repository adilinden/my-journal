---
layout: post
title: The New Repeater Controller
date: 2013-01-17 22:41:42
comments: 
lightbox: true
tags:
  - amateurradio
  - c
  - irlp
  - opensource
  - programming
summary: I mostly completed the biggest overhaul of the VA3SLT repeater and IRLP Node 2590 to date.
redirect_from:
  - /article/the-new-repeater-controller/
category: Amateur Radio
assets: resources/2013-01-18-the-new-repeater-controller
---

{% include lightbox.html image="IMG_1252-600x450.jpg" thumb="IMG_1252-150x150.jpg" caption="A PC in a homebrew rack mount case"  float="left" %}

I mostly completed the biggest overhaul of the VA3SLT repeater and [IRLP](http://www.irlp.net) Node 2590 to date. The old article of what I have done for an IRLP repeater is [IRLP Now](irlp-now).

The old Pentium PC powering the repeater had been on its last legs for a while. The RedHat 5.2 OS running the system had been way past its expiry date for some time. About 2 years ago I invested in a new ITX motherboard and DC power supply. What I thought to be a quick and easy upgrade turned out to be quite a chore. The original system relied on dual ISA sounds cards. Those were supported by OSS. Dual sound cards were needed since IRLP, CW ID, courtesy tone all needed to access the sound hardware. The IRLP software accessed the parallel port using a dedicated custom driver.

Since then much has changed. Along came ALSA and the parport driver. But it by all tossed a big monkey wrench into the repeater controller software I put into production. Now, after 2 years, I've completed a major overhaul of the repeater controller and the tone generation processes it relies on.

I've examined quite a few Linux applications designed to generate CW. None of them suited my taste for what I had in mind. So I went about writing applications to generate CW and tone sequences. The tone sequences were required to provide the repeater courtesy tones. The repeater application itself was cleaned up. I moved the code to control the IRLP board pins into its own source file. That way I was able to include the same functions in the repeater controller itself as well as in the port control application. Maintaining one library for manipulating parallel port pins sure is easier then having to deal with the same code in multiple different places. I also eliminated the legacy irlp-port code. For some time now IRLP relies on the irlpdev driver that accesses the parallel port via the kernels parport device.

I also added some new features to the repeater controller. Previously the CW ID was taken care of by an add-on to the IRLP system. But now CW ID has been integrated into the repeater controller. This makes the repeater controller a fully functional standalone controller. The only dependency on IRLP is the hardware to interface to the radio.

I have made the sources for [repeater-controller](http://github.com/adilinden/repeater-controller) available on [Github](http://github.com/adilinden/repeater-controller). As of the time of writing, I am running version 20130116 on my IRLP Node 2590. It has been tagged and a arball is available for your pleasure

* [repeater-controller-20130116](http://github.com/adilinden/repeater-controller/archive/20130116.tar.gz)

Enjoy!

