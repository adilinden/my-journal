---
layout: post
title: Create ISO image using hdiutil on OS X
date: 2010-11-13 13:20:34
comments: 
tags:
  - mac
  - osx

redirect_from:
  - /article/create-iso-image-using-hdiutil-on-os-x/
category:
  - Sysadmin
assets: resources/2010-11-13-create-iso-image-using-hdiutil-on-os-x
---

How exactly can one create a good old ISO image using readily available Mac tools? After all, the Disk Utility seems to heavily favor the DMG format. Here is the magic, using the terminal run:

    hdiutil makehybrid -iso -joliet -o <output file> <folder with files>/


Note that the files to populate the ISO with need to be in a folder. hdiutil will process the folder contents, not the folder itself. Also note that the trailing slash behind the folder name is a requirement.
