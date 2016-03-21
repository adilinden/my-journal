---
layout: post
title: Redirect HTTP Requests
date: 2004-10-18 20:35:33
comments: 
tags:

redirect_from:
  - /article/redirect-http-requests/
category:
  - Coding
assets: resources/2004-10-19-redirect-http-requests
---

Here is a small perl script I wrote to redirect http requests from one server to another. Intead of running web server software, such as apache, this little script is invoked by inetd. The inetd daemon is configured to listen to port 80 and any incoming connection to port at is passed to this script to be handled. I make no claims that this is secure or reasonable thing to do.
{% highlight perl %}
    #!/usr/bin/perl
    #
    # /usr/local/bin/http-redirect
    #
    # $Id: http-redirect,v 1.4 2004/10/18 23:55:46 adi Exp $
    # 
    # This perl script redirects browsers to another host/URL. It is meant to
    # be run from inetd or xinetd.
    #
    # This is an example configuration for xinetd:
    #
    #    service http-redirect
    #    {
    #        type                = UNLISTED
    #        socket_type         = stream
    #        protocol            = tcp
    #        wait                = no
    #        user                = nobody
    #        server              = /usr/local/bin/http-redirect
    #        port                = 80
    #        disable             = no
    #    }
    #
    # This is an example line for inetd
    #
    #    http stream tcp nowait nobody /usr/local/bin/http-redirect 
    #
    
    use POSIX;
    
    #
    # This subroutine returns time and date in rfc822 format. It wous found
    # at <http://www.tbray.org/ongoing/When/200x/2003/03/15/PerlGrind>.
    #
    sub rfc822
    {
        my $t = shift;
        $t = time unless $t;
        my $rfc822 = "%a, %d %b %G %T %Z";
        return POSIX::strftime($rfc822, localtime($t));
    }
    
    #
    # Define the parts of the message
    #
    $date = rfc822;
    $code = '302 Redirect';
    $url  = 'http://webmail.example.com/';
    
    $mbody = <<EOM;
    <!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML 2.0//EN">
    <HTML><HEAD>
    <TITLE>$code</TITLE>
    </HEAD><BODY>
    <H1>$code</H1>
    <P>This server has no documents.
    <P>Goto <a href="$url">$url</a> instead.
    </BODY></HTML>
    EOM
    
    $mlength = length($mbody);
    
    $mheader = <<EOM;
    HTTP/1.1 $code
    Date: $date
    Server: http-redirect/0.1
    Location: $url
    Content-Type: text/html
    Content-Length: $mlength
    EOM
    
    # Assemble message and make line termination CR+LF
    $message =  $mheader . "n" . $mbody;
    $message =~ s/n/rn/gm;
    
    # Read the input, actually we're just looking for a blank line
    while (<>) {
        last if (/^s*$/);
    }
    
    # Send output
    print $message;
    exit;
{% endhighlight %}
