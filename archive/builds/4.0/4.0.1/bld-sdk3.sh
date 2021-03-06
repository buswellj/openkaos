#
# Open Kernel Attached Operating System (OpenKaOS)
# Platform Build System version 4.0.0
#
# Copyright (c) 2009-2015 Opaque Systems, LLC 
#
# script : bld-sdk.sh
# purpose: sdk build script 3 of 3, creates SDK chroot from toolchain
#

TOOLS=`cat /.tools`
SRC=/src
LOGS=/src/logs
CFLAGS="-O2 -fPIC -pipe"
CXXFLAGS="$CFLAGS"
KAOSCPUS=`cat /proc/cpuinfo | grep processor | wc -l`
export SRC TOOLS LOGS CFLAGS CXXFLAGS KAOSCPUS
MAKEOPTS="-j$KAOSCPUS"
export MAKEOPTS

echo ""
echo "  [*] Building SDK: stage 3 of 3..."
echo ""
echo "  [.] Stripping debug information from execs..."
echo ""

$TOOLS/bin/find /{,usr/}{bin,lib,sbin} -type f \
  -exec $TOOLS/bin/strip --strip-debug '{}' ';' 1>>$LOGS/strip-fcs.log 2>>$LOGS/strip-chroot.err

$TOOLS/bin/find /{,usr/}{bin,sbin} -type f \
  -exec $TOOLS/bin/strip --strip-all '{}' ';' 1>>$LOGS/strip-fcs.log 2>>$LOGS/strip-chroot.err

exit

