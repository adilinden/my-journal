---
layout: post
title: Restoring the "traditional" Meaning of Home and End Keys on OS X Mountain Lion
date: 2013-03-12 20:58:30
comments: Yes
tags:
  - mac
  - osx
  - sysadmin

redirect_from:
  - /article/mountain-lion-home-end/
category:
  - Sysadmin
assets: resources/2013-03-13-mountain-lion-home-end
---

The Home and End keys on Mac OS X work quite a bit different then one would expect coming from other operating systems. Instead of the familiar beginning of line and end of line behaviour Apple decided that it should put the courser at the beginning or the end of the document. I find this highly annoying to say the least. Fortunately it is easy enough to fix this.

If the `~/Library/KeyBindings` directory doesn't exist then create it:
{% highlight bash %}
    mkdir ~/Library/KeyBindings
{% endhighlight %}

Then create the `~/Library/KeyBindings/DefaultKeyBinding.dict` file with the following content:
{% highlight bash %}
{
    /* home */
    "UF729"  = "moveToBeginningOfLine:";
    "$UF729" = "moveToBeginningOfLineAndModifySelection:";

    /* end */
    "UF72B"  = "moveToEndOfLine:";
    "$UF72B" = "moveToEndOfLineAndModifySelection:";

    /* page up/down */
    "UF72C"  = "pageUp:";
    "UF72D"  = "pageDown:";
}
{% endhighlight %}

Enjoy!
