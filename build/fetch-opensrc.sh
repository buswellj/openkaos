#!/bin/bash
#
# Open Kernel Attached Operating System (OpenKaOS)
# Platform Build System version 4.0.0
#
# Copyright (c) 2009-2015 Opaque Systems, LLC
#
# script : fetch-opensrc.sh
# purpose: this script fetches the core open source components from the Internet
#          it then generates the master source tree from those components
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

echo $PBTAG > ~/openkaos/.latest-src

echo "  [.] Retrieving Open Source components "
cd ~/openkaos/$PBENV
mkdir -p pkg/$PBTAG
chmod a+wt pkg/$PBTAG
wget -4 -i $PBHERE/opensrc-list -P pkg/$PBTAG
cd pkg/$PBTAG
mkdir -p patches
chmod a+wt patches
mv *.patch patches
mkdir -p log
chmod a+wt log

echo "  [.] Removing unused components "
# remove unnecessary components
mkdir -p notused
chmod a+wt notused
#mv lfs-bootscripts-* notused
mv sysvinit-* notused
mv vim-* notused

echo "  [.] Unpacking tzdata "
mkdir -p tzdata
mkdir -p archive
cd tzdata
tar xvf ../tzdata*.tar.*
cd ../
mv tzdata*.tar.* archive

echo "  [.] Uncompressing components "
for i in $(ls *.bz2); do echo "   ---- $i"; echo "$i" >> log/uncompress.bz2.log; echo "$i" >> log/uncompress.bz2.err.log; tar jxvf $i 1>>log/uncompress.bz2.log 2>>log/uncompress.bz2.err.log; done
for i in $(ls *.gz); do echo "   ---- $i"; echo "$i" >> log/uncompress.gz.log; echo "$i" >> log/uncompress.gz.err.log; tar zxvf $i 1>>log/uncompress.gz.log 2>>log/uncompress.gz.err.log; done
for i in $(ls *.xz); do echo "   ---- $i"; echo "$i" >> log/uncompress.xz.log; echo "$i" >> log/uncompress.xz.err.log; tar Jxvf $i 1>>log/uncompress.xz.log 2>>log/uncompress.xz.err.log; done

echo "  [.] Creating Source Archive "
mv *.bz2 archive
mv *.gz archive
mv *.xz archive

echo "  [.] Renaming source directories "
mv acl-* acl
mv attr-* attr
mv autoconf-* autoconf
mv automake-* automake
mv bash-* bash
mv bc-* bc
mv binutils-* binutils
mv bison-* bison
mv bridge-utils-* bridge-utils
mv busybox-* busybox
mv bzip2-* bzip2
mv check-* check
mv coreutils-* coreutils
mv cpio-* cpio
mv cracklib-* cracklib
mv dejagnu-* dejagnu
mv dhcpcd-* dhcpcd
mv diffutils-* diffutils
mv e2fsprogs-* e2fsprogs
mv eudev-* eudev
mv expat-* expat
mv expect* expect
mv file-* file
mv findutils-* findutils
mv flex-* flex
mv gawk-* gawk
mv gcc-* gcc
cp -a gcc gcc2
mv gdbm-* gdbm
mv gettext-* gettext
mv git-* git
mv glibc-* glibc
mv gmp-* gmp
mv glib-* glib
cp -a gmp gcc/gmp
cp -a gmp gcc2/gmp
mv gperf-* gperf
mv grep-* grep
mv groff-* groff
mv grub-* grub
mv gzip-* gzip
mv iana-etc-* iana-etc
mv inetutils-* inetutils
mv intltool-* intltool
mv iproute2-* iproute2
mv iptables-* iptables
mv kbd-* kbd
mv kmod* kmod
mv less-* less
mv libcap-* libcap
mv libpipeline-* libpipeline
mv libtool-* libtool
mv linux-* linux
mv Linux-PAM-* linux-pam
mv m4-* m4
mv make-* make
mv man-db-* man-db
mv man-pages-* man-pages
mv mpc-* mpc
cp -a mpc gcc/mpc
cp -a mpc gcc2/mpc
mv mpfr-* mpfr
cp -a mpfr gcc/mpfr
cp -a mpfr gcc2/mpfr
mv ncurses-* ncurses
mv openssh-* openssh
mv openssl-* openssl
mv parted-* parted
mv patch-* patch
mv pcre-* pcre
mv perl-* perl
mv pkg-config-* pkg-config
mv psmisc-* psmisc
mv procps-* procps
mv readline-* readline
mv sed-* sed
mv shadow-* shadow
mv squashfs* squashfs
mv sysklogd-* sysklogd
mv syslinux* syslinux
mv tar-* tar
mv tcl* tcl
mv texinfo-* texinfo
mv util-linux-* util-linux
mv XML-Parser-* XML-Parser
mv xz-* xz
mv zlib-* zlib
cp -a archive/cracklib-words-*.gz cracklib/

echo ""
echo "Source Directory is $PBTAG"
echo ""
cd $PBHERE

