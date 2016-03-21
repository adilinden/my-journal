---
layout: post
title: Pretty Code Block in CSS
date: 2011-02-18 20:29:30
comments: Yes
tags:
  - css
  - programming
  - wordpress

redirect_from:
  - /article/pretty-code-block-in-css/
category:
  - Coding
  - Wordpress
assets: resources/2011-02-19-pretty-code-block-in-css
---

This is a neat way to format code blocks. Parts cobbled together from various places. It is not longer exactly as used here since I have changed themes and CMS.
{% highlight css %}
    pre {
        font-family: "Courier 10 Pitch", Courier, monospace;
        font-size: 95%;
        line-height: 140%;
        white-space: pre;
        white-space: pre-wrap;
        white-space: -moz-pre-wrap;
        white-space: -o-pre-wrap;
    }       
    
    code {
        font-family: Monaco, Consolas, "Andale Mono", "DejaVu Sans Mono", monospace;
        font-size: 95%;
        line-height: 140%;
        white-space: pre;
        white-space: pre-wrap;
        white-space: -moz-pre-wrap;
        white-space: -o-pre-wrap;
        background: #faf8f0;
    }
    
    #content code {
        display: block;
        padding: 0.5em 1em;
        border: 1px solid #bebab0;
    }
{% endhighlight %}
