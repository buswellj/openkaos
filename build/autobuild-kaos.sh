#!/bin/bash
#
# Open Kernel Attached Operating System (OpenKaOS)
# Platform Build System version 5.0.0
#
# Copyright (c) 2009-2016 Opaque Systems, LLC
#
# script : autobuild-kaos.sh
# purpose: this script builds a new workspace, fetches code and then builds kaos
#

APBNOW=`date +%s`
export APBNOW

APBLOG=~/openkaos/autobuild/logs/$APBNOW
export APBLOG

echo ""
echo "Open Kernel Attached Operating System (OpenKaOS)"
echo "Platform Build System version 5.0.0"
echo ""
echo "Copyright (c) 2009-2016 Opaque Systems, LLC"
echo ""
echo "Automated Build in progress..."
echo ""
echo " => Creating logging area...."
mkdir -p $APBLOG
echo ""
echo " => Creating workspace...."
echo ""
./wsbld.sh 1>>$APBLOG/wsbld.log 2>>$APBLOG/wsbld.err
echo ""
echo " => Fetching Open Source code...."
echo ""
./fetch-opensrc.sh 1>>$APBLOG/fetchsrc.log 2>>$APBLOG/fetchsrc.err

ABOKSRC=`cat ~/openkaos/.latest-src`
export ABOKSRC

echo " => Verifying Open Source code...."
./verify-opensrc.sh $ABOKSRC 1>>$APBLOG/verifysrc.log 2>>$APBLOG/verifysrc.err

echo " => Checking for missing source...."

./verify-opensrc.sh $ABOKSRC | grep missing
./verify-opensrc.sh $ABOKSRC | grep missing 1>>$APBLOG/missingsrc.log 2>>$APBLOG/missingsrc.err

echo " => Waiting 30 seconds...."

sleep 30s

echo " => Building OpenKaOS... this will take awhile..."
./bld-kaos.sh $ABOKSRC 1>>$APBLOG/bld-kaos.log 2>>$APBLOG/bld-kaos.err

echo "Build complete..."
tail $APBLOG/bld-kaos.log -n 80
