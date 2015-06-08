#!/bin/bash
#
# Open Kernel Attached Operating System (OpenKaOS)
# Platform Build System version 4.0.0
#
# Copyright (c) 2009-2015 Opaque Systems, LLC
#
# script : verify-opensrc.sh
# purpose: this script verifies the opensrc packages have downloaded ok
#

echo ""
echo "OpenKaOS Platform Build System, version 4.0.0"
echo "Copyright (c) 2009-2015 Opaque Systems, LLC"
echo ""
echo ""
echo "  [.] Loading environment "

PBHERE=`pwd`
PBENV=`cat ~/openkaos/.current`
PBNOW=`date +%s`
PBTAG="opensrc-$PBNOW"
export PBHERE PBENV PBNOW PBTAG

echo "  [.] Checking Open Source components "
cd ~/openkaos/$PBENV/pkg/$1

echo "  [.] Verifying open source directories "
if [ -e acl ]; then
 echo "  [.] acl ok "
else
 echo "  [.] acl missing "
fi
if [ -e attr ]; then
 echo "  [.] attr ok "
else
 echo "  [.] attr missing "
fi
if [ -e autoconf ]; then
 echo "  [.] autoconf ok "
else
 echo "  [.] autoconf missing "
fi
if [ -e automake ]; then
 echo "  [.] automake ok "
else
 echo "  [.] automake missing "
fi
if [ -e bash ]; then
 echo "  [.] bash ok "
else
 echo "  [.] bash missing "
fi
if [ -e bc ]; then
 echo "  [.] bc ok "
else
 echo "  [.] bc missing "
fi
if [ -e binutils ]; then
 echo "  [.] binutils ok "
else
 echo "  [.] binutils missing "
fi
if [ -e bison ]; then
 echo "  [.] bison ok "
else
 echo "  [.] bison missing "
fi
if [ -e bridge-utils ]; then
 echo "  [.] bridge-utils ok "
else
 echo "  [.] bridge-utils missing "
fi
if [ -e busybox ]; then
 echo "  [.] busybox ok "
else
 echo "  [.] busybox missing "
fi
if [ -e bzip2 ]; then
 echo "  [.] bzip2 ok "
else
 echo "  [.] bzip2 missing "
fi
if [ -e check ]; then
 echo "  [.] check ok "
else
 echo "  [.] check missing "
fi
if [ -e cpio ]; then
 echo "  [.] cpio ok "
else
 echo "  [.] cpio missing "
fi
if [ -e coreutils ]; then
 echo "  [.] coreutils ok "
else
 echo "  [.] coreutils missing "
fi
if [ -e cracklib ]; then
 echo "  [.] cracklib ok "
else
 echo "  [.] cracklib missing "
fi
if [ -e curl ]; then
 echo "  [.] curl ok "
else
 echo "  [.] curl missing "
fi
if [ -e dejagnu ]; then
 echo "  [.] dejagnu ok "
else
 echo "  [.] dejagnu missing "
fi
if [ -e dhcp ]; then
 echo "  [.] dhcp ok "
else
 echo "  [.] dhcp missing "
fi
if [ -e dhcpcd ]; then
 echo "  [.] dhcpcd ok "
else
 echo "  [.] dhcpcd missing "
fi
if [ -e diffutils ]; then
 echo "  [.] diffutils ok "
else
 echo "  [.] diffutils missing "
fi
if [ -e e2fsprogs ]; then
 echo "  [.] e2fsprogs ok "
else
 echo "  [.] e2fsprogs missing "
fi
if [ -e eudev ]; then
 echo "  [.] eudev ok "
else
 echo "  [.] eudev missing "
fi
if [ -e expat ]; then
 echo "  [.] expat ok "
else
 echo "  [.] expat missing "
fi
if [ -e expect ]; then
 echo "  [.] expect ok "
else
 echo "  [.] expect missing "
fi
if [ -e file ]; then
 echo "  [.] file ok "
else
 echo "  [.] file missing "
fi
if [ -e findutils ]; then
 echo "  [.] findutils ok "
else
 echo "  [.] findutils missing "
fi
if [ -e flex ]; then
 echo "  [.] flex ok "
else
 echo "  [.] flex missing "
fi
if [ -e gawk ]; then
 echo "  [.] gawk ok "
else
 echo "  [.] gawk missing "
fi
if [ -e gcc ]; then
 echo "  [.] gcc ok "
else
 echo "  [.] gcc missing "
fi
if [ -e gcc2 ]; then
 echo "  [.] gcc2 ok "
else
 echo "  [.] gcc2 missing "
fi
if [ -e gdbm ]; then
 echo "  [.] gdbm ok "
else
 echo "  [.] gdbm missing "
fi
if [ -e gettext ]; then
 echo "  [.] gettext ok "
else
 echo "  [.] gettext missing "
fi
if [ -e git ]; then
 echo "  [.] git ok "
else
 echo "  [.] git missing "
fi
if [ -e glibc ]; then
 echo "  [.] glibc ok "
else
 echo "  [.] glibc missing "
fi
if [ -e gmp ]; then
 echo "  [.] gmp ok "
else
 echo "  [.] gmp missing "
fi
if [ -e glib ]; then
 echo "  [.] glib ok "
else
 echo "  [.] glib missing "
fi
if [ -e gcc/gmp ]; then
 echo "  [.] gcc-gmp ok "
else
 echo "  [.] gcc-gmp missing "
fi
if [ -e gcc2/gmp ]; then
 echo "  [.] gcc2-gmp ok "
else
 echo "  [.] gcc2-gmp missing "
fi
if [ -e gperf ]; then
 echo "  [.] gperf ok "
else
 echo "  [.] gperf missing "
fi
if [ -e grep ]; then
 echo "  [.] grep ok "
else
 echo "  [.] grep missing "
fi
if [ -e groff ]; then
 echo "  [.] groff ok "
else
 echo "  [.] groff missing "
fi
if [ -e grub ]; then
 echo "  [.] grub ok "
else
 echo "  [.] grub missing "
fi
if [ -e gzip ]; then
 echo "  [.] gzip ok "
else
 echo "  [.] gzip missing "
fi
if [ -e haveged ]; then
 echo "  [.] haveged ok "
else
 echo "  [.] haveged missing "
fi
if [ -e iana-etc ]; then
 echo "  [.] iana-etc ok "
else
 echo "  [.] iana-etc missing "
fi
if [ -e inetutils ]; then
 echo "  [.] inetutils ok "
else
 echo "  [.] inetutils missing "
fi
if [ -e intltool ]; then
 echo "  [.] intltool ok "
else
 echo "  [.] intltool missing "
fi
if [ -e iproute2 ]; then
 echo "  [.] iproute2 ok "
else
 echo "  [.] iproute2 missing "
fi
if [ -e kbd ]; then
 echo "  [.] kbd ok "
else
 echo "  [.] kbd missing "
fi
if [ -e kmod ]; then
 echo "  [.] kmod ok "
else
 echo "  [.] kmod missing "
fi
if [ -e less ]; then
 echo "  [.] less ok "
else
 echo "  [.] less missing "
fi
if [ -e libcap ]; then
 echo "  [.] libcap ok "
else
 echo "  [.] libcap missing "
fi
if [ -e libpipeline ]; then
 echo "  [.] libpipeline ok "
else
 echo "  [.] libpipeline missing "
fi
if [ -e libtool ]; then
 echo "  [.] libtool ok "
else
 echo "  [.] libtool missing "
fi
if [ -e linux ]; then
 echo "  [.] linux ok "
else
 echo "  [.] linux missing "
fi
if [ -e linux-pam ]; then
 echo "  [.] linux-pam ok "
else
 echo "  [.] linux-pam missing "
fi
if [ -e lzo ]; then
 echo "  [.] lzo ok "
else
 echo "  [.] lzo missing "
fi
if [ -e m4 ]; then
 echo "  [.] m4 ok "
else
 echo "  [.] m4 missing "
fi
if [ -e make ]; then
 echo "  [.] make ok "
else
 echo "  [.] make missing "
fi
if [ -e man-db ]; then
 echo "  [.] man-db ok "
else
 echo "  [.] man-db missing "
fi
if [ -e man-pages ]; then
 echo "  [.] man-pages ok "
else
 echo "  [.] man-pages missing "
fi
if [ -e mpc ]; then
 echo "  [.] mpc ok "
else
 echo "  [.] mpc missing "
fi
if [ -e gcc/mpc ]; then
 echo "  [.] gcc-mpc ok "
else
 echo "  [.] gcc-mpc missing "
fi
if [ -e gcc2/mpc ]; then
 echo "  [.] gcc2-mpc ok "
else
 echo "  [.] gcc2-mpc missing "
fi
if [ -e mpfr ]; then
 echo "  [.] mpfr ok "
else
 echo "  [.] mpfr missing "
fi
if [ -e gcc/mpfr ]; then
 echo "  [.] gcc-mpfr ok "
else
 echo "  [.] gcc-mpfr missing "
fi
if [ -e gcc2/mpfr ]; then
 echo "  [.] gcc2-mpfr ok "
else
 echo "  [.] gcc2-mpfr missing "
fi
if [ -e ncurses ]; then
 echo "  [.] ncurses ok "
else
 echo "  [.] ncurses missing "
fi
if [ -e nano ]; then
 echo "  [.] nano ok "
else
 echo "  [.] nano missing "
fi
if [ -e openssh ]; then
 echo "  [.] openssh ok "
else
 echo "  [.] openssh missing "
fi
if [ -e openssl ]; then
 echo "  [.] openssl ok "
else
 echo "  [.] openssl missing "
fi
if [ -e parted ]; then
 echo "  [.] parted ok "
else
 echo "  [.] parted missing "
fi
if [ -e patch ]; then
 echo "  [.] patch ok "
else
 echo "  [.] patch missing "
fi
if [ -e pcre ]; then
 echo "  [.] pcre ok "
else
 echo "  [.] pcre missing "
fi
if [ -e perl ]; then
 echo "  [.] perl ok "
else
 echo "  [.] perl missing "
fi
if [ -e pkg-config ]; then
 echo "  [.] pkg-config ok "
else
 echo "  [.] pkg-config missing "
fi
if [ -e psmisc ]; then
 echo "  [.] psmisc ok "
else
 echo "  [.] psmisc missing "
fi
if [ -e procps ]; then
 echo "  [.] procps ok "
else
 echo "  [.] procps missing "
fi
if [ -e readline ]; then
 echo "  [.] readline ok "
else
 echo "  [.] readline missing "
fi
if [ -e sed ]; then
 echo "  [.] sed ok "
else
 echo "  [.] sed missing "
fi
if [ -e shadow ]; then
 echo "  [.] shadow ok "
else
 echo "  [.] shadow missing "
fi
if [ -e squashfs ]; then
 echo "  [.] squashfs ok "
else
 echo "  [.] squashfs missing "
fi
if [ -e sysklogd ]; then
 echo "  [.] sysklogd ok "
else
 echo "  [.] sysklogd missing "
fi
if [ -e syslinux ]; then
 echo "  [.] syslinux ok "
else
 echo "  [.] syslinux missing "
fi
if [ -e tar ]; then
 echo "  [.] tar ok "
else
 echo "  [.] tar missing "
fi
if [ -e tcl ]; then
 echo "  [.] tcl ok "
else
 echo "  [.] tcl missing "
fi
if [ -e texinfo ]; then
 echo "  [.] texinfo ok "
else
 echo "  [.] texinfo missing "
fi
if [ -e util-linux ]; then
 echo "  [.] util-linux ok "
else
 echo "  [.] util-linux  missing "
fi
if [ -e wget ]; then
 echo "  [.] wget ok "
else
 echo "  [.] wget  missing "
fi
if [ -e XML-Parser ]; then
 echo "  [.] XML-Parser ok "
else
 echo "  [.] XML-Parser  missing "
fi
if [ -e xz ]; then
 echo "  [.] xz ok "
else
 echo "  [.] xz missing "
fi
if [ -e zlib ]; then
 echo "  [.] zlib ok "
else
 echo "  [.] zlib missing "
fi

echo ""
echo "   [*] Verifiying Patch directory..."
echo ""
ls -la patches/

echo ""
echo "Source Directory is $1"
echo ""
cd $PBHERE

