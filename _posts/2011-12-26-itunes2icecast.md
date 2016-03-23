---
layout: post
title: iTunes To Icecast
date: 2011-12-25 23:01:29
comments: Yes
tags:
  - php
  - programming

redirect_from:
  - /article/itunes2icecast/
category:
  - Coding
assets: resources/2011-12-26-itunes2icecast
---

Some time ago I wrote some PHP scripts to feed an iTunes library to an Icecast server. The project provides a framework and web based GUI to stream an iTunes library to an Icecast server.

The itunes2db.php script parses the XML version of the iTunes library and dumps songs and playlists into a MySQL database. The web based then allows for browsing of the songs and creation of playlists. A special queue is used to hold the songs in the order they are to be streamed. Ezstream is used to source the media file to the icecast server. The
icecast server can be local on the same machine or remote.

Note that I created this before Airtunes became available. It was a convenient method to distribute music throughout the house. With Airtunes distribution of music on the same LAN has become trivial. However, there is still use for feeding an iTunes library into Icecast
for distribution extending beyond the local LAN.

The docs/streaming.txt file is essential reading. It outlines the system requirements including required PHP5 compile options and PECL extensions. As well as any additional packages and binaries needed. The documentation is really sparse. If there is larger interest in this project I could make use of the Github Wiki to provide proper installation instructions.

This work is released under the [GNU General Public License](http://www.gnu.org/licenses/old-licenses/gpl-2.0.html), please consult COPYING.txt or [http://www.gnu.org/licenses/old-licenses/gpl-2.0.html](http://www.gnu.org/licenses/old-licenses/gpl-2.0.html).

I now placed the sources on [Github](https://github.com/adilinden/itunes2icecast).
