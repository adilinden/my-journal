---
layout: post
title: Installing Stager on Debian GNU/Linux (Sarge)
date: 2005-10-25 00:10:14
comments: Yes
tags:

redirect_from:
  - /article/installing-stager-debian-gnu-linux-sarge/
category:
  - Sysadmin
assets: resources/2005-10-25-installing-stager-debian-gnu-linux-sarge
---

This document describes the installation of a [Debian GNU/Linux (Sarge)](http://www.debian.org/) server for the purpose of collecting and presenting [NetFlow](http://www.cisco.com/en/US/products/ps6601/products_ios_protocol_group_home.html) data.  The [NetFlow](http://www.cisco.com/en/US/products/ps6601/products_ios_protocol_group_home.html) packets are collected using [flow-tools](http://www.splintered.net/sw/flow-tools/).  The data is processed and presented using [Stager](http://software.uninett.no/stager/).

**_Prerequisites_**

The Stager system reuqires information about routers such as names for interfaces. Several methods are available to aquire this information. Typically the router hostname is obtained by looking up ip address in DNS and interface descriptions are obtained via SNMP.  This presents some challenges for our implementation, the reverse DNS for router ip addresses resolves to some meaningless generic name. The interface descriptions contain information unsuitable for netflow.

For the purpose of this document, we maintain router names and interface descriptions in manual text files.

A source for netflow packets is required. Typical Cisco IOS configuration would look like this, assuming 192.168.10.99 is the IP address of this server we are about to build.

    ip flow-export version 5
    ip flow-export destination 192.168.10.99 9997

**_System Installation_**

**Debian Install**
Install a basic Debian Sarge system. Do not select any particular packages during install. Needed packages will be installed as needed using apt-get.

Use the manual partitioning option to partition the drive.

    /boot           200 MB (primary)
    swap           1000 MB (logical)
    /              1600 MB (logical)
    /tmp           2000 MB (logical)
    /usr           4400 MB (logical)
    /home          4800 MB (logical)
    /var          16000 MB (logical)
    /space         fill

**Essential Packages**
Install the following useful tools and packages.

    apt-get install sysv-rc-conf
    apt-get install vim
    apt-get install rsync
    apt-get install ntp-simple
    apt-get install ntpdate
    apt-get install bzip2
    apt-get install gawk
    apt-get install lynx
    apt-get install zip
    apt-get install unzip
    apt-get install postfix

**Unwanted Services**
In order to keep this server secure only specifically needed services should be running. Use the sysv-rc-conf tool to disable lpd, nfs-common, portmap, ppp.

Edit the `/etc/inetd.conf` file and comment identd and other service to disable.

**SMP Kernel**
Since this particular machine is a dual CPU server an SMP kernel image is quite useful. Use apt to find available kernel images and install the SMP kernel of your choice.

    apt-cache search 'kernel-image.*smp'
    apt-get install kernel-image-2.6-686-smp

Reboot the server to run the SMP kernel. To see CPU utilization of each CPU use 'top' and type '1'

**_System Configuration_**

**ntp**
The `/etc/ntp.conf` needs to be edited to obtain time from our local ntp server.  A suitable `/etc/ntp.conf` is:

    # /etc/ntp.conf, configuration for ntpd
    
    # File locations
    driftfile /var/lib/ntp/ntp.drift
    statsdir /var/log/ntpstats/
    logfile /var/log/ntpd
    
    # The server we connect to
    server 192.168.10.78
    restrict 192.168.10.78 nomodify
    
    # ... and use the local system clock as a reference if all else fails
    server 127.127.1.0
    fudge 127.127.1.0 stratum 13
    
    # By default noone is allowed to access this host
    restrict default ignore
    
    # Local users may interrogate the ntp server more closely.
    restrict 127.0.0.1 nomodify

The `/etc/default/ntpdate` needs to be edited to set the time at system boot.  Change the following line:

    NTPSERVERS="192.168.10.78"

**postfix**
The `/etc/postfix/main.cf` file contains all significant postfix configuration information. Just one line needs to be added to have postfix limited to only localhost and not listen on public interfaces:

    inet_interfaces = localhost.localdomain

**_Stager System Installation_**

**apache**
Install apache from Debian packages. Do not enable suexec.

    apt-get install apache
    apt-get install apache-dev

**postgresql**
Install postgresql from Debian packages.

    apt-get install postgresql
    apt-get install postgresql-dev

**perl**
Some additional perl modules are required. These are available as packages.

    apt-get install libdbi-perl
    apt-get install libdbd-pg-perl
    apt-get install libnet-dns-perl
    apt-get install libsnmp-perl

**php**
Some libraries are required to build php.

    apt-get install libxml2-dev
    apt-get install libgd2
    apt-get install libgd2-dev

The php apache module is installed from source. It appears that the Debian php package lags significantly behind official php releases and security fixes. To simplify building and rebuilding of php a build script is use.  Obtain the latest php release and adjust the release number in [build_php_4.sh]({{ site.baseurl }}/{{ page.assets }}/build_php_4.sh).

    mkdir /usr/local/src/php
    cd /usr/local/src/php
    wget http://ca3.php.net/get/php-4.4.0.tar.bz2/from/ca.php.net/mirror
    ./build_php_4.sh

The `/usr/local/lib/php.ini` file is edited to include `/usr/local/lib/php` in the include_path statment:

    include_path = ".:/usr/local/lib/php"

The `/usr/lib/apache/1.3/500mod_php4.info` file is created with the following content:

    LoadModule php4_module /usr/lib/apache/1.3/libphp4.so

The `/etc/apache/httpd.conf` file is edited. The lines that tell apache to parse certain extensions as php are uncommented. In particular these lines are to be uncommented:

    AddType application/x-httpd-php .php
    AddType application/x-httpd-php-source .phps

Finally the apache configuration utility is run and the apache daemon restarted.

    apache-modconf apache enable  mod_php4
    /etc/init.d/apache restart

**pear**
The PEAR::DB library is required. Although php includes pear, this is not included.

    pear install DB

**jpgraph**
Obtain [jpgraph](http://www.aditus.nu/jpgraph/) and install.

    cd /usr/local/src/php/
    wget http://members.chello.se/jpgraph/jpgdownloads/jpgraph-1.19.tar.gz
    tar xzf jpgraph-1.19.tar.gz
    cp -r jpgraph-1.19/src /usr/local/lib/php/jpgraph

**smarty**
Obtain [smarty](http://smarty.php.net/) and install.

    cd /usr/local/src/php/
    wget http://smarty.php.net/do_download.php?download_file=Smarty-2.6.10.tar.gz
    tar xzf Smarty-2.6.10.tar.gz
    cp -r Smarty-2.6.10/libs /usr/local/lib/php/Smarty

**flow-tools**
Obtain [flow-tools](http://www.splintered.net/sw/flow-tools/) and install.

    mkdir /usr/local/src/flow-tools
    cd /usr/local/src/flow-tools
    wget ftp://ftp.eng.oar.net/pub/flow-tools/flow-tools-0.68.tar.gz
    tar xzf flow-tools-0.68.tar.gz
    cd flow-tools-0.68
    ./configure --prefix=/usr/local
    make && make install

**stager**
Create a new user for stager.

    groupadd netflow
    useradd -g netflow -d /var/netflow netflow
    mkdir /var/netflow

Obtain stager.

    mkdir /usr/local/src/stager
    cd /usr/local/src/stager
    wget http://software.uninett.no/stager/download/Stager-1.2.4.tar.gz
    tar xzf Stager-1.2.4.tar.gz
    cd Stager_1_2_4

Install the backend. Accept the presented password or choose a sensible new password.

    ./stager-install.pl         --type=backend      --prefix=/var/netflow       --backends=netflow      --backends=snmp

Fix permissions for some scripts installed by the stager backen installation.

    chmod 755 /var/netflow/stager/bin/netflow_db_install.pl
    chmod 755 /var/netflow/stager/bin/opointmanage.pl
    chmod 755 /var/netflow/stager/bin/spoller.pl
    chmod 755 /var/netflow/stager/bin/topology2dot.pl

Create a temporary directory for stager.

    mkdir /var/netflow/stager-tmp
    chown netflow.netflow /var/netflow/stager-tmp

Install the frontend. The stager owner is 'netflow' and the web group is 'www-data'.

    ./stager-install.pl         --type=frontend         --prefix=/var/www       --backends=netflow      --backends=snmp

**snmp**
Install snmp command line tools.

    apt-get install snmp

**_Stager System Configuration_**

**flow-tools**
Create a directory to store flow-tools raw data.

    mkdir /var/netflow/raw

Install the [flow-capture.init]({{ site.baseurl }}/{{ page.assets }}/flow-capture.init) script as `/etc/init.d/flow-capture`. Use the sysv-rc-conf tool to start flow-capture at the desired run levels.

Make sure the init file is executable.

    chmod 755 /etc/init.d/flow-capture

**postgresql**
Prepare a user for the stager postgres databases.

    su postgres
    psql template1
    create user netflow with password '<password>' createdb;
    q
    exit

Edit `/etc/postgresql/pg_hba.conf`, add the following entry before any other entries.

    local  all    netflow                                       password
    host   all    netflow    127.0.0.1        255.255.255.255   password

Restart postgresql.

    /etc/init.d/postgresql restart

**stager backend**
Edit the `/var/netflow/stager/etc/netflow.cfg` configuration file. Edit the lines that specify the database user and passwords.

    db_name=stager
    db_user=netflow
    db_pass=<password>
    db_host=localhost
    db_port=5432
    
    tmp_path=/var/netflow/stager-tmp
    
    gri_text_cfg=routers.cfg

Edit the `/var/netflow/stager/etc/snmp.cfg` configuration file. Edit the lines that specify the database user and passwords.

    db_name=stager_snmp
    db_user=netflow
    db_pass=<password>
    db_host=localhost
    db_port=5432
    
    snmp_root=/var/netflow/raw/genplot

Run the database initialization script. You will be prompted for the netflow database user password multiple times.

    /var/netflow/stager/bin/db_install.pl --clean --backend=netflow

The next step will update the database with router information. This step has to be done every time a new router is configured to send netflow data to stager.  Edit `/var/netflow/stager/bin/getRouterInfo.sh` to point to the location where flow-capture stores raw data.

    dpath="/var/netflow/raw"

Create the `/var/netflow/stager/etc/exporters.cfg` file. It needs to contain name resolution information for all routers we receive netflow traffic from.

    10.97.97.3          rtr-lib-sl

Create the `/var/netflow/stager/etc/routers.cfg` file. It needs to contain information on all the router interfaces we receive netflow information about.

Execute the `stager/bin/getRouterInfo.sh script`. Running it first in trial mode (use the `--dry-run` arg) is recommended. If all looks well run it for real to populate the database.

    su - netflow
    ./stager/bin/getRouterInfo.sh --dry-run -v --plugin=text
    exit

If all looks well go for the real thing.

    su - netflow
    ./stager/bin/getRouterInfo.sh --plugin=text
    exit

Manually update the time stamps. Note: replace the date with the current date.

    psql -U netflow stager
    UPDATE obs_point_descr SET timestamp = '2005-10-21';
    q

Create cron entries to populate the database with flow data. These processes should run as netflow user.

    crontab -u netflow -e

Here is an example crontab.

    # get-netflow, hourly
    15  * * * * $HOME/stager/bin/get-netflow.pl
    
    # aggregate, daily
    45 01 * * * $HOME/stager/bin/aggregate.pl --backend=netflow --interval '1 day'  --timeformat 'YYYY-MM-DD'
    
    # aggregate, weekly
    50 02 * * 1 $HOME/stager/bin/aggregate.pl --backend=netflow --interval '1 week' --timeformat 'YYYY-IW' --no-cap
    
    # aggregate, monthly
    45 03 1 * * $HOME/stager/bin/aggregate.pl --backend=netflow --interval '1 mon'  --timeformat 'YYYY-MM'
    
    # purge, daily
    45 04 * * * $HOME/stager/bin/purge.pl --backend netflow

**apache and php**
The default web root for the Debian apache install is `/var/www`. We installed the stager frontend in `/var/www/stager`. This means stager is automatically availabe at the `http://example.com/stager` location.

Edit `/usr/local/lib/php/php.ini`. Modify the include_path statement and adjust the memory limit

    include_path = ".:/usr/local/lib/php:/usr/local/lib/php/Smarty:/usr/local/lib/php/jpgraph"
    memory_limit = 20M

Restart apache.

    /etc/init.d/apache restart

**stager frontend**
Edit the `/var/www/stager/config/user.config.php` configuration file. Of most importance is the database section.

    'db' => array(
        'my_db' => array(
            'name'          => 'My Database',
            'phptype'       => 'pgsql',
            'database'      => 'stager',
            'username'      => 'netflow',
            'password'      => '<password>',
            'hostspec'      => 'localhost',
            'port'          => '5432'
        )
    ),

**stager user access control**
Ok, this needs work :)  User access is controlled via sql commands. There is no web frontend for this. Each time `getRouterInfo.pl` adds new descriptors the user access has to be reapplied (as I understand the instructions).
