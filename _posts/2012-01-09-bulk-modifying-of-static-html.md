---
layout: post
title: Bulk Modifying of Static HTML
date: 2012-01-09 10:26:36
comments: 
tags:
  - programming
  - shell

redirect_from:
  - /article/bulk-modifying-of-static-html/
category:
  - Sysadmin
assets: resources/2012-01-09-bulk-modifying-of-static-html
---

While relocating the [PeeWeeLinux web site](http://peeweelinux.adis.ca/) I found myself needing to make bulk changes to a some 1800 static HTML pages. I had to insert a new HTML tag before the "head" tag on each page.

The search and replace workhorse in this method is "sed", the Unix stream editor. I created the following shell script "sed.sh" in the root directory of the HTML content:
{% highlight bash %}
    sed '/</HEAD/ i        <!-- Inserted_before_closing_head_tag -->
    ' $1 > tmp.txt
    cat tmp.txt > $1
{% endhighlight %}

In order to apply these changes to each and every HTML file the following "find" command was executed:
{% highlight bash %}
    find . -name '*.html' -exec sh sed.sh {} ;
{% endhighlight %}

And "voilà", all HTML files in the web directory now have a shiny new line with a HTML comment. A final step is to cleanup the temporary files created:
{% highlight bash %}
    rm sed.sh tmp.txt
{% endhighlight %}

On a side note, PeeWeeLinux is pretty outdated and has not seen any development in a long long time. However, I do still want to keep the web site and files alive, even if just for historic purposes. Not so long ago I have used [Embedded Debian](http://www.emdebian.org) for a Compact Flash based system. It works quite well.
