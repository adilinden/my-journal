---
layout: post
title: Image Popup Javascript
date: 2005-02-20 00:11:32
comments: 
tags:
  - java
  - programming

redirect_from:
  - /article/image-popup-javascript/
category:
  - Coding
assets: resources/2005-02-20-image-popup-javascript
---

I know that popup windows are being frowned upon at most times. However, I personally like the use of a popup window to obtain the larger version of an image thumbnail on a page. I make liberal use use of this on my web pages. One of my attempts of a popup image window is described here.

The Java function that does most of the work is placed in the `popup.js` file:

{% highlight java %}
    function popup(url,img_h,img_v,caption,title)
    {
        img_h_space  = 20;
        img_v_space  = 75;
        window_h     = parseInt(img_h) + img_h_space;
        window_v     = parseInt(img_v) + img_v_space;
        options      = 'toolbar=0' +
                       ',status=0' +
                       ',menubar=0' +
                       ',scrollbars=0' +
                       ',resizable=0' +
                       ',width=' + window_h +
                       ',height=' + window_v;
        img_tag      = '<img src="'+url+'" width="'+img_h+'" height="'+img_v+'">';
        if (!title) 
            title = caption;
        content      =
          '<html>n'+
          '<head><title>'+title+'</title></head>n' +
          '<body bgcolor="#ffffff"><div class="popup">' + img_tag +
          '<p>' + caption + '<br>' + 
          '<a href="javascript:window.close();">Close Window</a>' +
          '</div></body>n' +
          '</html>';
      
        if (typeof(viewImg) == 'object' &amp;&amp; !viewImg.closed)
            viewImg.close();
        viewImg  = window.open('','viewImg',options);
        if (!viewImg.opener) 
            viewImg.opener = self;
        viewImg.document.open();
        viewImg.document.write(content);
        viewImg.document.close();
        viewImg.focus();
    }
{% endhighlight %}

This funtion is included by these statements between the head tags of the web page:

{% highlight html %}
    <script src="../../common/javascript/validator.js" type="text/javascript"></script>
{% endhighlight %}

I usually use two different resolutions for images. The thumbnail on the page is scaled to a width if 150 pixels and the larger popup image is scaled to a width of 450 pixels. The following link below is W3C compliant. For Java capable browsers the larger image will appear in a popup window and for non-Java browsers the link we be followed and the large image will appear in the current window. Ideally the text quoted below should be all on one line.

{% highlight html %}
    <a href="images-450.jpg" onclick="popup('images-450.jpg','450','600','Caption'); return false;">
    <img src="images-150.jpg" hspace="5" align="right" height="200" width="150" vspace="5" alt="Caption" border="1">
    </a>
{% endhighlight %}

Enjoy!
