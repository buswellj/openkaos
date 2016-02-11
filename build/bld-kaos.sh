#!/bin/bash
#
# Open Kernel Attached Operating System (OpenKaOS)
# Platform Build System version 5.0.0
#
# Copyright (c) 2009-2016 Opaque Systems, LLC 
#
# script : bld-kaos.sh
# purpose: builds the KaOS platform from scratch
#

PPWD=`pwd`
cd ~
PBHOME=`pwd`
cd $PPWD
PBVER="5.0.0"
PBUSER=`whoami`
PBNOW=`date +%s`
PBWS="$PBHOME/openkaos"
PBTAG=`cat $PBWS/.current`

export PPWD PBHOME PBVER PBUSER PBNOW PBWS PBTAG

echo ""
echo "OpenKaOS Platform Build System, version $PBVER"
echo "Copyright (c) 2009-2016 Opaque Systems, LLC"
echo ""
echo "http://www.opaquesystems.com"
echo ""

if [ -z "$1" ]
then
 echo "Error: Missing command line parameters"
 echo ""
 echo "Usage:"
 echo ""
 echo "./bld-kaos.sh <opensrc-src-id> [clean]"
 echo ""
 echo "opensrc-src-id == The output from the fetch-opensrc script"
 echo "clean == always build toolchain even if it exists"
 echo ""
 exit
fi

echo "  [.] Testing Architecture "
KARCH=`uname -m | grep x86_64`
export KARCH

if [ ! "$KARCH" ]
 then
  echo ""
  echo "### ERROR ###"
  echo ""
  echo " This platform requires an x86-64 system!"
  echo ""
  exit
fi

PBSRC="$PBWS/$PBTAG/pkg/$1"
PBBLD="$PBWS/$PBTAG/bld-$PBNOW"
PBLOG="$PBWS/$PBTAG/log-$PBNOW"
PBSTATS="$PBWS/$PBTAG/stats-$PBNOW"
export PBSRC PBBLD PBLOG PBSTATS

if [ -e $PBWS/.toolchain ]; then
 PBSKIPTOOLS=1
 PBTOOLCHAIN=`cat $PBWS/.toolchain`
 export PBSKIPTOOLS PBTOOLCHAIN
fi

echo "  [-] Starting Build ID# $PBNOW"
echo "  [.] Creating Build and Log directories..."
mkdir -p $PBBLD $PBLOG

echo "  [.] Creating build stats file..."
echo "creating stats..." > $PBSTATS
date >> $PBSTATS
date +%s >> $PBSTATS
echo "" >> $PBSTATS

echo "  [-] Environment Information: "
echo ""
echo "        User is $PBUSER ($PBHOME)"
echo "        Building $PBTAG in $PBBLD"
echo "        Source is $PBSRC"
echo "        Logs stored in $PBLOG"
echo ""

if [ -n "$2" ]
then
 echo "  [*] Performing Clean Build $2"
 unset PBSKIPTOOLS
 unset PBTOOLCHAIN
fi

echo "PBUSER=$PBUSER" > $PBBLD/.env
echo "PBHOME=$PBHOME" >> $PBBLD/.env
echo "PBWS=$PBWS" >> $PBBLD/.env
echo "PBTAG=$PBTAG" >> $PBBLD/.env
echo "PBSRC=$PBSRC" >> $PBBLD/.env
echo "PBBLD=$PBBLD" >> $PBBLD/.env
echo "PBLOG=$PBLOG" >> $PBBLD/.env
echo "export PBUSER PBHOME PBWS PBTAG PBSRC PBBLD PBLOG" >> $PBBLD/.env
echo "        Environment saved to $PBBLD/.env"
echo ""

if [ -n "$PBSKIPTOOLS" ]; then
 echo "toolchain skipped using $PBTOOLCHAIN: " >> $PBSTATS
 date >> $PBSTATS
 date +%s >> $PBSTATS
 echo "" >> $PBSTATS
 echo "  [*] Using toolchain: $PBTOOLCHAIN"
 LFS="$PBBLD/bld"
 TOOLS="/tools.$PBUSER"
 export LFS TOOLS
 echo "        Build is $LFS"
 echo "        Tools is $TOOLS"
 echo ""
 cd $PPWD
 sudo mkdir -p $LFS/tools.$PBUSER
 sudo rm -rf $TOOLS
 sudo ln -sv $LFS/tools.$PBUSER $TOOLS
 sudo chown -v $PBUSER $LFS/tools.$PBUSER
 sudo cp -a $PBTOOLCHAIN/tools.$PBUSER/* $TOOLS
 echo "  [.] Setting toolchain environment"
 set +h
 umask 022
 LC_ALL=POSIX
 LFS_TGT=$(uname -m)-kaos-linux-gnu
 PATH=/tools.$PBUSER/bin:/bin:/usr/bin:$PATH
 export LC_ALL LFS_TGT PATH
 sudo chown -R root:root $LFS/tools.$PBUSER
 echo "toolchain skipped end: " >> $PBSTATS
 date >> $PBSTATS
 date +%s >> $PBSTATS
 echo "" >> $PBSTATS
else
 echo "toolchain start: " >> $PBSTATS
 date >> $PBSTATS
 date +%s >> $PBSTATS
 echo "" >> $PBSTATS

 echo "  [*] Building toolchain..."
 echo ""
 LFS="$PBBLD/bld"
 TOOLS="/tools.$PBUSER"
 export LFS TOOLS
 echo "        Build is $LFS"
 echo "        Tools is $TOOLS"
 echo ""

 cd $PPWD
 sudo mkdir -p $LFS/tools.$PBUSER
 sudo rm -rf $TOOLS
 sudo ln -sv $LFS/tools.$PBUSER $TOOLS
 sudo chown -v $PBUSER $LFS/tools.$PBUSER

 source bld-toolchain.sh

 echo "toolchain end: " >> $PBSTATS
 date >> $PBSTATS
 date +%s >> $PBSTATS
 echo "" >> $PBSTATS
fi

unset PBSKIPTOOLS
unset PBTOOLCHAIN

echo "  [*] Preparing SDK Environment..."
echo ""
cd $PPWD

source bld-prepsdk.sh

echo "  [*] Building KaOS SDK..."
echo ""
cd $PPWD

echo "SDK phase 1 start: " >> $PBSTATS
date >> $PBSTATS
date +%s >> $PBSTATS
echo "" >> $PBSTATS

echo "  [.] SDK phase 1"
sudo chroot "$LFS" $TOOLS/bin/env -i \
    HOME=/root TERM="$TERM" PS1='\u:\w\$ ' \
    PATH=/bin:/usr/bin:/sbin:/usr/sbin:$TOOLS/bin \
    $TOOLS/bin/bash -c /src/bld-sdk.sh

echo "SDK phase 2 start: " >> $PBSTATS
date >> $PBSTATS
date +%s >> $PBSTATS
echo "" >> $PBSTATS

echo "  [.] SDK phase 2"
sudo chroot "$LFS" $TOOLS/bin/env -i \
    HOME=/root TERM="$TERM" PS1='\u:\w\$ ' \
    PATH=/bin:/usr/bin:/sbin:/usr/sbin:$TOOLS/bin \
    /bin/bash -c /src/bld-sdk2.sh

echo "SDK phase 3 start: " >> $PBSTATS
date >> $PBSTATS
date +%s >> $PBSTATS
echo "" >> $PBSTATS

echo "  [.] SDK phase 3"
sudo chroot "$LFS" $TOOLS/bin/env -i \
    HOME=/root TERM=$TERM PS1='\u:\w\$ ' \
    PATH=/bin:/usr/bin:/sbin:/usr/sbin \
    $TOOLS/bin/bash -c /src/bld-sdk3.sh

echo "  [.] SDK core build"
sudo chroot "$LFS" $TOOLS/bin/env -i \
    HOME=/root TERM=$TERM PS1='\u:\w\$ ' \
    PATH=/bin:/usr/bin:/sbin:/usr/sbin \
    /bin/bash -c /src/bld-core.sh

echo "Build Cleanup: " >> $PBSTATS
date >> $PBSTATS
date +%s >> $PBSTATS
echo "" >> $PBSTATS

echo "  [.] Cleaning SDK environment"
sudo mv $LFS$TOOLS $LFS/..
sudo umount $LFS/dev/pts $LFS/dev/shm $LFS/dev $LFS/proc $LFS/sys $LFS/run
sudo mv $LFS/src $LFS/../src2
sudo mv $LFS/.tools $LFS/..
sudo rm -rf $LFS/tmp/*
sudo rm $LFS/usr/lib/lib{bfd,opcodes}.a
sudo rm $LFS/usr/lib/libbz2.a
sudo rm $LFS/usr/lib/lib{com_err,e2p,ext2fs,ss}.a
sudo rm $LFS/usr/lib/libltdl.a
sudo rm $LFS/usr/lib/libz.a

echo "Build complete: " >> $PBSTATS
date >> $PBSTATS
date +%s >> $PBSTATS
echo "" >> $PBSTATS

echo "  [*] Build complete. "
echo "  [-] Build Information: "
echo ""
echo "        Build ID is $PBNOW"
echo "        User is $PBUSER ($PBHOME)"
echo "        Building $PBTAG in $PBBLD"
echo "        Source is $PBSRC"
echo "        Logs stored in $PBLOG"
echo ""
echo "        Run chroot-fcs.sh bld-$PBNOW to enter chroot environment"
echo ""

