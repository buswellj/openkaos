#
# Open Kernel Attached Operating System (OpenKaOS)
# Platform Build System version 4.0.0
#
# Copyright (c) 2009-2015 Opaque Systems, LLC 
#
# script : bld-core.sh
# purpose: SDK core build script - generates packages used in running system
#

TOOLS=`cat /.tools`
SRC=/src
SDK=/sdk
APPCONFIG=/app/config
APPQ=/app/queue/pkg
APPQUEUE=/app/queue
LOGS=/src/logs
CFLAGS="-O2 -fPIC -pipe"
CXXFLAGS="$CFLAGS"
KAOSCPUS=`cat /proc/cpuinfo | grep processor | wc -l`
export SDK SRC TOOLS LOGS CFLAGS CXXFLAGS KAOSCPUS APPQ APPCONFIG APPQUEUE
MAKEOPTS="-j$KAOSCPUS"
export MAKEOPTS

cd $SRC/
mkdir -p $SDK
mkdir -p $APPQ
chown 0:0 -R $SDK
chown 0:0 -R $APPQ

cd $SRC/cpio
patch -Np1 -i ../patches/cpio-2.11-remove_gets.patch 1>>$LOGS/cpio.log 2>>$LOGS/cpio.err
./configure --prefix=/usr --bindir=/bin --with-gnu-ld 1>>$LOGS/cpio.log 2>>$LOGS/cpio.err
make 1>>$LOGS/cpio.log 2>>$LOGS/cpio.err
make install 1>>$LOGS/cpio.log 2>>$LOGS/cpio.err

cd $SRC/bridge-utils
autoconf 1>>$LOGS/bridge-utils.log 2>>$LOGS/bridge-utils.err
./configure --prefix=/usr --sbindir=/sbin --bindir=/bin 1>>$LOGS/bridge-utils.log 2>>$LOGS/bridge-utils.err
make 1>>$LOGS/bridge-utils.log 2>>$LOGS/bridge-utils.err
make install 1>>$LOGS/bridge-utils.log 2>>$LOGS/bridge-utils.err

cd $SRC/openssl
mkdir -p $APPCONFIG/openssl
mkdir -p $APPQ/openssl/1.0.2
patch -Np1 -i ../patches/openssl-1.0.2a-fix_parallel_build-2.patch 1>>$LOGS/openssl.log 2>>$LOGS/openssl.err
./config --prefix=$APPQ/openssl/1.0.2/ --openssldir=$APPCONFIG/openssl/ zlib-dynamic shared 1>>$LOGS/openssl.log 2>>$LOGS/openssl.err
make 1>>$LOGS/openssl.log 2>>$LOGS/openssl.err
make test 1>>$LOGS/openssl.log 2>>$LOGS/openssl.err
make install 1>>$LOGS/openssl.log 2>>$LOGS/openssl.err
ln -sf $APPQ/openssl/1.0.2 $APPQUEUE/openssl
echo $APPQUEUE/openssl/lib > /etc/ld.so.conf.d/openssl.conf
ldconfig

cd $SRC/linux-pam
./configure --prefix=/usr --sysconfdir=/etc --libdir=/usr/lib --enable-securedir=/lib/security 1>>$LOGS/linux-pam.log 2>>$LOGS/linux-pam.err
make 1>>$LOGS/linux-pam.log 2>>$LOGS/linux-pam.err
make install 1>>$LOGS/linux-pam.log 2>>$LOGS/linux-pam.err

cd $SRC/openssh
install -v -m700 -d /var/lib/sshd
chown   -v root:sys /var/lib/sshd
groupadd -g 50 sshd
useradd -c 'sshd PrivSep' -d /var/lib/sshd -g sshd -s /bin/false -u 50 sshd
CFLAGS="$CFLAGS -I$APPQUEUE/openssl/include -L$APPQUEUE/lib" ./configure --prefix=/usr --sysconfdir=/etc/ssh --with-md5-passwords \
 --with-privsep-path=/var/lib/sshd --with-pam --with-ipaddr-display --with-4in6 --with-ldflags=-L$APPQUEUE/openssl/lib 1>>$LOGS/openssh.log 2>>$LOGS/openssh.err
make 1>>$LOGS/openssh.log 2>>$LOGS/openssh.err
make install 1>>$LOGS/openssh.log 2>>$LOGS/openssh.err

cd $SRC/curl
CFLAGS="$CFLAGS -I$APPQUEUE/openssl/include -L$APPQUEUE/openssl/lib" LDFLAGS="-L$APPQUEUE/openssl/lib" ./configure --prefix=/usr --disable-static \
 --enable-threaded-resolver --with-ssl 1>>$LOGS/curl.log 2>>$LOGS/curl.err
make 1>>$LOGS/curl.log 2>>$LOGS/curl.err
make install 1>>$LOGS/curl.log 2>>$LOGS/curl.err

cd $SRC/git
CFLAGS="$CFLAGS -I$APPQUEUE/openssl/include -L$APPQUEUE/openssl/lib" ./configure --prefix=/usr --with-openssl=$APPQUEUE/openssl --with-curl 1>>$LOGS/git.log 2>>$LOGS/git.err
make 1>>$LOGS/git.log 2>>$LOGS/git.err
make install 1>>$LOGS/git.log 2>>$LOGS/git.err

cd $SRC/dhcpcd
./configure --prefix=$APPQ/dhcpcd/6.9.0 --sysconfdir=$APPCONFIG/dhcpcd 1>>$LOGS/dhcpcd.log 2>>$LOGS/dhcpcd.err
make 1>>$LOGS/dhcpcd.log 2>>$LOGS/dhcpcd.err
make install 1>>$LOGS/dhcpcd.log 2>>$LOGS/dhcpcd.err
ln -sf $APPQ/dhcpcd/6.9.0 $APPQUEUE/dhcpcd 1>>$LOGS/dhcpcd.log 2>>$LOGS/dhcpcd.err
echo $APPQUEUE/dhcpcd/lib > /etc/ld.so.conf.d/dhcpcd.conf 1>>$LOGS/dhcpcd.log 2>>$LOGS/dhcpcd.err
ldconfig 1>>$LOGS/dhcpcd.log 2>>$LOGS/dhcpcd.err

cd $SRC/squashfs/squashfs-tools
mv Makefile Makefile.orig 1>>$LOGS/sqfs.log 2>>$LOGS/sqfs.err
cat Makefile.orig | sed 's/#XZ_SUPPORT/XZ_SUPPORT/g' | sed 's/\/usr\/local\/bin/\/usr\/bin/g' > Makefile 1>>$LOGS/sqfs.log 2>>$LOGS/sqfs.err
make 1>>$LOGS/sqfs.log 2>>$LOGS/sqfs.err
make install 1>>$LOGS/sqfs.log 2>>$LOGS/sqfs.err

cd $SRC/busybox
make defconfig 1>>$LOGS/busybox.log 2>>$LOGS/busybox.err
sed -e 's/.*FEATURE_PREFER_APPLETS.*/CONFIG_FEATURE_PREFER_APPLETS=y/' -i .config 1>>$LOGS/busybox.log 2>>$LOGS/busybox.err
sed -e 's/.*FEATURE_SH_STANDALONE.*/CONFIG_FEATURE_SH_STANDALONE=y/' -i .config 1>>$LOGS/busybox.log 2>>$LOGS/busybox.err
make 1>>$LOGS/busybox.log 2>>$LOGS/busybox.err
cp busybox /sbin 1>>$LOGS/busybox.log 2>>$LOGS/busybox.err

cd $SRC/iptables
./configure --prefix=/usr --sbindir=/sbin --enable-libipq --with-xtlibdir=/lib/xtables 1>>$LOGS/iptables.log 2>>$LOGS/iptables.err
make 1>>$LOGS/iptables.log 2>>$LOGS/iptables.err
make install 1>>$LOGS/iptables.log 2>>$LOGS/iptables.err
ldconfig

exit
