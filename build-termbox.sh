#!/bin/bash

cd "$( dirname "${BASH_SOURCE[0]}" )"
cd termbox
./waf configure --prefix=/usr
./waf
cd ..
