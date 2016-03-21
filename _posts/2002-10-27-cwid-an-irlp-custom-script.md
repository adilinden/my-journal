---
layout: post
title: cwid, an IRLP Custom Script
date: 2002-10-27 00:59:57
comments: 
tags:
  - amateurradio
  - irlp
  - programming

redirect_from:
  - /article/cwid-an-irlp-custom-script/
category:
  - Amateur Radio
  - Coding
assets: resources/2002-10-27-cwid-an-irlp-custom-script
---

**Introduction to cwid**
When I first started with IRLP I wrote a few custom scripts for my node. This script plays a CW ID on a regular basis. It uses playmidi and a midi file to id the repeater. The scripts default timing adheres to Canadian regulation. It ids at 20 minute intervals, but yields to ongoing conversations for up to an additional 2 minutes. It only ids if there is activity on the repeater. It will not id during extended periods of inactivity. The actual timing is easily configured using variables.

**Downloading cwid**
The latest version of cwid is available as:

* The cwid tarball [cwid-1.2.tar.gz]({{ site.baseurl }}/{{ page.assets }}/cwid-1.2.tar.gz)

**Dependencies**
The cwid script relies on the sccw command. The sccw sources and a patch I applied are also here.

* The sccw sources [cwid-1.2.tar.gz]({{ site.baseurl }}/{{ page.assets }}/cwid-1.2.tar.gz)
* The sccw patch [sccw_1.1a.patch]({{ site.baseurl }}/{{ page.assets }}/sccw_1.1a.patch)

**Documentation for cwid**
Documentation for cwid is provided by a README file. This README file is shown below and included in the distribution.

    $Id: README,v 1.1.1.1 2002/10/27 21:18:36 adicvs Exp $
    
    Description
    -----------
    
    cwid relies on the playmidi package to send a pre-recorded midi file at
    certain intervals.
    
    I hope to add some more information here soon!
    
    Installation
    ------------
    
    As repeater user, extract the cwid.tgz archive in /home/irlp/custom. It 
    will extract into the cwid directory. The following files are in the cwid 
    directory:
    
        README        - you're reading it
        cwid          - the main script which runs in an endless loop
        cwidmon       - a script that checks for the existance of cwid
        cwid.mid      - the midi file containing the cw callsign
    
    The cwid script contains variables determining the timing of the id's.
    Change to following as necessary:
    
        idcourt="120"                # Courtesy time, default 2 min (120 secs)
        iddelay="2400"               # Frequency, default 20 min (2400 secs)
    
    "iddelay" determines how often the id is repeated. "idcourt" is the time
    period cwid will yield to ongoing repeater traffic before forcing
    transmission of the cw identification. In a worst case scenario the above
    times would id every 22 minutes.
    
    If cwid is run from the commandline it will create a line of output every
    second displaying the internal timer counts and the state. It is recommended
    that cwid is run in the background with stout and sterr redirected to
    /dev/null. Something like this would do:
    
        ./cwid > /dev/null 2>&1
    
    Even better, use the included cwidmon script to monitor for the existance
    of the script and restart it in case it dies for any reason. The cwidmon
    script will then take care of starting cwid at system boot as well. The
    following line would be appropriate for the repeater user cron:
    
        */5 * * * * /home/irlp/custom/cwid/cwidmon
    
    This would be an appropriate line for the root cron file:
    
        */5 * * * * su - -c "/home/irlp/custom/cwid/cwidmon" repeater
    
    Make sure you record your own midi file containing the cw version of your
    repeater callsign! The sample file will send "cwid"!
    
    Notes
    -----
    
    I used "CW Midi for Windows" to record the midi file. It's available at
    <http://www.natradioco.com/Nrprod.htm>.
    
    This script has been tested on RedHat 7.1 using Soundblaster AWE64 
    hardware. In order to allow the repeater user and playmidi to access the
    kernels midi driver I had to add this to "/etc/rc.d/rc.local":
    
        chmod 660 /dev/sequencer*
        chown root.sys /dev/sequencer*
    
    I have not tested this with any other hardware. Depending on your hardware
    you may have to change the arguments for playmidi in the cwid script.
