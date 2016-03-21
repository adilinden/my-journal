---
layout: post
title: My Debian GNU/Linux (Sarge Release) Mail Server
date: 2005-10-09 22:17:30
comments: Yes
tags:

redirect_from:
  - /article/my-debian-gnu-linux-sarge-mail-server/
category:
  - Sysadmin
assets: resources/2005-10-10-my-debian-gnu-linux-sarge-mail-server
---

These instructions describe the installation of a Debian GNU/Linux based mail server. The server is a closed system, without user shell accounts. Mail accounts are administered using web based tools. This provides for excellent system security.

Note that these instructions are based on my installation notes, just prettied up a little. A fair bit of system administration knowledge is assumed. The information concentrates on installation and configuration of components that comprise the mail system. Setting passwords, adding users, configuring networking aren’t touched on and tasks the reader should be familiar with. With that out of the way, enjoy!

***

## Base System

### Installation

The Debian Sarge release is installed. This can be accomplished using a variety of methods. My prefered method is a network install using the official Debian “netinst” image. This ISO image of about 180MB size contains a small set of packages for a very basic system upon which the full system is built. The installation is completed with just the basic package selection.

During the installation process the drive is partitioned as follows:

    /               1000MB (primary)
    /usr            2600MB (logical)
    /var            1600MB (logical)
    /home           1200MB (logical)
    /tmp            1000MB (logical)
    swap            1000MB (logical)
    /var/cyrus         xMB (logical, remaining space)

### Additional Packages

The apt-get tool is used to install additional packages which I consider essential.

    apt-get install sysv-rc-conf
    apt-get install vim
    apt-get install ntp-simple
    apt-get install ntpdate
    apt-get install bzip2
    apt-get install rsync
    apt-get install gawk
    apt-get install lynx
    apt-get install zip
    apt-get install unzip

### Unwanted Services

While Debian is fairly secure after a basic installation there are still a few services that need to be disabled. The sysv-rc-conf tool is used to disable lpd, nfs-common, portmap, ppp. The `/etc/inetd.conf` file should be edited and the discard, daytime, time, identd services disabled.

***

## System Configuration

### apt

When these instructions were first conceived Sarge was still in testing phase. The `/etc/apt/sources.list` file should not require changes.

### ntp

The `/etc/ntp.conf` file is the configuration file for the ntpd time keeping daemon. Replace 192.168.77.4 with the IP address of a remote ntp server of your choice.

    # /etc/ntp.conf, configuration for ntpd

    # File locations
    driftfile /var/lib/ntp/ntp.drift
    statsdir /var/log/ntpstats/
    logfile /var/log/ntpd

    # The server we connect to
    server 192.168.77.4 
    restrict 192.168.77.4 nomodify

    # ... and use the local system clock as a reference if all else fails
    server 127.127.1.0
    fudge 127.127.1.0 stratum 13

    # By default noone is allowed to access this host
    restrict default ignore

    # Local users may interrogate the ntp server more closely.
    restrict 127.0.0.1 nomodify

The `/etc/default/ntpdate` file is the configuation file for ntpdate. It is used during the boot process to set the server clock to the correct time while the ntpd daemon keeps the clock accurate. Edit just one line in this file.

    NTPSERVERS="192.168.77.4"

### Backup

My servers run automated backups to a dedicated backup host. I strongly recommend a backup strategy. It is not a question “if” but “when” this machine will die.

### Power Conditioning

The server these instructions are based on is connected to a 300VA APC Back-UPS with serial port. This is quite sufficient to condition power and ride out short power interruptions of 5 minutes or less. To provide for a controlled shutdown during extended power outages the genpower package is installed and configured.

    apt-get install genpower

The `/etc/genpowerd.conf` file is edited to match the UPS and cabling used.

    ENABLED=true
    UPSPORT=/dev/ttyS0
    UPSSTAT=/var/run/upsstat
    UPSTYPE=apc-linux

The `/etc/init.d/powerfail` file is edited to begin shutdown 5 minutes into a power interruption.

    failtime=+5     # shutdown delay from initial power failure

The default Debian installation will halt the system. This may cause the system to go off and stay off is power returns while shutdown is in progress. When the `/etc/init.d/halt` script is called with the poweroff argument to kill the UPS it will send the kill signal to the UPS. If the kill fails it will continue to halt the system. The APC Back-UPS will not honor the kill command and turn off if proper line power is present. This opens a window of opportunity during which the server may stay off if power returned before `/etc/init.d/genpower` poweroff completes. The following changes to /etc/init.d/halt address this situation.

    poweroff)
        echo "Sending power-down signal to the UPS... "
        sync; sync; sleep 2
        $genpowerd -k >/dev/null 2>&1 
        #
        # Added by Adi 
        #
        # Reboot the system if killing UPS power failed 
        sleep 180 
        echo -n "Killing UPS failed... Rebooting now... "
        reboot -d -f -i
        # 
        exit $?
    ;;

The cabling wiring diagram I recommend (and based the configuration on) is as follows:

    UPS Side                           Serial Port Side
    9 Pin Male                         9 Pin Female

    Shutdown UPS 1 <---------------> 3 TX  (high = kill power)
    Line Fail    2 <---------------> 1 DCD (high = power fail)
    Ground       4 <---------------> 5 GND
    Low Battery  5 <----+----------> 6 DSR (low = low battery)
                        +--|  |----> 4 DTR (cable power)

### ssh

To improve security sshd is configured to refuse any attempt to login as root user. Before this step is taken it is important that a generic user account exists which can login and become superuser.

The `/etc/ssh/sshd_config` file is edited and the following line is added. (Note: Make the allowed user whichever non privileged system account you use to login!)

    DenyUsers root
    AllowUsers fred

***

## Mail Server Installation

### postfix

The postfix MTA Debian packages are installed.

    apt-get install postfix
    apt-get install postfix-tls
    apt-get install postfix-mysql

### mysql

The mysql Debian packages and development packages are installed.

    apt-get install mysql-server
    apt-get install libmysqlclient-dev

By default the mysql installation is very insecure as no root password is set. This next step sets the mysql root password.

    mysqladmin  -u root password <password>

The `/etc/mysql/my.cnf` file is edited to have the mysql daemon listening to localhost only. External network access to mysql is not needed for this installation and poses a security risk.

    #skip-networking        
    bind-address=127.0.0.1

Additional information about Debian specific mysql information can be found in `/usr/share/doc/mysql-server/README.Debian`.

### pam

The pam library provides authentication mechanims. We need additional support for mysql.

    apt-get install libpam-mysql

### cyrus-sasl

The cyrus-sasl package is used by cyrus-imapd and postifx to authenticate mail accounts via information stored in a mysql database. Some additional cyrus-sasl packages are installed.

    apt-get install sasl2-bin
    apt-get install libsasl2-modules

### cyrus-imapd

The cyrus-imapd package is installed from sources. The source archive is available at ftp://ftp.andrew.cmu.edu/pub/cyrus-mail/cyrus-imapd-2.2.12.tar.gz.

The cyrus-imapd build requires additional development tools.

    apt-get install libtool
    apt-get install autoconf
    apt-get install automake
    apt-get install automake1.6

The cyrus-imapd build further requires additional development packages.

    apt-get install libssl-dev
    apt-get install libdb4.2-dev
    apt-get install libsasl2-dev
    apt-get install libpam0g-dev

The `build_cyrus-imapd.sh` script is used to build and install cyrus-imapd. Create the `build_cyrus-imapd.sh` in the same directory as the cyrus-imapd-2.2.12.tar.gz file with the following content.

    #!/bin/bash -x
    
    version='2.2.12'
    
    rm -rf  cyrus-imapd-${version}
    tar xzf cyrus-imapd-${version}.tar.gz
    cd cyrus-imapd-${version}
    
    cd cmulocal
    #patch < ../../cyrus-imapd-berkdb.m4.diff
    cd ..
    
    rm -f config/libtool.m4
    rm -f configure
    sh SMakefile
    
    ./configure             --enable-sieve             --enable-servers             --disable-nntp             --disable-murder             --disable-cmulocal             --disable-gssapi             --with-cyrus-prefix=/usr/local/cyrus             --with-auth=unix             --with-dbdir             --with-bdb-libdir=/usr/lib             --with-bdb-incdir=/usr/include             --with-openssl=/usr             --with-perl             --with-sasl=/usr             --with-syslogfacility=LOCAL6             --without-afs             --without-ldap             --without-krb
    
    make
    make install
    
    mkdir /usr/local/cyrus/tools
    install -m 755 tools/* /usr/local/cyrus/tools

Run the `build_cyrus-imapd.sh` script. If it completes without errors your cyrus-imapd build should be installed.

    sh -x build_cyrus-imapd.sh

Since cyrus-imapd is a daemon a startup script is required. Create the `cyrus-imapd` script and install it in the `/etc/init.d` directory. Make sure the script is executable by modifying the file permissions.

    chmod 755 /etc/init.d/cyrus-imapd

### apache

The Debian Sarge package for the apache web server is installed.

    apt-get install apache
    apt-get install apache-dev

### php

The PHP scripting lanuage is installed from sources. Once again a build script is created to install php. Using the build script makes future upgrades much easier since in many case just the version information has to be changed and the new package installed. The php source package is downloaded from http://ca3.php.net/get/php-4.4.0.tar.bz2/from/ca.php.net/mirror.

The `build_php.sh` is created in the same directory as the php-4.4.0.tar.bz2 file.

    #!/bin/bash -x
    
    PHPVER=4.4.0
    
    bunzip2 -c php-${PHPVER}.tar.bz2 | tar x
    cd php-${PHPVER}
    ./configure         --with-apxs         --enable-pic         --enable-shared         --enable-force-cgi-redirect         --enable-trans-sid         --enable-track-vars         --enable-ftp         --enable-magic-quotes         --enable-safe-mode         --enable-sockets         --enable-cli         --with-gettext         --with-mysql         --with-mysql-sock=/var/run/mysqld/mysqld.sock         --with-pear         --with-regex=system
    make
    make install-pear
    make install-cli
    make install-programs
    install -m 644 libs/libphp4.so /usr/lib/apache/1.3/
    
    # Config file only if installed from scratch!
    if [ ! -f /usr/local/lib/php.ini ]; then 
        install -m 644 php.ini-dist /usr/local/lib/php.ini
    else
        install -m 644 php.ini-dist /usr/local/lib/php.ini.new
    fi
    
    if [ ! -f /etc/php.ini ]; then 
        ln -s /usr/local/lib/php.ini /etc/php.ini
    fi
    
Run the build_php.sh script. If it completes without errors your php DSO for apache should be installed.

    sh -x build_php.sh

The `/usr/local/lib/php.ini` file is edited to include `/usr/local/lib/php` in the include_path statment. Search for the include_path statement in the file and edit as below.

    include_path = ".:/usr/local/lib/php"

The `/usr/lib/apache/1.3/500mod_php4.info` file is created with the following content:
    
    LoadModule php4_module /usr/lib/apache/1.3/libphp4.so

The `/etc/apache/httpd.conf` file is edited. The lines that tell apache to parse certain extensions as php are uncommented. In particular these lines should be uncommented:

    AddType application/x-httpd-php .php
    AddType application/x-httpd-php-source .phps

Finally the apache configuration utility is run and the apache daemon restarted.

    apache-modconf apache enable mod_php4
    /etc/init.d/apache restart

***

## Mail Server Configuration

### apache

The apache web server is configured for virtual hosts. The default virtual host is our webmail domain. The `/etc/apache/conf.d/mail` configuration file is created:

    #
    # The default virtual host
    #
    <VirtualHost _default_>
        ServerName webmail.example.com
        DocumentRoot /home/mailhelp/html

    </VirtualHost>

A new user is created for the mailhelp directory.

    groupadd mailhelp
    useradd -m -g mailhelp mailhelp

The mailhelp directory is populated with html files, etc. This is the main page received by anyone accessing the server. Sorry, I don’t have any suitable help files available at this time. Still working on those myself.

### postfixadmin

The postfixadmin package provides a web frontend to administer domains and accounts. The archive is downloaded from http://high5.net/postfixadmin/download.php?file=postfixadmin-2.0.5.tgz. A patch is required to support cyrus-imapd with postfixadmin. Note that this patch is specific to the 2.0.5 release of postfixadmin. The patch is available at [postfixadmin-2.0.5-cyrus-imap.diff]({{ site.baseurl }}/{{ page.assets }}/postfixadmin-2.0.5-cyrus-imap.diff).

A new user is created.

    groupadd postfixadmin
    useradd -m -g postfixadmin postfixadmin

The apache configuration file `/etc/apache/conf.d/mail` is altered to make the postfixadmin directory accessible and to enable htaccess type authentication for the admin directory.

    Alias /postfixadmin  /home/postfixadmin/html

    <Directory /home/postfixadmin/html> 
        AllowOverride AuthConfig
    </Directory> 

The postfixadmin files are installed as the postfixadmin user.

    su - postfixadmin
    tar xzf postfixadmin-2.0.5.tgz
    mv postfixadmin-2.0.5 html

The `build/postfixadmin-2.0.5-cyrus-imap.diff` patch is applied to gain support for adding mailboxes and setting quota in cyrus-imapd. The `html/admin/.htaccess` file requires editing to point to the proper .htpasswd file.

    AuthUserFile /home/postfixadmin/html/admin/.htpasswd
    AuthGroupFile /dev/null
    AuthName "Postfix Admin"
    AuthType Basic

    <limit GET POST>
    require valid-user
    </limit>

The `html/admin/.htpasswd` file is recreated from scratch with the desired admin password.

    htpasswd -c -m html/admin/.htpasswd admin

The configuration file is created from the distribution example and edited to suit our particular configuration.

    cp html/config.inc.php.sample config.inc.php

The `html/DATABASE.TXT` file contains the databases that needed to be established on the mail servers mysql daemon. The DATABASE.TXT file requires edited. The passwords for postfix and postfixadmin need to be changed. In addition, the lines that add the postfixadmin user to the user and db tables are duplicated. Access for these users needed to be allowed from ‘localhost’ and ’127.0.0.1′. The DATABASE.TXT file is imported into mysql.

    mysql -u root -p < DATABASE.TXT

### squirrelmail

A home directory is needed for SquirrelMail. The webmail user account is created.

    groupadd squirrelmail
    useradd -m -g squirrelmail squirrelmail

The SquirrelMail user address books and preferences are configured to be in a mysql database but a directory to store attachments is still required.

    mkdir /var/cache/attachments
    chgrp -R www-data /var/cache/attachments
    chmod 730 /var/cache/attachments

A cronjob is installed that periodically removes files from the attachments directory. The `/etc/cron.daily/squirrelmail` file is created:

    #!/bin/bash
    #
    # This script removes old files from squirrelmails attachments directory.

    rm -f `find /var/cache/attachments -atime +2 | grep -v "." | grep -v _`

The `/etc/cron.daily/squirrelmail` permissions require modification.

    chmod 755 /etc/cron.daily/squirrelmail

The following is added to the apache configuration file `/etc/apache/conf.d/mail`:

    Alias /webmail /home/squirrelmail/html

The latest stable SquirrelMail release is downloaded and installed in the new webmail home directory.

    su - squirrelmail
    wget http://umn.dl.sourceforge.net/sourceforge/squirrelmail/squirrelmail-1.4.3a.tar.gz
    gunzip -c squirrelmail-1.4.3a.tar.gz | tar x
    mv squirrelmail-1.4.3a html
    cd html

Instructions for using a mysql backend for user preferences and user address books are found in `doc/db-backend.txt`. As instructed in the documentation, the necessary mysql databases need to be created.

    mysqladmin -u root -p create squirrelmail
    mysql -u root -p
    mysql> GRANT select,insert,update,delete ON squirrelmail.*
        ->  TO squirreluser@localhost IDENTIFIED BY '<password>';
    mysql> use squirrelmail;    
    mysql> CREATE TABLE address (
        ->      owner varchar(128) DEFAULT '' NOT NULL,
        ->      nickname varchar(16) DEFAULT '' NOT NULL,
        ->      firstname varchar(128) DEFAULT '' NOT NULL,
        ->      lastname varchar(128) DEFAULT '' NOT NULL,
        ->      email varchar(128) DEFAULT '' NOT NULL,
        ->      label varchar(255),
        ->      PRIMARY KEY (owner,nickname),
        ->      KEY firstname (firstname,lastname)
        ->    );
    mysql> CREATE TABLE userprefs (
        ->     user varchar(128) DEFAULT '' NOT NULL,
        ->     prefkey varchar(64) DEFAULT '' NOT NULL,
        ->     prefval BLOB DEFAULT '' NOT NULL,
        ->     PRIMARY KEY (user,prefkey)
        ->   );

The configuration script is run and some settings are altered.

    ./configure
      1.   Organization Preferences
        1.  Organization Name      : mail.example.com
        9.  Provider name          : 
      2.   Server Settings
        1.   Domain                 : example.com
        A.
          4.   IMAP Server            : mail.example.com
        B.
          4.   SMTP Server           : mail.example.com
          5.   SMTP Port             : 25
          6.   POP before SMTP       : false
          7.   SMTP Authentication   : login
          8.   Secure SMTP (TLS)     : false
      3.   Folder Defaults
        6.  By default, move to trash     : false
        7.  By default, move to sent      : true
        8.  By default, save as draft     : false
        11. Auto Expunge                  : false
        16. Auto Create Special Folders   : false
      4.   General Options
        3.  Attachment Directory        : /var/cache/attachments/
      9.
        1.  DSN for Address Book   : 
                   mysql://squirreluser:<password>@localhost/squirrelmail
        3.  DSN for Preferences    : 
                   mysql://squirreluser:<password>@localhost/squirrelmail

### websieve

The websieve user interface for sieve is installed on the web server. The project is hosted on SourceForge and the latest release can be downloaded from http://voxel.dl.sourceforge.net/sourceforge/websieve/websieve-063a.tar.gz.

A new user needs to be created for websieve:

    groupadd websieve
    useradd -m -g websieve websieve

The files are installed as the websieve user:

    su - websieve
    tar xzf websieve-063a.tar.gz
    mkdir html
    cp websieve-063a/websieve.pl cgi-bin/
    cp websieve-063a/websieve.conf cgi-bin/
    cp websieve-063a/funclib.pl cgi-bin/funclib.pl
    chmod 555 cgi-bin/websieve.pl

Some perl modules need to be installed. Get IMAP-Admin-1.4.3 from CPAN http://search.cpan.org/CPAN/authors/id/E/EE/EESTABROO/IMAP-Admin-1.4.3.tar.gz

    tar xzf IMAP-Admin-1.4.3.tar.gz
    cd IMAP-Admin-1.4.3
    perl Makefile.PL
    make
    make install
    cd ..

    cd websieve-063a
    tar xzf perlsieve-0.4.9b.tar.gz
    cd perlsieve-0.4.9
    perl Makefile.PL
    make
    make install

The `websieve-063a/websieve.conf` file is edited to configure websieve. The following statement is added to apache to enable access to websieve:

    ScriptAlias /websieve/   /home/websieve/cgi-bin/

Some changes to `cgi-bin/websieve.pl` are required for this setup. These changes are captured in http://adisworld.oodi.ca/files/posts/my-debian-gnu-linux-sarge-mail-server/websieve.pl.diff. Apply the patch as follows:

    cd websieve-063a
    patch -p1 < ../websieve.pl.diff

### postfix

The postfix configuration files are located in `/etc/postfix`. Wherever possible postfix daemons are installed chroot by Debian. This means that processes are unable to talk to `/var/run/mysqld/mysqld.sock`. The result are seg faults of various postfix services. There are two solutions, do not run postfix chroot or connect to mysql via 172.0.0.1, the latter is used.

The postfix configuration files and the suggested contents are (adjust domain names and passwords to suit):

* []({{ site.baseurl }}/{{ page.assets }}/main.cf)
* []({{ site.baseurl }}/{{ page.assets }}/master.cf)
* []({{ site.baseurl }}/{{ page.assets }}/mysql_virtual_alias.cf)
* []({{ site.baseurl }}/{{ page.assets }}/mysql_virtual_domains.cf)
* []({{ site.baseurl }}/{{ page.assets }}/mysql_virtual_limit.cf)
* []({{ site.baseurl }}/{{ page.assets }}/mysql_virtual_mailbox.cf)

For SMTP AUTH the postfix user has to be added to the sals group.

    adduser postfix sasl

The `/etc/postfix/sasl/smtpd.conf` file has to be created with the following content:

    pwcheck_method: saslauthd
    mech_list: plain login

A symlink has to be created. It appears that postfix expects to find the `/etc/postfix/sasl/smtpd.conf` and cyrus-sasl expected to find `/usr/lib/sasl2/smtpd.conf`.

    ln -s /etc/postfix/sasl/smtpd.conf /usr/lib/sasl2/smtpd.conf

### pam

User authentication is done via PAM. This requires some configuration files to be edited/created in `/etc/pam.d`. The `/etc/pam.d/common-mailservices` file:

    #
    # /etc/pam.d/common-mailservices
    #
    # This file is included by other mail services which use common mysql data to
    # authenticate users.
    #
    # This looks up the authentication information for mail users
    #
    
    auth        sufficient      pam_mysql.so         user=postfix         passwd=<password>         host=127.0.0.1         db=postfix         table=mailbox         usercolumn=username         passwdcolumn=password         crypt=1         md5=Y
    
    account     sufficient      pam_mysql.so         user=postfix         passwd=<password>         host=127.0.0.1         db=postfix         table=mailbox         usercolumn=username         passwdcolumn=password         crypt=1         md5=Y

The `/etc/pam.d/imap` file:

    #
    # The PAM configuration file for the 'imap' service
    #

    # Look up normal mail accounts
    @include common-mailservices
    
    # If login didn't succeed, perhaps we are a administrator?
    auth        sufficient      pam_mysql.so         user=postfix         passwd=<password>         host=127.0.0.1         db=postfix         table=admin         usercolumn=username         passwdcolumn=password         crypt=1         md5=Y
    
    account     sufficient      pam_mysql.so         user=postfix         passwd=<password>         host=127.0.0.1         db=postfix         table=admin         usercolumn=username         passwdcolumn=password         crypt=1         md5=Y

The `/etc/pam.d/pop` file:

    #
    # The PAM configuration file for the 'pop3' service
    #
    
    # Look up normal mail accounts
    @include common-mailservices

The `/etc/pam.d/sieve`file:

    #
    # The PAM configuration file for the 'sieve' service
    #
    
    # Look up normal mail accounts
    @include common-mailservices

The `/etc/pam.d/smtp` file:

    #
    # The PAM configuration file for the 'smtp' service
    #
    
    # Look up normal mail accounts
    @include common-mailservices

### cyrus-sasl

By Debian default the saslauthd socket is located in `/var/run/saslaulthd`. This is not suitable for running the postfix smtpd process chroot. A new location for the saslauthd is created:

    mkdir -p /var/spool/postfix/var/run/saslauthd
    chown root.sasl /var/spool/postfix/var/run/saslauthd
    chmod 750 /var/spool/postfix/var/run/saslauthd

The old `/var/run/saslauthd` directory is removed and symlinked to the new location.

    rmdir /var/run/saslauthd
    ln -s /var/spool/postfix/var/run/saslauthd /var/run/saslauthd

The `/etc/default/saslauthd` file control the behaviour of the saslauthd daemon in Debian. The file needs to contain the following lines:

    START=yes
    MECHANISMS="pam"
    PARAMS="-m /var/spool/postfix/var/run/saslauthd -r"
    PWDIR=/var/spool/postfix/var/run/saslauthd
    PIDFILE=/var/spool/postfix/var/run/saslauthd/saslauthd.pid

    # Create a symlink for our socket
    if [ ! -h /var/run/saslauthd ]; then 
        rm -rf /var/run/saslauthd
        ln -sf /var/spool/postfix/var/run/saslauthd /var/run/saslauthd
    fi  

Edit the `/etc/init.d/saslauthd` file and comment out two lines:

    #dir=`dpkg-statoverride --list $PWDIR`
    #test -z "$dir" || createdir $dir

The installation of the sasl2-bin package has the daemon automatically start
at the appropriate runlevel. To manually start he daemon now, run

    /etc/init.d/saslauthd

### cyrus-imapd

We built cyrus-imapd with logging to syslog facility LOCAL6. This requires some additional in /etc/syslog.conf. Just below the mail system logging insert

    #
    # Logging for the cyrus-imapd system
    #
    local6.*                        -/var/log/imapd.log

Next the log file needs to be created. Followed by a restart of the system logger.
    
    touch /var/log/imapd.log
    chown root.adm /var/log/imapd.log
    chmod 640 /var/log/imapd.log
    /etc/init.d/sysklogd restart

The cyrus-imapd configuration files need to be created. The `/etc/cyrus.conf` file is creaded with the following content:

    # standard standalone server implementation
    
    START {
      # do not delete this entry!
      recover   cmd="ctl_cyrusdb -r"
    }
    
    SERVICES {
      # add or remove based on preferences
      imap              cmd="imapd" listen="imap" prefork=1
      pop3              cmd="pop3d" listen="pop3" prefork=1
      imaps             cmd="imapd -s" listen="imaps" prefork=1
      pop3s             cmd="pop3d -s" listen="pop3s" prefork=1
      # sieve access is via web interface on localhost only
      #sieve    cmd="timsieved" listen="sieve" prefork=0
      sieve             cmd="timsieved" listen="127.0.0.1:sieve" prefork=1
    
      # at least one LMTP is required for delivery
      #lmtp             cmd="lmtpd" listen="lmtp" prefork=1
      lmtpunix  cmd="lmtpd" listen="/var/cyrus/imap/socket/lmtp" prefork=1
      # a socket dedicated for postfix inside the postfix chroot
      lmtppostfix       cmd="lmtpd" listen="/var/spool/postfix/socket/lmtp" prefork=1
    }
    
    EVENTS {
      # this is required
      checkpoint        cmd="ctl_cyrusdb -c" period=30
    
      # this is only necessary if using duplicate delivery suppression,
      # Sieve or NNTP
      delprune  cmd="cyr_expire -E 3" at=0400
    
      # this is only necessary if caching TLS sessions
      tlsprune  cmd="tls_prune" at=0400
    
      # purge message delvered 2 or more days ago
      purgejunkmail     cmd="ipurge -d2 -X -f *.junkmail" at=0230
    
    }

The `/etc/imapd.conf` file is created with the following content:

    # /etc/imapd.conf
    
    # General
    postmaster: postmaster
    configdirectory: /var/cyrus/imap
    partition-default: /var/cyrus/mail
    syslog_prefix: imapd
    admins: cyrus
    
    # Sieve
    sievedir: /var/cyrus/sieve
    sendmail: /usr/lib/sendmail
    
    # Virtual domain support 'user' @ 'domain.tdl'
    virtdomains: userid
    #defaultdomain:
    
    # Maildir/namespace/account creation
    unixhierarchysep: no
    altnamespace: no
    autocreatequota: 10000
    
    # Databases
    annotation_db: skiplist
    duplicate_db: skiplist
    mboxlist_db: flat
    quota_db: quotalegacy
    seenstate_db: flat
    subscription_db: flat

    # tls/ssl support
    tls_ca_file: /var/cyrus/tls/CA.crt
    tls_key_file: /var/cyrus/tls/example_ca.key
    tls_cert_file: /var/cyrus/tls/example_ca.crt
    tls_session_timeout: 1440
    tlscache_db: skiplist
    
    # Authentication
    allowanonymouslogin: no
    allowplaintext: yes
    
    # cyrus-sasl configuration parameters 
    sasl_mech_list: plain login
    sasl_pwcheck_method: saslauthd

The cyrus user is created. The mail group already exists.

    adduser --system         --ingroup mail         --home /usr/local/cyrus         --no-create-home         --shell /bin/sh         cyrus

The default partition directory is created

    mkdir /var/cyrus/mail
    chown cyrus.mail /var/cyrus/mail
    chmod 750 /var/cyrus/mail

The sieve directory is created

    mkdir /var/cyrus/sieve
    chown cyrus.mail /var/cyrus/sieve
    chmod 750 /var/cyrus/sieve

The mkimap tool is used to create the remaining directories.

    su - cyrus
    ./tools/mkimap
    exit

Communication between postfix and cyrus-imapd is to occur via lmtp. Because postfix and cyrus-imapd run as different users a special group needs to be created to provide access to a shared lmtp socket.

    addgroup --system lmtppf
    adduser postfix lmtppf
    adduser cyrus lmtppf

A directory for the lmpt socket is created and the proper permissions set.

    mkdir -p /var/spool/postfix/socket
    chown -R cyrus.lmtppf /var/spool/postfix/socket
    chmod -R 750 /var/spool/postfix/socket

The cyrus user needs to belong to the sasl group in order to access the saslauthd socket located at `/var/run/saslauthd/mux`.

    adduser cyrus sasl

***

## Optional Mail Server Components Installation

Is spam and virus checking optional? I’d say not. But at this point we have a fully functional mail server. I strongly suggest testing all aspects of the mail server before proceeding!

The amavis-new package is what ties the various pieces of mail filtering software together. Because of this everything is installed under the amavisd user account.

### system account

Add a new user account and home directory with proper permissions.

    groupadd amavis
    useradd -g amavis -s /bin/false -d /var/lib/amavis amavis
    mkdir -p /var/lib/amavis/tmp
    mkdir -p /var/lib/amavis/var
    mkdir -p /var/lib/amavis/db
    chown -R amavis.amavis /var/lib/amavis
    chmod -R 750 /var/lib/amavis

### spamassassin

The spamassassin package was installed from sources. Packages are often dated which is not a good thing for spam (or virus) detection. The sources are available at http://apache.mirror.cygnal.ca/spamassassin/Mail-SpamAssassin-3.0.1.tar.gz.

The Mail::SpamAssassin modules are called directly via amavis. This means no spamassassin user account is needed.

A number of perl modules are required. These first modules few (Digest::SHA1, HTML::Parser, Storable) are installable via apt-get.

    apt-get install libdigest-sha1-perl
    apt-get install libhtml-parser-perl
    apt-get install libstorable-perl

The following modules are installed from sources.

[Digest::BubbleBabble](http://search.cpan.org/CPAN/authors/id/B/BT/BTROTT/Digest-BubbleBabble-0.01.tar.gz)
  
    tar xzf Digest-BubbleBabble-0.01.tar.gz
    cd Digest-BubbleBabble-0.01
    perl Makefile.PL && make && make test && make install
    cd ..

[Digest::MD5](http://search.cpan.org/CPAN/authors/id/G/GA/GAAS/Digest-MD5-2.33.tar.gz)

    tar xzf Digest-MD5-2.33.tar.gz
    cd Digest-MD5-2.33
    perl Makefile.PL && make && make test && make install
    cd ..

[Digest::HMAC](http://search.cpan.org/CPAN/authors/id/G/GA/GAAS/Digest-HMAC-1.01.tar.gz)

    tar xzf Digest-HMAC-1.01.tar.gz
    cd Digest-HMAC-1.01
    perl Makefile.PL && make && make test && make install
    cd ..

 [MIME::Base64](http://search.cpan.org/CPAN/authors/id/G/GA/GAAS/MIME-Base64-3.05.tar.gz)

    tar xzf MIME-Base64-3.05.tar.gz
    cd MIME-Base64-3.05
    perl Makefile.PL && make && make test && make install
    cd ..

[DB_File](http://search.cpan.org/CPAN/authors/id/P/PM/PMQS/DB_File-1.810.tar.gz)

    tar xzf DB_File-1.810.tar.gz
    cd DB_File-1.810
    perl Makefile.PL && make && make test && make install
    cd ..

[Net::DNS (>0.34)](http://search.cpan.org/CPAN/authors/id/C/CR/CREIN/Net-DNS-0.48.tar.gz)

    tar xzf Net-DNS-0.48.tar.gz
    cd Net-DNS-0.48
    perl Makefile.PL && make && make test && make install
    cd ..

[Net::SMTP](http://search.cpan.org/CPAN/authors/id/G/GB/GBARR/libnet-1.19.tar.gz)

    tar xzf libnet-1.19.tar.gz
    cd libnet-1.19
    perl Makefile.PL && make && make test && make install
    cd ..

[Net::CIDR::Lite](http://search.cpan.org/CPAN/authors/id/D/DO/DOUGW/Net-CIDR-Lite-0.15.tar.gz)

    tar xzf Net-CIDR-Lite-0.15.tar.gz
    cd Net-CIDR-Lite-0.15
    perl Makefile.PL && make && make test && make install
    cd ..

[Sys::Hostname::Long](http://search.cpan.org/CPAN/authors/id/S/SC/SCOTT/Sys-Hostname-Long-1.2.tar.gz)

    tar xzf Sys-Hostname-Long-1.2.tar.gz
    cd Sys-Hostname-Long-1.2
    perl Makefile.PL && make && make test && make install
    cd ..

[URI](http://search.cpan.org/CPAN/authors/id/G/GA/GAAS/URI-1.34.tar.gz)

    tar xzf URI-1.34.tar.gz
    cd URI-1.34
    perl Makefile.PL && make && make test && make install
    cd ..
    
[Mail::SPF::Query](http://search.cpan.org/CPAN/authors/id/F/FR/FREESIDE/Mail-SPF-Query-1.997.tar.gz)

    tar xzf Mail-SPF-Query-1.997.tar.gz
    cd Mail-SPF-Query-1.997
    perl Makefile.PL && make && make test && make install
    cd ..

[Geography::Countries](http://search.cpan.org/CPAN/authors/id/A/AB/ABIGAIL/Geography-Countries-1.4.tar.gz)
    
    tar xzf Geography-Countries-1.4.tar.gz
    cd Geography-Countries-1.4
    perl Makefile.PL && make && make test && make install
    cd ..
    
[IP::Country::Fast](http://search.cpan.org/CPAN/authors/id/N/NW/NWETTERS/IP-Country-2.18.tar.gz)

    tar xzf IP-Country-2.18.tar.gz
    cd IP-Country-2.18
    perl Makefile.PL && make && make test && make install
    cd ..

[Time::HiRes](http://search.cpan.org/CPAN/authors/id/J/JH/JHI/Time-HiRes-1.65.tar.gz)

    tar xzf Time-HiRes-1.65.tar.gz
    cd Time-HiRes-1.65
    perl Makefile.PL && make && make test && make install
    cd ..

[Net::Ping (required by razor)](http://search.cpan.org/CPAN/authors/id/B/BB/BBB/Net-Ping-2.31.tar.gz)

    tar xzf Net-Ping-2.31.tar.gz
    cd Net-Ping-2.31
    perl Makefile.PL && make && make test && make install
    cd ..

[Getopt::Long (required by razor)](http://search.cpan.org/CPAN/authors/id/J/JV/JV/Getopt-Long-2.34_02.tar.gz)

    tar xzf Getopt-Long-2.34_02.tar.gz
    cd Getopt-Long-2.34_02
    perl Makefile.PL && make && make test && make install
    cd ..
  
[Digest::Nilsimsa (required by razor)](http://search.cpan.org/CPAN/authors/id/V/VI/VIPUL/Digest-Nilsimsa-0.06.tar.gz)

    tar xzf Digest-Nilsimsa-0.06.tar.gz
    cd Digest-Nilsimsa-0.06
    perl Makefile.PL && make && make test && make install
    cd ..
    
Razor is an optional prerequisite for spamassassin and installed from source which can be found at http://unc.dl.sourceforge.net/sourceforge/razor/razor-agents-2.61.tar.gz.

    tar xzf razor-agents-2.61.tar.gz
    cd razor-agents-2.61
    perl Makefile.PL && make && make test && make install
    razor-client
    cd ..

DCC is another optional spamassassin prerequisite that was installed from source. Find the source at http://www.dcc-servers.net/dcc/source/dcc-dccproc.tar.Z.

    tar xfvz dcc-dccproc.tar.Z
    cd dcc-dccproc-*
    ./configure --homedir=/var/lib/amavis/dcc --disable-sys-inst         --disable-server --disable-dccm --disable-dccifd
    make && make install
    chown -R amavis /var/lib/amavis/dcc

Next call cdcc, the command should give some output, a number of servers.

    cdcc info

Finally we are ready to build and install spamassassin. Pay close attention to ‘make test’ to ensure all desired functions were built into spamassassin.

    tar xzf Mail-SpamAssassin-3.0.1.tar.gz
    cd Mail-SpamAssassin-3.0.1
    perl Makefile.PL && make 
    make test 
    make install

### amavis-new

It appears that amavis-new is the recommended glue to bring postfix, clamav and spamassassin together.

Just like spamassassin, amavis-new requires a bundle of perl modules. Here is the list of all the required modules and the installation.

[IO::Zlib](http://search.cpan.org/CPAN/authors/id/T/TO/TOMHUGHES/IO-Zlib-1.04.tar.gz)

    tar xzf IO-Zlib-1.04.tar.gz
    cd IO-Zlib-1.04
    perl Makefile.PL && make && make test && make install
    cd ..

[Archive::Tar](http://search.cpan.org/CPAN/authors/id/K/KA/KANE/Archive-Tar-1.10.tar.gz)

    tar xzf Archive-Tar-1.10.tar.gz
    cd Archive-Tar-1.10
    perl Makefile.PL && make && make test && make install
    cd ..

[Archive::Zip](http://search.cpan.org/CPAN/authors/id/N/NE/NEDKONZ/Archive-Zip-1.14.tar.gz)
    
    tar xzf Archive-Zip-1.14.tar.gz
    cd Archive-Zip-1.14
    perl Makefile.PL && make && make test && make install
    cd ..

[Compress::Zlib](http://search.cpan.org/CPAN/authors/id/P/PM/PMQS/Compress-Zlib-1.33.tar.gz)

    tar xzf Compress-Zlib-1.33.tar.gz
    cd Compress-Zlib-1.33
    perl Makefile.PL && make && make test && make install
    cd ..

[Convert::TNEF](http://search.cpan.org/CPAN/authors/id/D/DO/DOUGW/Convert-TNEF-0.17.tar.gz)

    tar xzf Convert-TNEF-0.17.tar.gz
    cd Convert-TNEF-0.17
    perl Makefile.PL && make && make test && make install
    cd ..

[Convert::UUlib](http://search.cpan.org/CPAN/authors/id/M/ML/MLEHMANN/Convert-UUlib-1.03.tar.gz)

    tar xzf Convert-UUlib-1.03.tar.gz
    cd Convert-UUlib-1.03
    perl Makefile.PL && make && make test && make install
    cd ..

MIME::Base64 (Already installed for spamassassin.)

[MIME::Parser](http://search.cpan.org/CPAN/authors/id/D/DS/DSKOLL/MIME-tools-5.414.tar.gz)
   
    tar xzf MIME-tools-5.414.tar.gz
    cd MIME-tools-5.414
    perl Makefile.PL && make && make test && make install
    cd ..

[Mail::Internet](http://search.cpan.org/CPAN/authors/id/M/MA/MARKOV/MailTools-1.64.tar.gz)

    tar xzf MailTools-1.64.tar.gz
    cd MailTools-1.64
    perl Makefile.PL && make && make test && make install
    cd ..

[Net::Server](http://search.cpan.org/CPAN/authors/id/B/BB/BBB/Net-Server-0.87.tar.gz)

    tar xzf Net-Server-0.87.tar.gz
    cd Net-Server-0.87
    perl Makefile.PL && make && make test && make install
    cd ..

Net::SMTP (Already installed for spamassassin.)

Digest::MD5 (Already installed for spamassassin.)

[IO::Stringy](http://search.cpan.org/CPAN/authors/id/E/ER/ERYQ/IO-stringy-2.109.tar.gz)

    tar xzf IO-stringy-2.109.tar.gz
    cd IO-stringy-2.109
    perl Makefile.PL && make && make test && make install
    cd ..

Time::HiRes (Already installed for spamassassin.)

[Unix::Syslog](http://search.cpan.org/CPAN/authors/id/M/MH/MHARNISCH/Unix-Syslog-0.100.tar.gz)

    tar xzf Unix-Syslog-0.100.tar.gz
    cd Unix-Syslog-0.100
    perl Makefile.PL && make && make test && make install
    cd ..

[Parse::RecDescent](http://search.cpan.org/CPAN/authors/id/D/DC/DCONWAY/Parse-RecDescent-1.94.tar.gz)

    tar xzf Parse-RecDescent-1.94.tar.gz
    cd Parse-RecDescent-1.94
    perl Makefile.PL && make && make test && make install
    cd ..

[Inline::C](http://search.cpan.org/CPAN/authors/id/I/IN/INGY/Inline-0.44.tar.gz)

    tar xzf Inline-0.44.tar.gz
    cd Inline-0.44
    perl Makefile.PL && make && make test && make install
    cd ..

[Mail::ClamAV](http://search.cpan.org/CPAN/authors/id/S/SA/SABECK/Mail-ClamAV-0.12.tar.gz)

    tar xzf Mail-ClamAV-0.12.tar.gz
    cd Mail-ClamAV-0.12
    perl Makefile.PL && make && make test && make install
    cd ..

[BerkeleyDB](http://search.cpan.org/CPAN/authors/id/P/PM/PMQS/BerkeleyDB-0.26.tar.gz)

    tar xzf BerkeleyDB-0.26.tar.gz
    cd BerkeleyDB-0.26
    perl Makefile.PL && make && make test && make install
    cd ..

[DBI](http://search.cpan.org/CPAN/authors/id/T/TI/TIMB/DBI-1.45.tar.gz)

    tar xzf DBI-1.45.tar.gz
    cd DBI-1.45
    perl Makefile.PL && make && make test && make install
    cd ..

[DBD::mysql](http://search.cpan.org/CPAN/authors/id/R/RU/RUDY/DBD-mysql-2.9005_1.tar.gz)

    tar xzf DBD-mysql-2.9005_1.tar.gz
    cd DBD-mysql-2.9005_1
    perl Makefile.PL && make && make test && make install
    cd ..

A number of useful archiving tools are installed from Debian packages to make virus scanning more effective.

    apt-get install arc
    apt-get install lzop
    apt-get install lha
    apt-get install unrar
    apt-get install cabextract

The amavis-new distribution is downloaded and unpacked.

    wget http://ftp.cfu.net/pub/amavisd-new/amavisd-new-2.1.2.tar.gz
    tar xzf amavisd-new-2.1.2.tar.gz
    cd amavisd-new-2.1.2

Install the daemon and the config file.

    cp amavisd /usr/local/sbin
    chmod 755 /usr/local/sbin/amavisd
    chown root.root /usr/local/sbin/amavisd

    cp amavisd.conf /etc/amavis/
    chmod 644 /etc/amavis/amavisd.conf
    chown root.root /etc/amavis/amavisd.conf

Create a quarantaine directory for undesirable email

    mkdir /var/spool/quarantine
    chmod 750 /var/spool/quarantine
    chown amavis.amavis /var/spool/quarantine

### clamav

I selected the OpenSource clamav virus scanner for this mail system. The sources can be downloded from SourceForge
http://mesh.dl.sourceforge.net/sourceforge/clamav/clamav-0.80.tar.gz.

Just like with spamassassin, the clamav daemon is part of the amavis system. It has to run as the amavisd user.

Some directories need to be created for clamav to properly operate.

    mkdir /var/lib/amavis/clamav
    mkdir /var/run/amavis
    chmod 755 /var/lib/amavis/clamav
    chown amavis.amavis /var/lib/amavis/clamav
    chmod 750 /var/run/amavis
    chown amavis.amavis /var/run/amavis

The clamav build process requires additional packages.

    apt-get install zlibc 
    apt-get install zlib1g
    apt-get install zlib1g-dev
    apt-get install curl
    apt-get install libcurl3-dev
    apt-get install libbz2-dev
    apt-get install libgmp3
    apt-get install libgmp3-dev

The clamav package is build.

    tar xzf clamav-0.80.tar.gz
    cd clamav-0.80
    ./configure --with-user=amavis --with-group=amavis         --sysconfdir=/etc/amavis --with-dbdir=/var/lib/amavis/clamav
    make
    make install

The successful built of the package can be confirmed by running clamscan in the clamav-0.80 directory. The scan.txt file should be examined for errors.

    clamscan -r -l scan.txt .

### dspam

amavis-new supports dspam.

    wget http://www.nuclearelephant.com/projects/dspam/sources/dspam-3.2.0.tar.gz
    tar xzf dspam-3.2.0.tar.gz
    cd dspam-3.2.0
    ./configure --with-dspam-home=/var/lib/amavis/dspam         --without-delivery-agent        --without-quarantine-agent      --with-storage-driver=libdb4_drv        --sysconfdir=/etc/amavis        --with-dspam-home-owner=amavis      --with-dspam-home-group=amavis       --with-dspam-mode=755
    make
    make install
    chmod 755 /usr/local/bin/dspam*
    chmod 644 /etc/amavis/dspam.conf
    chown amavis.amavis /var/lib/amavis/dspam

***

## Optional Mail Server Components Configuration

Now we are ready to configure each piece of software. Followed by some changes to postfix to loop all mail through the mail filtering chain.

### amavis-new

We will be configuring amavis to log to it’s own log file via the syslog local7 facility. This requires that the following lines are added just below the cyrus-imap lines

    #
    # Logging for the amavis spam checker
    #
    local7.*                        -/var/log/amavisd.log

The log file needs to be created followed by a restart of the system logger.

    touch /var/log/amavisd.log
    chmod 640 /var/log/amavisd.log
    chown root.adm /var/log/amavisd.log

    /etc/init.d/sysklogd restart

The configuration file for amavisd is `/etc/amavis/amavid.conf`. Note that the lines below need to be edited in the file. Only changes are shown not the complete file.

    $max_servers = 4;
    $daemon_user  = 'amavis';
    $daemon_group = 'amavis';
    $mydomain = 'example.com';
    $MYHOME   = '/var/lib/amavis'
    $QUARANTINEDIR = '/var/spool/quarantine';
    $db_home   = "$MYHOME/db";
    $helpers_home = "$MYHOME/var";
    $pid_file  = "/var/run/amavis/amavisd.pid";
    $lock_file = "/var/run/amavis/amavisd.lock";
    @local_domains_maps = ();
    $SYSLOG_LEVEL = 'local7.debug';
    $inet_socket_port = 10024;
    $sa_spam_report_header = 1;
    $sa_tag_level_deflt  = -999;  # add spam info headers if at, or above level
    $sa_tag2_level_deflt = 6.31;  # add 'spam detected' headers at that level
    $sa_kill_level_deflt = 15;    # triggers spam evasive actions
    $sa_dsn_cutoff_level = -999;  # spam level beyond which a DSN is not sent
    
    @lookup_sql_dsn =
      ( ['DBI:mysql:database=postfix;host=127.0.0.1;port=3306',
         'amavis','<passwdord>']);
    $sql_select_policy = 'SELECT NULL as id, NULL as spam_tag_level,' .
         ' NULL as spam_tag2_level, NULL as spam_kill_level FROM alias' .
         ' WHERE (active=1) AND (address IN (%k))';
    @addr_extension_spam_maps       = ('junkmail');

    $virus_admin               = "";
    
    $final_virus_destiny      = D_DISCARD;
    $final_banned_destiny     = D_DISCARD;
    $final_spam_destiny       = D_DISCARD;
    $final_bad_header_destiny = D_PASS;

In addition to the above changes all virus scanners need to be commented. We will be using clamav, so the following sections are uncommented.

     ### http://www.clamav.net/
     ['ClamAV-clamd',
       &ask_daemon, ["CONTSCAN {}n", "/var/run/amavis/clamd"],
       qr/bOK$/, qr/bFOUND$/,
       qr/^.*?: (?!Infected Archive)(.*) FOUND$/ ],
     # NOTE: run clamd under the same user as amavisd;  match the socket
     # name (LocalSocket) in clamav.conf to the socket name in this entry
     # When running chrooted one may prefer: ["CONTSCAN {}n","$MYHOME/clamd"],

We also uncomment the following section for a backup scanner in case the daemon dies.

     ### http://www.clamav.net/   - backs up clamd or Mail::ClamAV
     ['ClamAV-clamscan', 'clamscan',
       "--stdout --disable-summary -r --tempdir=$TEMPBASE {}", [0], [1],
       qr/^.*?: (?!Infected Archive)(.*) FOUND$/ ],

The [amavisd]({{ site.baseurl }}/{{ page.assets }}/amavisd.txt) script is installed in `/etc/init.d/amavisd`. The sysv-rc-conf tool is used to run the daemon at the appropriate runlevels.

Finally a user is added to mysql so amavisd can lookup the recipient address in the alias table to determine if the recipient is local.

    mysql -u root [-p] < DATABASE.TXT
    mysql> USE mysql;
    mysql> INSERT INTO user (Host, User, Password) 
        ->    VALUES ('localhost','amavis',password('<password>'));
    mysql> INSERT INTO user (Host, User, Password) 
        ->    VALUES ('127.0.0.1','amavis',password('<password>'));
    mysql> INSERT INTO db (Host, Db, User, Select_priv) 
        ->    VALUES ('localhost','postfix','amavis','Y');
    mysql> INSERT INTO db (Host, Db, User, Select_priv) 
        ->    VALUES ('127.0.0.1','postfix','amavis','Y');
    mysql> FLUSH PRIVILEGES;

Amavis stores D_DISCARD messages in `/var/spool/quarantine`. Install this script as `/etc/cron.daily/amavis` to delete quarantined messages that exceed a certain age.
    
    #!/bin/sh
    #
    # Delete quarantained emails periodically.
    #/bin/rm -f `/usr/bin/find /var/spool/quarantine -atime +4`
    for file in `/usr/bin/find /var/spool/quarantine -atime +4`; do
        rm -f $file
    done

### spamassassin

The spamassassin configuration file is `/etc/mail/spamassassin/local.cf`. Because the spamassassin perl module is called directly by amavis there are a number of parameters that have no effect. Amongst them options to modify header or body or rewrite messages. These items have to be configured in amavis. Create a system-wide account for amavis/spamassassin to access razor.

    razor-admin -home=/var/lib/amavis/razor -create
    razor-admin -home=/var/lib/amavis/razor -discover
    razor-admin -home=/var/lib/amavis/razor -register
    chown -R amavis.amavis /var/lib/amavis/razor

Tell razor where it lives by adding to `/var/lib/amavis/razor/razor-agent.conf`

    razorhome              = /var/lib/amavis/razor

The working directory for spamassassin is `/var/lib/amavisd/spamassassin`. Edit `/etc/mail/spamassassin/local.cf` to reflect this:

    #
    # Configure bayes
    #
    bayes_path /var/lib/amavis/spamassassin/bayes
    auto_whitelist_path /var/lib/amavis/spamassassin/auto-whitelist 
    bayes_file_mode 777
    auto_whitelist_file_mode 777
    use_bayes 1
    auto_learn 1
    bayes_ignore_header ReSent-Date
    bayes_ignore_header ReSent-From
    bayes_ignore_header ReSent-Message-ID
    bayes_ignore_header ReSent-Subject
    bayes_ignore_header ReSent-To
    bayes_ignore_header Resent-Date
    bayes_ignore_header Resent-From
    bayes_ignore_header Resent-Message-ID
    bayes_ignore_header Resent-Subject
    bayes_ignore_header Resent-To

    #
    # Configure razor
    #
    use_razor2 1
    razor_config /var/lib/amavis/razor/razor-agent.conf

### clamav

The clamd configuration file is `/etc/amavis/clamd.conf`. The following configuration parameters were changed from default.

    #Example
    LogFile /var/log/clamav/clamd.log
    LogFileMaxSize 0
    LogTime
    PidFile /var/run/amavis/clamd.pid
    TemporaryDirectory /tmp
    LocalSocket /var/run/amavis/clamd
    FixStaleSocket
    User amavis
    ScanMail
    ScanArchive

The freshclam configuration file is `/etc/freshclam.conf`. The following configuration parameters were changed from defaults.

    #Example
    UpdateLogFile /var/log/clamav/freshclam.log
    PidFile /var/run/amavis/freshclam.pid
    DatabaseOwner amavis
    DatabaseMirror db.ca.clamav.net
    Checks 10
    NotifyClamd

The [clamav-freshclam]({{ site.baseurl }}/{{ page.assets }}/clamav-freshclam.txt) and [clamav-freshclam]({{ site.baseurl }}/{{ page.assets }}/clamav-freshclam.txt) scripts need to be installed as `/etc/init.d/clamav-clamd` and `/etc/init.d/clamav-freshclam`. The sysv-rc-conf tool is used to set the runlevels appropriately.

The `/etc/logrotate.d/clamav` needs to be create. This makes sure the clamav logs will get rotated on a regular basis.

    #
    # Rotate Clam AV daemon log file
    #
    
    /var/log/clamav/clamd.log {
        missingok
        nocompress
        create 640 amavis amavis
        postrotate
            /bin/kill -HUP `cat /var/run/clamav/clamd.pid 2> /dev/null` 2> /dev/null || true
        endscript
    }
    
    /var/log/clamav/freshclam.log {
        missingok
        nocompress
        create 640 amavis amavis
        postrotate
            /bin/kill -HUP `cat /var/run/clamav/freshclam.pid 2> /dev/null` 2> /dev/null || true
        endscript
    }

The log directory and log files need to be created.

    mkdir /var/log/clamav
    chmod 755 /var/log/clamav
    chown amavis.amavis /var/log/clamav
    touch /var/log/clamav/clamd.log
    chmod 640 /var/log/clamav/clamd.log
    chown amavis.amavis /var/log/clamav/clamd.log
    touch /var/log/clamav/freshclam.log
    chmod 640 /var/log/clamav/freshclam.log
    chown amavis.amavis /var/log/clamav/freshclam.log

### dcc

Nothing should be needed to get dcc to work with `amavis/spamassassin`. However some log messages in `/var/log/mail.log` indicated trouble:

    Oct 25 01:04:19 yoda dccproc[9967]: missing message body; fatal error

Some googling found the answer. At aboult line 796 in `/usr/local/share/perl/5.8.4/Mail/SpamAssassin/Dns.pm`, uncomment one line and comment out two others. The result should look like:

    my $pid = open(DCC, join(' ', $path, "-H", $opts, "< '$tmpf'", "2>&1", '|'))
        || die "$!n";
    # my $pid = Mail::SpamAssassin::Util::helper_app_pipe_open(*DCC,
    #            $tmpf, 1, $path, "-H", split(' ', $opts));
    $pid or die "$!n";

### dspam

The dspam_clean tool needs to run on a nightly basis to purge old, unecessary data from the dspam database. The following content should be placed in `/etc/cron.daily/amavis-dspam`:

    #!/bin/sh
    #
    # Purge dspam databases
    /usr/local/bin/dspam_clean -u30,15,10,10 -p30 amavis

The `/etc/amavis/dspam` file needs to be modified. All 'TrustedDeliveryAgent' need to be commented, 'QuarantineAgent' needs to be commented and all except for 'Preference "spamAction=tag"' are commented. All logging is turned off.  The remaining defaults are reasonable.

This is added to `/etc/mail/spamassassin/local.cf` so spamassassin evaluates dspam responses:

    #
    # Configure scoring of dspam headers
    #
    header DSPAM_SPAM X-DSPAM-Result =~ /^Spam$/
    describe DSPAM_SPAM DSPAM claims it is spam
    score DSPAM_SPAM 0.5
           
    header DSPAM_HAM X-DSPAM-Result =~ /^Innocent$/
    describe DSPAM_HAM DSPAM claims it is ham
    score DSPAM_HAM -0.1

Setting `'$dspam  = '';'` in `/etc/amavis/amavisd.conf` will disable dspam functionality in amavis-new.

### postfix

The following line in `/etc/postfix/main.cf` routes mail through amavis. If mail is supposed to bypass amavis simply comment this line:

    # Pass all mail through amavis
    content_filter = smtp-amavis:127.0.0.1:10024

### cyrus-imap

Since spam is deliverd to the junkmail foder, we need to purge messages on a regular basis. The ipurge is run daily to delete all messages delivered to the junkmail foder more than 2 days ago. Add this to `/etc/cyrus.imapd`

    # purge message delvered 2 or more days ago
    purgejunkmail cmd="ipurge -d2 -X -f *.junkmail" at=0230

Caution: The command above is recursive. It will find and process all folders
named junkmail on the server!

***

## Tweaking

### squirrelmail

Squirrelmail supports additional features via plugins. From the squirrelmail website download quota_usage-1.2.tar.gz and msg_flags-1.4.3.1-1.4.3.tar.gz. Intall thes plugins by extractimng them into the `html/plugins` directory. Follow the installation instractions for each to configure.

### sysklogd

The Debian syslog is configured to log virtually everything to `/var/log/syslog` in addition to more specific logs. This line will exclude mail system messages from `/var/log/syslog`

    *.*;auth,authpriv,mail,local6,local7.none             -/var/log/syslog

Do we really need three (3) mail logs? The mail.info line was commented.

## Note, Todo

- Daemon watch to make sure our daemons don’t die without anyone noticing!!!

