---
layout: post
title: W3C Validator Javascript
date: 2004-02-09 23:39:41
comments: 
tags:
  - java
  - programming

redirect_from:
  - /article/w3c-validator-javascript/
category:
  - Coding
assets: resources/2004-02-10-w3c-validator-javascript
---

I used to like some small unobtrusive links to the various W3C html and css validators at the bottom of my pages. Instead of mainting these links by hand I decided to write some litte Java for the task. The solution I came up with is W3C compliant in that browsers not capable of Javascript simply won’t display the links.

Here is the code for the Java function which I placed in the `validator.js`file:
{% highlight java %}
    function validator()
    { 
          var url = 'Check this page for ' +
                    '<a href="http://validator.w3.org/checklink?uri=' +
                    location.href + "'>dead links</a>, ' +
                    '<a href="http://validator.w3.org/check?uri=' +
                    location.href + '">sloppy html</a>, or a ' +
                    '<a href="http://jigsaw.w3.org/css-validator/validator?uri=' +
                    location.href + '">bad style sheet</a>.';
          document.write(url);
    } 
{% endhighlight %}

The function is included in the html page by placing the following between the `<head>` and `</head>` tags:

    <script src="validator.js" type="text/javascript"></script>
    
Now that this function is available in the page, it is used on the page by placing this code in the body of the page:

    <script type="text/javascript">
        <!-- // For browsercompatibility
        validator();
         // -->
    </script>
