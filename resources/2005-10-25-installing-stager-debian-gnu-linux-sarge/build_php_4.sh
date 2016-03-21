#!/bin/bash -x

PHPVER=4.4.0
[ -d php-${PHPVER} ] && rm -rf php-${PHPVER}

bunzip2 -c php-${PHPVER}.tar.bz2 | tar x
cd php-${PHPVER}

./configure \
        --with-apxs \
        --enable-pic \
        --enable-shared \
        --enable-calendar \
        --enable-cli \
        --enable-force-cgi-redirect \
        --enable-ftp \
        --enable-magic-quotes \
        --enable-memory-limit \
        --enable-safe-mode \
        --enable-sockets \
        --enable-trans-sid \
        --enable-track-vars \
        --with-gettext \
        --with-gd \
          --with-jpeg-dir \
          --with-png-dir \
          --with-zlib-dir \
          --enable-gd-native-ttf \
        --with-iconv \
        --with-pgsql \
        --with-pear \
        --with-regex=system \
        --with-zlib

make && \
make  install-pear && \
make install-cli && \
make install-programs && \
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

