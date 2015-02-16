#!/bin/bash
#
# Open Kernel Attached Operating System (OpenKaOS)
# Platform Build System version 4.0.0
#
# Copyright (c) 2009-2015 Opaque Systems, LLC 
#
# script : pkg-toolchain.sh
# purpose: package the toolchain to improve build performance
#

echo ""
echo "Open Kernel Attached Operating System (OpenKaOS)"
echo "Copyright (c) 2009-2015 Opaque Systems, LLC"
echo ""
echo "Source Build Environment: $1"
echo ""

echo "  [.] Preparing packaging environment"

if [ ! -e ~/openkaos/pkg/toolchains ]; then
    echo "  [.] Creating OpenKaOS toolchain packaging directory... "
    mkdir -p ~/openkaos/pkg/toolchains/
fi

echo "  [.] Loading environment "

if [ ! -e ~/openkaos/.current ]; then
    echo "  [#] FATAL - no valid build environment. Run wsbld.sh first.."
    echo ""
    exit
fi

PBCUR=`cat ~/openkaos/.current`
export PBCUR

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

if [ ! -e $PBENV/tools.$USER ]; then
    echo "  [#] FATAL - no toolchain found in $PBENV/tools.$USER. "
    exit
fi

echo "  [.] Found toolchain - $PBENV/tools.$USER"

PBPKGTC="/home/$USER/openkaos/pkg/toolchains/$1"
export PBPKGTC

echo "  [.] Packaging toolchain in $PBPKGTC"

echo $PBPKGTC > ~/openkaos/.toolchain
mkdir -p $PBPKGTC

sudo cp -a $PBENV/tools.$USER $PBPKGTC

echo "  [.] Packaging complete"


