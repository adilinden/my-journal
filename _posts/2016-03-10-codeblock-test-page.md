---
layout: post
title:  "Codeblock Test Page"
date:   2016-03-10 21:25:50
comments: Yes
tags:
  - rouge
  - test page
categories:
  - test page
assets:
---

This page demontrates various ways code blocks can be structured in Markdown. It compares a backtick fenced codeblock, a liquid tag enclosed codeblock and an indented codeblock.  Each section displays the raw Markdown, the HTML structure (from rendered page source at time of writing) and finally the rendered code block.

### Table of Contents

[Backtick Fenced Codeblock](#backtick-fenced-codeblock)  
[Liquid Tag Enclosed Codeblock](#liquid-tag-enclosed-codeblock)  
[Indented Code](#indented-code)  
[Direct Comparison](#direct-comparison)  
[Line Numbers](#line-numbers)  
[Inline Code](#inline-code)  

### Backtick Fenced Codeblock

Markdown source

{% highlight md %}
``` coffeescript
# Objects:
math =
  root:   Math.sqrt
  square: square
  cube:   (x) -> x * square x
```
{% endhighlight %}

HTML Structure

{% highlight html %}
<div class="highlighter-rouge">
  <pre class="highlight">
    <code>
      <!-- Code -->
    </code>
  </pre>
</div>
{% endhighlight %}

Rendered output

``` coffeescript
# Objects:
math =
  root:   Math.sqrt
  square: square
  cube:   (x) -> x * square x
```

### Liquid Tag Enclosed Codeblock

Markdown source

{% highlight md %}{% raw %}
{% highlight coffeescript %}
# Objects:
math =
  root:   Math.sqrt
  square: square
  cube:   (x) -> x * square x
{% endhighlight %}{% endraw %}
{% endhighlight %}

HTML Structure

{% highlight html %}
<figure class="highlight">
  <pre>
    <code class="language-coffeescript" data-lang="coffeescript">
      <!-- Code -->
    </code>
  </pre>
</figure>
{% endhighlight %}

Rendered output

{% highlight coffeescript %}
# Objects:
math =
  root:   Math.sqrt
  square: square
  cube:   (x) -> x * square x
{% endhighlight %}

### Indented Code 

Markdown source

{% highlight md %}
    # Objects:
    math =
      root:   Math.sqrt
      square: square
      cube:   (x) -> x * square x
{% endhighlight %}

HTML Structure

{% highlight html %}
<div class="highlighter-rouge">
  <pre class="highlight">
    <code>
      <!-- Code -->
    </code>
  </pre>
</div>
{% endhighlight %}

Rendered output

    # Objects:
    math =
      root:   Math.sqrt
      square: square
      cube:   (x) -> x * square x

### Direct Comparison

And for good measure the three different types of code blocks in direct comparison.  This makes it easier to verify the outcome of CSS syntax highlighting, etc.

Backtick fenced...

``` coffeescript
# Objects:
math =
  root:   Math.sqrt
  square: square
  cube:   (x) -> x * square x
```

Liquid tagged...

{% highlight coffeescript %}
# Objects:
math =
  root:   Math.sqrt
  square: square
  cube:   (x) -> x * square x
{% endhighlight %}

Indented...

    # Objects:
    math =
      root:   Math.sqrt
      square: square
      cube:   (x) -> x * square x

### Line Numbers

Markdown source

{% highlight md %}{% raw %}
{% highlight coffeescript linenos %}
# Objects:
math =
  root:   Math.sqrt
  square: square
  cube:   (x) -> x * square x
{% endhighlight %}{% endraw %}
{% endhighlight %}

HTML Structure

{% highlight html %}
<figure class="highlight">
  <pre>
    <code class="language-coffeescript" data-lang="coffeescript">
      <table style="border-spacing: 0">
        <tbody>
          <tr>
            <td class="gutter gl" style="text-align: right">
              <pre class="lineno">
                <!-- Line Numbers -->
              </pre>
            </td>
            <td class="code">
              <pre>
                <!-- Code -->
              </pre>
            </td>
          </tr>
        </tbody>
      </table>
    </code>
  </pre>
</figure>
{% endhighlight %}

Rendered output

{% highlight coffeescript linenos %}
# Objects:
math =
  root:   Math.sqrt
  square: square
  cube:   (x) -> x * square x
{% endhighlight %}

### Inline Code

Inline code is also possible.  I am aware of backticks or html to do this.

{% highlight md %}
Here is sample `inline code` within a sentence.
{% endhighlight %}

Here is sample `inline code` within a sentence.

{% highlight md %}
Here is sample <code>inline code</code> within a sentence.
{% endhighlight %}

Here is sample <code>inline code</code> within a sentence.
