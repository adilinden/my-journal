---
layout: post
title: speak_time, an IRLP Custom Script
date: 2002-10-27 01:22:19
comments: 
tags:
  - amateurradio
  - irlp
  - programming

redirect_from:
  - /article/speak_time-an-irlp-custom-script/
category:
  - Amateur Radio
  - Coding
assets: resources/2002-10-27-speak_time-an-irlp-custom-script
---

**Introduction to speak_time**
When I first started with IRLP I wrote a few custom scripts for my node. This script announces the local system time.

**Downloading speak_time**
The latest version of speak_time is available as:

* [speak_time-1.0.tar.gz]({{ site.baseurl }}/{{ page.assets }}/speak_time-1.0.tar.gz)

**Documentation for speak_time**
Documentation for speak_time is provided by a README file. This README file is shown below and included in the distribution.

    $Id: README,v 1.1.1.1 2002/10/27 21:18:36 adicvs Exp $
    Adi Linden
    
    Speak Time
    ==========
    
    What's this?
    ------------
    This is a add-on for an IRLP node. The purpose it read the current time
    of the node computer and announce it on the local repeater.
    
    Requirements
    ------------
    - A working IRLP node
    
    Installation
    ------------
    I'd recommend that the complete speak_time directory structure be
    placed under the custom directory of the repeater user. This includes
    any wav files. The script expects the wav files to live in ./audio/default
    relative to the location of the script itself.
    
    The config file defines a few variables. The values most likely requiring
    change are:
    
    wavpath="$homedir/audio/default"     # Change to your own wav files
    
    The wavpath variable points to the individual wav files that are needed
    to assemble the complete sentence announcing the time. If you want to
    record your own, place them in a directory under audio and change
    the wavpath variable accordingly.
    
    Finally, the node needs to be configured to announce the time on a specific
    DTMF sequence. For my node I use 81 to announce the time. The following
    lines added to $CUSTOM/custom_decode will accomplish that:
    
    if [ "$1" = "81" ] ; then
    $CUSTOM/speak_time/speak ; exit 1 ;
    fi
    
    Caveats
    -------
    This script uses the date system command and the time is only as accurate
    as the Linux system time is. To get accurate time I recommend running ntp
    on the node and syncing the time against a ntp server.
    
    Contact
    -------
    Feel free to contact VA3ADI on node 2590.


*[IRLP]: Internet Radio Linking Project
