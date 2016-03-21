---
layout: post
title: AWStats on Debian (Sarge)
date: 2005-10-26 21:15:03
comments: Yes
tags:

redirect_from:
  - /article/awstats-on-debian-sarge/
category:
  - Sysadmin
assets: resources/2005-10-27-awstats-on-debian-sarge
---

AWStats is a log analyzer for apache logs. It is available at [http://awstats.sourceforge.net/](http://awstats.sourceforge.net/).

AWStats consists of a number of perl scripts and related files. There is no build in the sense of compiling required. Even though awstats has been designed as a cgi that creates statistics dynamically it also supports static html pages. I choose to run awstats on a daily basis to generate static pages. No cgi access provided. This eliminates all cgi related security risks and also places the load of processing log information at a controlled time when overall server load is low.

**Installation**
Download and expand the awstats package.

    cd /usr/local/src
    wget http://unc.dl.sourceforge.net/sourceforge/awstats/awstats-6.4.tgz
    tar xzf awstats-6.4.tgz
    cd awstats-6.4

Install the various awstats files. Since we do not need cgi access the file locations differ significantly from the official installation instructions.

    mkdir -p /usr/share/awstats/etc
    mkdir -p /usr/share/awstats/lang
    mkdir -p /usr/share/awstats/lib
    mkdir -p /usr/share/awstats/plugins
    mkdir -p /usr/share/awstats/icons
    mkdir -p /usr/share/awstats/tools
    
    cp -r wwwroot/cgi-bin/lang/* /usr/share/awstats/lang/
    cp -r wwwroot/cgi-bin/lib/* /usr/share/awstats/lib/
    cp -r wwwroot/cgi-bin/plugins/*.pm /usr/share/awstats/plugins/
    cp -r wwwroot/icon/* /usr/share/awstats/icons/
    cp    wwwroot/cgi-bin/awstats.pl /usr/share/awstats/tools/
    cp    tools/awstats_buildstaticpages.pl /usr/share/awstats/tools/
    cp    wwwroot/cgi-bin/awstats.model.conf /usr/share/awstats/etc/

Fix permissions for the installed files. Only directories, `tools/*` and `awstats.pl' itself should have execute permissions.

    chmod -R u=rw,g=r,o=r /usr/share/awstats
    chmod -R u+X,g+X,o+X /usr/share/awstats
    chmod 755 /usr/share/awstats/tools/*

Create working directories for awstats.

    mkdir -p /var/lib/awstats
    mkdir -p /var/www/awstats

**Configuration**
Edit the `/usr/share/awstats/etc/awstats.model.conf` configuration file template.  The important required changes are:

    LogFile="/var/log/apache/access.log.1"
    LogFormat = "%virtualname %host %other %logname %time1 %methodurl %code %bytesd %refererquot %uaquot"
    HostAliases="localhost 127.0.0.1"
    DNSLookup=1
    DirData="/var/lib/awstats"
    DirIcons="/awstats-icons"
    DirLang="/usr/share/awstats/lang"
    LoadPlugin="hashfiles"

The main apache configuration file `/etc/apache/httpd.conf` needs to be edited.  For awstats to recognize virtual hosts the requested hostname has to appear in the log file. A new LogFormat is added and the CustomLog directive is changed to log the new format.

    # AWStats log format
    LogFormat "%v %h %l %u %t "%r" %>s %b "%{Referer}i" "%{User-Agent}i"" awstats
    
    # CustomLog /var/log/apache/access.log combined
    CustomLog /var/log/apache/access.log awstats

To make the awstats output accessable add these aliases to the apache configuration:

    Alias /awstats/              /var/www/awstats/
    Alias /awstatsicons/         /usr/share/awstats/icons/

For the apache changes to take effect and proper log file to be written a logrotation of the apache logs needs to be forced.

    logrotate -f /etc/logrotate.d/apache

**Operation**
The  `run-awstats.sh` needs to be installed in `/usr/share/awstats/tools` This script is a wrapper for `awstats_buildstaticpages.pl` and `awstats.pl`. It created individual configurations files and an index.html file as it is run for each virtual host.

The script is run daily by logrotate. If log files are compressed makes sure the delaycompress directive is specified. This keeps the first rotated log file uncompressed and available for awstats to process as a postrotate script.

Run `/usr/share/awstats/tools/run-awstats.sh` from command line with no args for a complete explanation of available arguments. Pay particular attention to the `--domain` and `--aliases` swithes. These are used to match vitual hosts entries in the log file.

Edit `/etc/logrotate.d/apache`. Here is a complete example:

    /var/log/apache/*.log {

        # Rotate log daily
        daily
        # Keep 3 month worth
        rotate 90

        missingok
        compress
        delaycompress
        notifempty
        create 640 root adm
        sharedscripts
        postrotate
           if [ -f /var/run/apache.pid ]; then              if [ -x /usr/sbin/invoke-rc.d ]; then                 invoke-rc.d apache reload > /dev/null;              else                 /etc/init.d/apache reload > /dev/null;              fi;            fi;            /usr/share/awstats/tools/run-awstats.sh --domain domain1.com;            /usr/share/awstats/tools/run-awstats.sh --domain domain2.com;            /usr/share/awstats/tools/run-awstats.sh --domain domain3.com;            /usr/share/awstats/tools/run-awstats.sh --index;
        endscript
    }

After the file has been modified it would be good to run logrotate to catch any possible errors.

    logrotate -f /etc/logrotate.d/apache

**run-awstats.sh**
Here is the listing for the `run-awstats.sh  script:

    #!/bin/bash
    
    #
    # This script will run awstats. The result are static html pages for virtual
    # hosts.
    #
    # Based on command line arguments the script will create a awstats
    # configuration file. It then proceeds to execute awstats_buildstaticpages.pl
    # which is a wrapper for the actual awstats.pl script.
    #
    
    bindir="/usr/share/awstats/tools"
    etcdir="/usr/share/awstats/etc"
    outbase="/var/www/awstats"
    wrkbase="/var/lib/awstats"
    
    awstats="${bindir}/awstats.pl"
    awstats_static="${bindir}/awstats_buildstaticpages.pl"
    awstats_model="${etcdir}/awstats.model.conf"
    
    idxfile="${outbase}/index.html"
    idxcache="${wrkbase}/awstats.cache.txt"
    
    domain=""
    alias=""
    handle=""
    doindex=""
    debug=""
    
    #
    # Usage
    #
    usage()
    {
        echo "Usage: run-awstats.sh [OPTION]..."
        echo "Create static awstats pages for virtual hosts."
        echo "Example: run-awstats.sh --domain example.com"
        echo ""
        echo "Mandatory parameters:"
        echo "  --domain DOMAIN        DOMAIN is the main domain name for the virtual host"
        echo "                         This is equvalent to apache's ServerName directive."
        echo ""
        echo "Optional parameters:"
        echo "  --aliases ALIAS        ALIAS is another name the virtual host may beaccessed"
        echo "                         as. This is equivalent to apache's ServerAlias"
        echo "                         directive. Multiple aliases may be specified as a"
        echo "                         space seperated list. Enclose the list of aliases"
        echo "                         in quotes. Example: --aliases "alias1 alias3 alias3"."
        echo "  --handle HANDLE        Use HANDLE to specify a string (i.e. username) to"
        echo "                         name files and directories for awstats. If omitted"
        echo "                         DOMAIN is used."
        echo "  --index                Create index.html in web root. This should be run"
        echo "                         on its own after multiple virtual hosts have been"
        echo "                         processed."
        echo "  --debug                Print informations as the script runs."
        echo ""
        echo "Report bugs to <adi@adis.on.ca>."
        exit
    }
    
    #
    # Debug
    #
    decho()
    {
        if [ "$debug" != "" ]; then
            echo $*
        fi
    }
    
    #
    # Index
    #
    # Create an index html from the $idxcache. This will create a nice directory
    # to the statistics pages of the various virtual hosts.
    #
    index()
    {
        # Check for $idxcache
        if [ ! -r "$idxcache" ]; then
            echo "Error: File not found: $idxcache"
      exit 1
        fi
        decho "Reading $idxcache"
      
        # Set time stamp
        idxdate=`date '+%A, %B %e, %Y at %T %Z'`
    
        decho "Writing header to file: $idxfile"
        indexhead > "$idxfile"
    
        while read idxdomain idxhandle idxpath; do
            decho "Writing domain information: $idxdomain "
            indexlist >> "$idxfile"
        done < "$idxcache"
    
        decho "Writing footer to file: $idxfile"
        indexfoot >> "$idxfile"
    
        decho "Clearing cache file: $idxcache"
        > "$idxcache"
    }
    
    #
    # Index list
    #
    indexlist()
    {
        cat<<-EOF
        <li>Statistics for <a href="${idxpath}" title="${idxdomain}">${idxdomain}</a> 
    EOF
    }
    
    #
    # Index header
    #
    indexhead()
    {
        cat<<-EOF
    <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
    <html>
    <head>
      <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
      <title>AWStats :: Virtual Host Traffic Statistics</title>
      <style type="text/css">
      <!--
      body { 
          font: 12px verdana, arial, helvetica, sans-serif; 
          background-color: #FFFFFF; 
      }
      b { 
          font-weight: bold; 
      }
      a { 
          font: 12px verdana, arial, helvetica, sans-serif; 
      }
      a:link { 
          color: #0011BB; 
          text-decoration: none; 
      }
      a:visited { 
          color: #0011BB; 
          text-decoration: none; 
      }
      a:hover { color: #605040; 
          text-decoration: underline; 
      }
      .title {
          color: #000000;
          font-weight: bold;
          font-size: 14px; 
      }
      .lastupdated {
          color: #880000; 
          font-size: 10px; 
      }
      .lastupdatedtitle {
          color: #000000; 
          font-size: 10px; 
      }
      .credits {
          color: #CCCCCC; 
          font-size: 10px; 
      }
      //-->
      </style>
    </head>
    <body>
      <font class="title">Virtual Host Traffic Statistics</font>
      <br><font class="lastupdatedtitle">Last Update:</font>
      <font class="lastupdated">$idxdate</font>
      <ul>
    EOF
    }
    
    #
    # Index footer
    #
    indexfoot()
    {
        cat<<-EOF
      </ul>
      <p><span class="credits">Created by run-awstats.sh</span>
    </body>
    </html>
    EOF
    }
    
    #
    # Main
    #
    
    # Collect command line args
    while [ "$1" != "" ] ; do
        case $1 in
            # Server domain name
            --domain)
          if [ "$2" != "" ]; then
              domain=$2
        shift
                fi
          ;;
            # Server alias(es)
      --aliases)
          if [ "$2" != "" ]; then
            aliases=$2
        shift
                fi
          ;;
            # Handle, aka username
      --handle)
          if [ "$2" != "" ]; then
            handle=$2
        shift
                fi
          ;;
            # Create index
      --index)
          doindex="1"
          ;;
            # Be verbose
            --debug)
          debug="1"
          ;;
            # User is clueless
            *)
          usage
          exit
          ;;
        esac
        shift
    done
    
    if [ "$doindex" != "" ]; then
        index
        exit
    fi
    
    # Catch missing required args
    if [ "$domain" = "" ]; then
        echo "Error: Missing server domain!"
        echo
        usage
        exit 1
    fi
    
    # Catch missing awstats
    if [ ! -r "$awstats" ]; then
        echo "Error: Defective awstats install! Missing file:"
        echo "  '$awstats'!"
        exit 1
    fi
    if [ ! -r "$awstats_static" ]; then
        echo "Error: Defective awstats install! Missing file:"
        echo "  '$awstats_static'!"
        exit 1
    fi
    if [ ! -r "$awstats_model" ]; then
        echo "Error: Defective awstats install! Missing file:"
        echo "  '$awstats_model'!"
        exit 1
    fi
    
    # Generate domain specific variables
    if [ "$handle" = "" ]; then
        handle=$domain
    fi
    outdir="${outbase}/${handle}"
    wrkdir="${wrkbase}/${handle}"
    wrkcfg="${wrkbase}/awstats.${handle}.conf"
    
    decho
    decho "Working Parameters:"
    decho "-------------------"
    decho "Server name: $domain"
    decho "Server alias: $aliases"
    decho "Output directory: $outdir"
    decho "Working directory: $wrkdir"
    decho "Working configuration: $wrkcfg"
    decho
    
    # Make sure directories exist
    if [ ! -d "$outdir" ]; then
        decho "Creating directory: $outdir"
        mkdir -p "$outdir"
    fi
    if [ ! -d "$wrkdir" ]; then
        decho "Creating directory: $wrkdir"
        mkdir -p "$wrkdir"
    fi
    
    # Save the information to $idxcache for index building
    #
    # Format of the file is tab delimited with the following fields:
    # DOMAIN<tab>HANDLE<tab>RELPATH
    #
    idxpath="./${handle}/awstats.${handle}.html"
    echo -ne "${domain}t${handle}t${idxpath}n" >> "$idxcache"
    
    # Create working configuration from model configuration
    #
    # Use regex to edit config parameters
    #     SiteDomain="$domain"
    #     HostAliases="$aliases"
    #     DirData="$wrkdir"
    #
    regex="s/^(SiteDomain=).*$/1"$domain"/;"
    regex="${regex}s/(^HostAliases=).*$/1"$aliases"/;"
    regex="${regex}s|^(DirData=).*$|1"$wrkdir"|;"
    
    decho "Creating configuration file: $wrkcfg"
    sed "$regex" "$awstats_model" > "$wrkcfg"
    
    # Run the awstats_buildstaticpages.pl script
    awstats_cmd=""
    awstats_cmd="${awstats_cmd} $awstats_static"
    awstats_cmd="${awstats_cmd} -update"
    awstats_cmd="${awstats_cmd} -configdir="$wrkbase""
    awstats_cmd="${awstats_cmd} -config="$handle""
    awstats_cmd="${awstats_cmd} -awstatsprog="$awstats""
    awstats_cmd="${awstats_cmd} -diricons=/awstats-icons"
    awstats_cmd="${awstats_cmd} -dir="$outdir" "
    
    decho "Finally, running awstats ..."
    if [ "$debug" != "" ]; then
        eval $awstats_cmd
    else
        eval $awstats_cmd > /dev/null
    fi



