#!/bin/bash
#
# Open Kernel Attached Operating System (OpenKaOS)
# Platform Build System version 4.0.0
#
# Copyright (c) 2009-2015 Opaque Systems, LLC 
#
# script : openkaos-sdk.sh
# purpose: production script to invoke chroot on SDK
#

echo ""
echo "Open Kernel Attached Operating System (OpenKaOS)"
echo "Copyright (c) 2009-2015 Opaque Systems, LLC"
echo ""

OKVERSION="4.0.0"
OKPWD=`pwd`
export OKPWD OKVERSION

OKSDK="$OKPWD/sdk/"
export OKSDK

echo "SDK version $OKVERSION"
echo ""

echo " [.] Mounting Virtual File Systems"
sudo mount -v --bind /dev $OKSDK/dev
sudo mount -vt devpts devpts $OKSDK/dev/pts
sudo mount -vt tmpfs shm $OKSDK/dev/shm
sudo mount -vt proc proc $OKSDK/proc
sudo mount -vt sysfs sysfs $OKSDK/sys
echo ""
echo " [.] Entering SDK"

sudo chroot "$OKSDK" /usr/bin/env -i \
    HOME=/root TERM="$TERM" PS1='\u:\w\$ ' \
    PATH=/bin:/usr/bin:/sbin:/usr/sbin \
    /bin/bash --login +h

sudo umount $OKSDK/dev/pts $OKSDK/dev/shm $OKSDK/dev $OKSDK/proc $OKSDK/sys

