---
layout: post
title:  "Markdown Examples"
date:   2016-03-10 20:11:10
tags:
  - test page
  - markdown
categories:
  - test page
---

This page demonstrates the Markdown syntax.  It is primarily intended to see how Markdown renders within Jekyll.  I use it to verify the effects of stylesheet changes. 

#### Table of Contents

[Headers](#headers)  
[Emphasis](#emphasis)  
[Subscript](#subscript)  
[Lists](#lists)  
[Links](#links)  
[Images](#images)  
[Tables](#tables)  
[Blockquotes](#blockquotes)  
[Inline HTML](#inline-html)  
[Horizontal Rule](#horizontal-rule)  
[Youtube videos](#youtube-videos)  

#### Headers

{% highlight md %}
# H1

## H2

### H3

#### H4

##### H5

###### H6

Alternatively, for H1 and H2, an underline-ish style:

Alt-H1
======

Alt-H2
------
{% endhighlight %}

# H1

## H2

### H3

#### H4

##### H5

###### H6

Alternatively, for H1 and H2, an underline-ish style:

Alt-H1
======

Alt-H2
------

[Top](#table-of-contents)  

#### Emphasis

{% highlight md %}
Emphasis, aka italics, with *asterisks* or _underscores_.

Strong emphasis, aka bold, with **asterisks** or __underscores__.

Combined emphasis with **asterisks and _underscores_**.

Strikethrough uses two tildes. ~~Scratch this.~~
{% endhighlight %}

Emphasis, aka italics, with *asterisks* or _underscores_.

Strong emphasis, aka bold, with **asterisks** or __underscores__.

Combined emphasis with **asterisks and _underscores_**.

Strikethrough uses two tildes. ~~Scratch this.~~

[Top](#table-of-contents)  

#### Subscript

{% highlight md %}
This is some <sup>superscript</sup> text.

This is some <sub>superscript</sub> text.
{% endhighlight %}

This is some <sup>superscript</sup> text.

This is some <sub>superscript</sub> text.

[Top](#table-of-contents)  

#### Lists

(In this example, leading and trailing spaces are shown with with dots)

{% highlight md %}
1. First ordered list item
2. Another item
⋅⋅⋅⋅* Unordered sub-list. 
1. Actual numbers don't matter, just that it's a number
⋅⋅⋅⋅1. Ordered sub-list
4. And another item.

⋅⋅⋅You can have properly indented paragraphs within list items. Notice the blank line above, and the leading spaces (at least one, but we'll use three here to also align the raw Markdown).

⋅⋅⋅To have a line break without a paragraph, you will need to use two trailing spaces.⋅⋅
⋅⋅⋅Note that this line is separate, but within the same paragraph.⋅⋅
⋅⋅⋅(This is contrary to the typical GFM line break behaviour, where trailing spaces are not required.)

* Unordered list can use asterisks
- Or minuses
+ Or pluses
{% endhighlight %}

1. First ordered list item
2. Another item
    * Unordered sub-list. 
1. Actual numbers don't matter, just that it's a number
    1. Ordered sub-list
4. And another item.

   You can have properly indented paragraphs within list items. Notice the blank line above, and the leading spaces (at least one, but we'll use three here to also align the raw Markdown).

   To have a line break without a paragraph, you will need to use two trailing spaces.  
   Note that this line is separate, but within the same paragraph.  
   (This is contrary to the typical GFM line break behaviour, where trailing spaces are not required.)

* Unordered list can use asterisks
- Or minuses
+ Or pluses

[Top](#table-of-contents)  

#### Links

{% highlight md %}
[I'm an inline-style link](https://www.google.com)

[I'm an inline-style link with title](https://www.google.com "Google's Homepage")

[I'm a reference-style link][Arbitrary case-insensitive reference text]

[I'm a relative reference to a repository file](../blob/master/LICENSE)

[You can use numbers for reference-style link definitions][1]

Or leave it empty and use the [link text itself].

URLs and URLs in angle brackets will automatically get turned into links. 
http://www.example.com or <http://www.example.com> and sometimes 
example.com (but not on Github, for example).

Some text to show that the reference links can follow later.

[arbitrary case-insensitive reference text]: https://www.mozilla.org
[1]: http://slashdot.org
[link text itself]: http://www.reddit.com
{% endhighlight %}

[I'm an inline-style link](https://www.google.com)

[I'm an inline-style link with title](https://www.google.com "Google's Homepage")

[I'm a reference-style link][Arbitrary case-insensitive reference text]

[I'm a relative reference to a repository file](../blob/master/LICENSE)

[You can use numbers for reference-style link definitions][1]

Or leave it empty and use the [link text itself].

URLs and URLs in angle brackets will automatically get turned into links. 
http://www.example.com or <http://www.example.com> and sometimes 
example.com (but not on Github, for example).

Some text to show that the reference links can follow later.

[arbitrary case-insensitive reference text]: https://www.mozilla.org
[1]: http://slashdot.org
[link text itself]: http://www.reddit.com

[Top](#table-of-contents)  

#### Images

{% highlight md %}
Here's our logo (hover to see the title text):

Inline-style: 
![alt text](https://github.com/adam-p/markdown-here/raw/master/src/common/images/icon48.png "Logo Title Text 1")

Reference-style: 
![alt text][logo]

[logo]: https://github.com/adam-p/markdown-here/raw/master/src/common/images/icon48.png "Logo Title Text 2"
{% endhighlight %}

Here's our logo (hover to see the title text):

Inline-style: 
![alt text](https://github.com/adam-p/markdown-here/raw/master/src/common/images/icon48.png "Logo Title Text 1")

Reference-style: 
![alt text][logo]

[logo]: https://github.com/adam-p/markdown-here/raw/master/src/common/images/icon48.png "Logo Title Text 2"

[Top](#table-of-contents)  

#### Tables

{% highlight md %}
Colons can be used to align columns.

| Tables        | Are           | Cool  |
| ------------- |:-------------:| -----:|
| col 3 is      | right-aligned | $1600 |
| col 2 is      | centered      |   $12 |
| zebra stripes | are neat      |    $1 |

There must be at least 3 dashes separating each header cell.
The outer pipes (|) are optional, and you don't need to make the 
raw Markdown line up prettily. You can also use inline Markdown.

Markdown | Less | Pretty
--- | --- | ---
*Still* | `renders` | **nicely**
1 | 2 | 3
{% endhighlight %}

Colons can be used to align columns.

| Tables        | Are           | Cool  |
| ------------- |:-------------:| -----:|
| col 3 is      | right-aligned | $1600 |
| col 2 is      | centered      |   $12 |
| zebra stripes | are neat      |    $1 |

There must be at least 3 dashes separating each header cell.
The outer pipes (|) are optional, and you don't need to make the 
raw Markdown line up prettily. You can also use inline Markdown.

Markdown | Less | Pretty
--- | --- | ---
*Still* | `renders` | **nicely**
1 | 2 | 3

[Top](#table-of-contents)  

#### Blockquotes

{% highlight md %}
> Blockquotes are very handy in email to emulate reply text.
> This line is part of the same quote.

Quote break.

> This is a very long line that will still be quoted properly when it wraps. Oh boy let's keep writing to make sure this is long enough to actually wrap for everyone. Oh, you can *put* **Markdown** into a blockquote. 
{% endhighlight %}

> Blockquotes are very handy in email to emulate reply text.
> This line is part of the same quote.

Quote break.

> This is a very long line that will still be quoted properly when it wraps. Oh boy let's keep writing to make sure this is long enough to actually wrap for everyone. Oh, you can *put* **Markdown** into a blockquote. 

[Top](#table-of-contents)  

#### Horizontal Rule

{% highlight md %}
Three or more...

---

Hyphens

***

Asterisks

___

Underscores
Three or more...
{% endhighlight %}

Three or more...

---

Hyphens

***

Asterisks

___

Underscores
Three or more...

[Top](#table-of-contents)  

#### YouTube Videos

They can't be added directly but you can add an image with a link to the video like this:

{% highlight md %}
[![IMAGE ALT TEXT](http://img.youtube.com/vi/YOUTUBE_VIDEO_ID_HERE/0.jpg)](http://www.youtube.com/watch?v=YOUTUBE_VIDEO_ID_HERE "Video Title")
{% endhighlight %}

[![Foxes Dr. Who](http://img.youtube.com/vi/h-OTYT02W7E/0.jpg)](http://www.youtube.com/watch?v=h-OTYT02W7E "Foxes Dr. Who")

[Top](#table-of-contents)  
