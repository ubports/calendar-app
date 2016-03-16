#!/bin/sh

export LC_ALL=C

BZR_SOURCE=${1:-lp:ubuntu-calendar-app}

CLICKARCH=armhf
rm -rf $CLICKARCH-build
mkdir $CLICKARCH-build
cd $CLICKARCH-build
cmake .. -DCLICK_MODE=on \
        -DBZR_REVNO=$(cd ..; bzr revno) \
        -DBZR_SOURCE="$BZR_SOURCE"
make DESTDIR=../package install
cd ..
click build package
