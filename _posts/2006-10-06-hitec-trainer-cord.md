---
layout: post
title: Hitec Trainer Cord
date: 2006-10-05 23:41:37
comments: 
tags:
  - r/c

redirect_from:
  - /article/hitec-trainer-cord/
category:
  - RC Flying
assets: resources/2006-10-06-hitec-trainer-cord
---

Curious me wanted to know the pinout of the plug on the back of my Hitec radios. Some time ago I made up a buddy cord for the Hitec Optic 6 and Hitec Laser 4. It took me a while to retrace those steps and find all the information used to make that cable. So here it is, this is how I made my Hitec buddy cord.

Below is an (ugly) ASCII drawing showing the pinout of the trainer cord connector on the Hitec transmitter.

                -------            1  ----  +V Switched
             /                    
            /      3              2  ----  PPM Out
           /  2    o    4         
               o       o           3  ----  PPM In
          |                 |      
          |  1o    o    o5  |      4  ----  +V 
          |        6        |      
                                   5  ----  High to Disable RF
                         /        
               7 ___    /         6  ----  DSC 
                /     /          
                -------            7  ----  GND/Shield```

And coming right up... This is how I assembled the trainer cord. Two DIN connectors are required and a chunk of cable. The cable only works one way, one connector is therfore labeled master and the other student.

    Student              Master
 
      1  -----------------  1 
      2  -----------------  3
      3  -----------------  2
      4  ---+
      5  ---+
      7  -----------------  7

    Note: pins 4 and 5 bridged on student side
    
**Some words of warning!**
_The information presented is provided "as is" without any guarantees or warranty. I will not be responsible for any damage or losses of any kind caused by the use or misuse of the information._
