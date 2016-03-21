---
layout: post
title: Add a Filetype to "Open With"
date: 2012-01-20 12:23:14
comments: Yes
tags:
  - arduino
  - mac
  - osx
  - sysadmin
  - vim
summary: How to add an "Open With" item...
redirect_from:
  - /article/add-filetype-open-with/
category:
  - Sysadmin
assets: resources/2012-01-20-add-filetype-open-with
---

![VIM](/resources/2012-01-20-add-filetype-open-with/vim.gif)

**The problem:** 

I like [MacVim][] with syntax highlighting for all major programming tasks. MacVim is pretty good at adding itself as an application to most filetypes I would use it for - until I installed [Arduino][] and [MPIDE][]. Since [MPIDE][] is based on Arduino pre-1.0 it used the .pde file extension. [Arduino][] 1.0 uses the .ino file extension. While MacVim has no issues opening either file, it knows nothing about the file extensions. To open .ino and .pde files using MacVim I had to right-click (or CTRL-click), select "Open With", then "Others..." and scroll down the long list of apps until finally arriving at MacVim. I did not want MacVim to be the default app for these files, just a quick and convenient way to open the files using the "Open With" menu, but without scrolling down the list. I made MacVim the default app, hoping it would populate the preferred list, then removed it. No such luck, but read on for the solution.

**The quest:** 

The list of extensions associated with an application are defined in the info.plist file in the applications package. At first I thought the easy way would have been to add the .ino and .pde file extensions to the info.plist file of the MacVim application. Just add it to the same "CFBundleTypeExtensions" container as other like file extensions. I did this by adding .ino and .pde extensions wherever .cpp was referenced. But this accomplished nothing. Searching on Google I discovered that one must reset the Launch Services Database using the "lsregister" utility. Even that did not cause MacVim to be visible in the "Open With" menu for .pde and .ino files. I then looked at how .ino was defined in the Arduino apps info.plist file. I noticed some very significant differences between the statements for MacVim and Arduino. Looking up terms such a "LSItemContentTypes" and "CFBundleTypeMIMETypes" in Google I discovered that there are different methods by which filetypes are registered with the system. I came across this [post][] in a Google search result for "LSItemContentTypes". Convinced I did it wrong, I restored my modified info.plist for MacVim to virgin condition.

**The solution:** 

I copied the "CFBundleTypeExtensions" container for the .ino extension from the info.plist file of the Arduino application. I then modified it for .ino and .pde and nothing else.
{% highlight xml %}
<dict>
    <key>CFBundleTypeExtensions</key>
    <array>
        <string>ino</string>
        <string>pde</string>
    </array>
    <key>CFBundleTypeIconFile</key>
    <string>pde.icns</string>
    <key>CFBundleTypeName</key>
    <string>Arduino Source File</string>
    <key>CFBundleTypeMIMETypes</key>
    <array>
        <string>text/plain</string>
    </array>
    <key>CFBundleTypeOSTypes</key>
    <array>
        <string>TEXT</string>
    </array>
    <key>CFBundleTypeRole</key>
    <string>Editor</string>
</dict>
{% endhighlight %}

I opened the info.plist file for the MacVim application and inserted the above code right below:
{% highlight xml %}
<key>CFBundleDocumentTypes</key>
<array>
{% endhighlight %}
Upon saving the file I then reset the Launch Services Database.

    /System/Library/Frameworks/CoreServices.framework/Versions/A/Frameworks/LaunchServices.framework/Versions/A/Support/lsregister -kill -seed -r

Voila! We have MacVim as a preferred application in the "Open With" menu...

![Open With](/resources/2012-01-20-add-filetype-open-with/Open-With-300x209.png)

Just one last note, this has all been done on OS X Snow Leopard, 10.6.8.

[MacVim]:http://code.google.com/p/macvim/
[MPIDE]: http://http://chipkit.net
[Arduino]: http://arduino.cc
[post]: http://lists.apple.com/archives/Carbon-dev/2005/Oct/msg00184.html

