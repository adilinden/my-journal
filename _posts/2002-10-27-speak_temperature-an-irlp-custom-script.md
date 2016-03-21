---
layout: post
title: speak_temperature, an IRLP Custom Script
date: 2002-10-27 01:14:31
comments: 
tags:
  - amateurradio
  - irlp
  - programming

redirect_from:
  - /article/speak_temperature-an-irlp-custom-script/
category:
  - Amateur Radio
  - Coding
assets: resources/2002-10-27-speak_temperature-an-irlp-custom-script
---

**Introduction to speak_temperature**
When I first started with IRLP I wrote a few custom scripts for my node. This script announces the temperature. The temperature is obtained via a Dallas DS1820 1-wire sensor attached to the nodes serial port. digitemp is used to read the sensor, a precompiled static digitemp binary has been included for convenience.

**Downloading speak_temperature**
The latest version of speak_temperature is available as:

* [speak_temperature-1.0.tar.gz]({{ site.baseurl }}/{{ page.assets }}/speak_temperature-1.0.tar.gz)

**Documentation for speak_temperature**
Documentation for speak_temperature is provided by a README file. This README file is shown below and included in the distribution.

    $Id: README,v 1.1.1.1 2002/10/27 21:18:34 adicvs Exp $
    Adi Linden
    
    Speak Temperature
    =================
    
    What's this?
    ------------
    This is a add-on for an IRLP node. The purpose it read a single temperature
    sensor and output the temperature as voice via the local repeater.
    
    Requirements
    ------------
    - A working IRLP node
    - A Dallas DS1820 1-wire temperature sensor
    - A simple serial adapter for the temperature sensor
    - The digitemp software
    
    Hardware Installation
    ---------------------
    Here is a simple ascii diagram for the serial interface:
    
      DTR  O---------+-------------+-------------+------------------O
                     |             |             |                    To DS1820
                   `---, D1        |             |             +----O
                    /   1N5228    |             |             |
                    ---  3.9V     ---  D3      `---, D2        |
                     |            /   1N5817   /   1N5234    |
      GND  O---------+            ---           ---  6.2V      |
                                   |             |             |
                                   |             |             |
                                   |             |             |
      RXD  O---------+-------------+-------------+-------------+
                     |             |
                     -             |
                    | |          `---, D4
                    | |           /   1N5817
                    | |           ---
                     -             |
                     |             |
      TXD  O---------+-------------+
    
    The adapter can easily be build on a small perf board. I recommend the use
    of shielded cable between the serial adapter and the DS1820 temperature
    sensor.
    
    Software Installation
    ---------------------
    I'd recommend that the complete speak_temperature directory structure be
    placed under the custom directory of the repeater user. This includes
    any wav files. The script expects the wav files to live in ./audio/default
    relative to the location of the script itself.
    
    The config file defines a few variables. The values most likely requiring
    change are: 
    
        wavpath="$homedir/audio/default"     # Change to your own wav files
    
        digitempdev="/dev/ttyS0"             # Change as required!
    
    The wavpath variable points to the individual wav files that are needed
    to assemble the complete sentence announcing the temperature. If you
    want to record your own, place them in a directory under audio and change
    the wavpath variable accordingly.
    
    The digitemp variable needs to be set to the device the serial interface
    for the DS1820 has been connected to.
    
    The digitemp program is also required. For convenience I supplied a
    statically linked precompiled binary in the bin directory. If you build
    your own digitemp from sources either replace the supplied binary in bin
    or change the digitemp variable in the config file to point to your
    compiled binary.
    
    Finally, the node needs to be configured to announce the temperature on
    a specific DTMF sequence. For my node I use 82 for temperature in Celsius
    and 83 for temperature in farenheit. The following lines added to
    $CUSTOM/custom_decode will accomplish that:
    
        if [ "$1" = "82" ] ; then 
            $CUSTOM/speak_temperature/speak celsius ; exit 1 ; 
        fi
        if [ "$1" = "83" ] ; then 
            $CUSTOM/speak_temperature/speak farenheit ; exit 1 ; 
        fi
    
    Caveats
    -------
    The 1-wire bus and digitemp support multiple temperature sensors on the
    interface. This script currently plays back the value of the first
    temperature sensor only. Perhaps at some point in the future I will
    adapt it to support multiple sensors.
    
    Resources
    ---------
    IRLP              http://www.irlp.net
    DS1820            http://www.dalsemi.com
    digitemp          http://www.brianlane.com/digitemp.php
    
    Contact
    -------
    Feel free to contact  or VA3ADI on node 2590.

*[IRLP]: Internet Radio Linking Project
