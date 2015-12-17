#!/bin/bash

# Install C version of nsf/termbox

# Clone termbox-c
git clone https://github.com/nsf/termbox lib-termbox

# cd to it
cd "ext/nsf/termbox"

# Configure and build
./waf configure --prefix=/usr/local
./waf

# Install (in /usr/local/lib)
sudo ./waf install --destdir=/
