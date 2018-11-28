#!/bin/sh
# Install SC-IM 

# Dependencies
apt-get install bison libncurses5-dev libncursesw5-dev libxml2-dev libzip-dev

cd /tmp
git clone https://github.com/jmcnamara/libxlsxwriter.git
cd libxlsxwriter/
make
checkinstall

# reload dynamic linked lib cache
ldconfig

cd /tmp
git clone https://github.com/andmarti1424/sc-im.git
cd sc-im/src
make
checkinstall
