#!/bin/bash
#
# Open Kernel Attached Operating System (OpenKaOS)
# Platform Build System version 4.0.0
#
# Copyright (c) 2009-2015 Opaque Systems, LLC 
#
# script : pkg-sdk.sh
# purpose: package the SDK environment for distribution
#

echo ""
echo "Open Kernel Attached Operating System (OpenKaOS)"
echo "Copyright (c) 2009-2015 Opaque Systems, LLC"
echo ""
echo "Source Build Environment: $1"
echo ""

echo "  [.] Preparing packaging environment"

if [ ! -e ~/openkaos/pkg/sdk/ ]; then
    echo "  [.] Creating OpenKaOS SDK packaging directory... "
    mkdir -p ~/openkaos/pkg/sdk/
fi

echo "  [.] Loading environment "

if [ ! -e ~/openkaos/.current ]; then
    echo "  [#] FATAL - no valid build environment. Run wsbld.sh first.."
    echo ""
    exit
fi

PBCUR=`cat ~/openkaos/.current`
PBPWD=`pwd`
PBNOW=`date +%s`
export PBCUR PBPWD PBNOW

PBENV="/home/$USER/openkaos/$PBCUR/$1"
export PBENV

if [ ! -e $PBENV/.env ]; then
    echo "  [#] FATAL - missing environment information. Do a build first.."
    exit
fi

source $PBENV/.env
LFS="$PBWS/$PBTAG/$1/bld/"
export LFS

echo "      Env is $PBENV"
echo "      Build is $LFS"
echo ""

if [ ! -e $LFS/bin/bash ]; then
    echo "  [#] FATAL - no valid build found in $LFS "
    exit
fi

echo "  [.] Found SDK - $LFS"

PBPKGSDK="/home/$USER/openkaos/pkg/sdk/$PBNOW"
export PBPKGSDK

echo "  [.] Packaging SDK in $PBPKGSDK"

mkdir -p $PBPKGSDK/sdk/

echo "  [.] Installing $LFS in package"
sudo cp -a $LFS/* $PBPKGSDK/sdk/
cd $PBPKGSDK
sudo cp $PBPWD/openkaos-sdk.sh .
sudo chown 0:0 ./openkaos-sdk.sh
sudo tar cfJvlp sdk-$PBNOW.tar.xz sdk/ openkaos-sdk.sh

echo "  [.] Package sdk-$PBNOW.tar.xz is complete"
echo "  [.] Cleaning up"
echo ""
sudo rm -rf sdk/ openkaos-sdk.sh

cd $PBPWD

echo "  [.] Packaging complete"
echo ""

