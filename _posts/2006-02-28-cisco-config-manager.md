---
layout: post
title: Cisco Configuration Manager
date: 2006-02-27 20:30:13
comments: Yes
tags:
  - cisco
  - php
  - programming

redirect_from:
  - /article/cisco-config-manager/
category:
  - Coding
  - Sysadmin
assets: resources/2006-02-28-cisco-config-manager
---

This project provides tools to manage configurations for Cisco devices. At the heart of the project is a tftp daemon written entirely in PHP. Configurations are read and written to the tftp server using a file path that incorporates a password feature for security. The current version of each device configuration is stored in a mysql database. Subsequent changes to the configurations are stored in diff format to provide revision history. A web frontend is provided to manage devices and view configurations and history.

The docs/README.txt file is essential reading. It outlines the system requirements including required PHP5 compile options and PECL extensions.

This project was conceived to address some specific needs at [K-Net](http://www.knet.ca/) where it is used on a daily basis. Be warned, the documentation and installation instructions are very sparse.

The project is hosted on [GitHub](http://github.com/adilinden/cisco-config-manager/).

Install by cloning the git repo

    git clone https://github.com/adilinden/cisco-config-manager.git

Install by downloading the latest tarball at [cisco-config-manager tarball](https://github.com/adilinden/cisco-config-manager/archive/master.tar.gz)
