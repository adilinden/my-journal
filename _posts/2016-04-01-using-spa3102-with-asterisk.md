---
layout: post
title: Using SPA3102 with Asterisk
date: 2016-04-01 21:03:00
comments: Yes
tags:
  - asterisk
  - cisco
category:
  - Sysadmin
---

Here are some quick and dirty instructions on how I was able to get a SPA3102 to work on my Asterisk server.  I am running Asterisk on OS X but that is a story for another day.

## Initial Setup

Connect handset to SPA3102.  Connect ethernet to WAN port of 3102.  Pickup handset and dial "\*\*\*\*" to access the voice menu.  Get the IP address of the SPA3102 by dialing "110#". Reset the device by pressing "73738#". Enable the web interface on the WAN port using the following sequence:

```
7932#
1#
1
```

## Connect to the Device

Connect the management PC directly to the ETHERNET port of the SPA3201.  The DHCP server of the SPA3201 should provide an IP address to the workstaion.  Using the webbraowser navigate to http://192.168.0.1/admin/advanced and use the username 'admin' and password 'admin'.

## General SPA3102 Settings

SPA3102 "Router" tab, "WAN Setup" subtab

1. Under "Optional Settings"
    1. Set "Primary NTP Server" to "<IP address of NTP server>"
    2. Set "Secondary NTP Server" to "<IP address of alternate NTP server>"

SPA3102 "Voice" tab, "SIP" subtab

1. Under "RTP Parameters", set "RTP Packet Size" to "0.020"

## Configure PSTN Outgoing

SPA3102 "Voice" tab, "PSTN" subtab

1. Under "Proxy and Registration"
    1. Set the "Proxy" to "<IP address of Asterisk server>"
    2. Set "Make Call Without Reg" and "Ans Call Without Reg" to "Yes"
    3. Set "Use OB Proxy In Dialog" to "No"
2. Under "Subscriber Information"
    1. Set "User ID" to the trunk name "spa3102"
    2. Set "Password" to our password "some_crazy_password"
3. Under 'SIP Settings'
    1. Set "SIP Port" to "5060"
4. Click "Submit All Changes"
5. Create Asterisk dial peer in `sip.conf`

```
[spa3102]
; SPA3102
type=friend
context=inbound-pstn-gateway
defaultuser=spa3102
secret=some_crazy_password
host=dynamic
port=5061
dtmfmode=rfc2833
directmedia=no
disallow=all                    ; Prevent all codecs
allow = ulaw                    ; ...except G.711 ulaw
insecure=port,invite
qualify=yes
```

## Configure PSTN Incoming

SPA3102 "Voice" tab, "PSTN" subtab

1. Under "PSTN-To-VoIP Gateway Setup"
    1. Set "PSTN Ring Thru Line 1" to "No"
    2. Set "Caller Default DP" to "2"
    3. Set "Display Name" to "Bell Line Calling"
2. Under "Dial Plans"
    1. Set "Dial Plan 2" to "S0(<:5551212>)", the actual phone number
3. Under "FXO Timer Values (sec)"
    1. Set "PSTN Answer Delay:" to "0" since I do not have caller ID
4. Click "Submit All Changes"
5. Create in inbound route in Asterisk `extensions.conf`

## Configure FXS Port

*Note:* I disabled "Line 1" and used ATA for local FXS to avoid toll charges by device bypassing VoIP on power outage or loss of network.  I do not want my local PSTN line used for longdisatance at all.

SPA3102 "Voice" tab, "LINE 1" subtab

1. Under "Proxy and Registration"
    1. Set "Proxy" to "<IP address of Asterisk server>"
    2. Set "Make Call Without Reg" and "Ans Call Without Reg" to "Yes"
    3. Set "Use OB Proxy In Dialog" to "No"
2. Under "Subscriber Information"
    1. Set "User ID" to the extension number "26"
    2. Set "Password" to our password "some_crazy_password"
3. Under 'SIP Settings'
    1. Set "SIP Port" to "5061"
4. Under "DialPlan"
    1. Set the "Dial Plan" to "([*x]x.)"
5. Under "VoIP Fallback To PSTN"
    1. Set the "Auto PSTN Fallback" to "No"
6. Click "Submit All Changes"

SPA3102 "Voice" tab, "Regional" subtab

7. Under "Vertical Service Activation Codes"
    1. Clear out all "*XX" codes as they otherwise interfere.
8. Miscellaneous
    1. Set "Time Zone" to "GMT-6"
    2. Set "Daylight Saving Time Rule" to "start=3/2/7;end=11/1/7;save=1"
8. Click "Submit All Changes"
9. Create a new extension in `sip.conf`
