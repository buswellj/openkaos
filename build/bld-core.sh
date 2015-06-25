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
APPSTATE=/app/status
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
mkdir -p $SDK/kernel
mkdir -p $SDK/tools
mkdir -p $APPQ
mkdir -p $APPCONFIG
mkdir -p $APPSTATE
chown 0:0 -R $SDK
chown 0:0 -R $APPQ

cp -a $SRC/bld-cpio.sh $SDK/tools
cp -a $SRC/*-linode $SDK/kernel
cp -a $SRC/linux $SDK/kernel

cd $SRC/cpio
patch -Np1 -i ../patches/cpio-2.11-remove_gets.patch 1>>$LOGS/cpio.log 2>>$LOGS/cpio.err
./configure --prefix=/usr --bindir=/bin --with-gnu-ld 1>>$LOGS/cpio.log 2>>$LOGS/cpio.err
make 1>>$LOGS/cpio.log 2>>$LOGS/cpio.err
make install 1>>$LOGS/cpio.log 2>>$LOGS/cpio.err

cd $SRC/lzo
./configure --prefix=/usr --enable-shared --disable-static 1>>$LOGS/lzo.log 2>>$LOGS/lzo.err
make 1>>$LOGS/lzo.log 2>>$LOGS/lzo.err
make install 1>>$LOGS/lzo.log 2>>$LOGS/lzo.err
ldconfig

cd $SRC/bridge-utils
autoconf 1>>$LOGS/bridge-utils.log 2>>$LOGS/bridge-utils.err
./configure --prefix=/usr --sbindir=/sbin --bindir=/bin 1>>$LOGS/bridge-utils.log 2>>$LOGS/bridge-utils.err
make 1>>$LOGS/bridge-utils.log 2>>$LOGS/bridge-utils.err
make install 1>>$LOGS/bridge-utils.log 2>>$LOGS/bridge-utils.err

cd $SRC/openssl
mkdir -p $APPCONFIG/openssl
mkdir -p $APPQ/openssl/1.0.2
patch -Np1 -i ../patches/openssl-1.0.2a-fix_parallel_build-2.patch 1>>$LOGS/openssl.log 2>>$LOGS/openssl.err
./config --prefix=/usr zlib-dynamic shared 1>>$LOGS/openssl.log 2>>$LOGS/openssl.err
make 1>>$LOGS/openssl.log 2>>$LOGS/openssl.err
make test 1>>$LOGS/openssl.log 2>>$LOGS/openssl.err
make install 1>>$LOGS/openssl.log 2>>$LOGS/openssl.err
ldconfig

cd $SRC/tools
cp -a make-cert.pl /usr/bin
chmod +x /usr/bin/make-cert.pl
cp -a make-ca.sh /usr/bin
chmod +x /usr/bin/make-ca.sh
cp -a remove-expired-certs.sh /usr/sbin
chmod +x /usr/sbin/remove-expired-certs.sh
cp $SRC/patches/certdata.txt .

/usr/bin/make-ca.sh
SSLDIR=/etc/ssl                                              &&
remove-expired-certs.sh certs                                &&
install -d ${SSLDIR}/certs                                   &&
cp -v certs/*.pem ${SSLDIR}/certs                            &&
c_rehash                                                     &&
install BLFS-ca-bundle*.crt ${SSLDIR}/ca-bundle.crt          &&
ln -sfv ../ca-bundle.crt ${SSLDIR}/certs/ca-certificates.crt &&
unset SSLDIR

cd $SRC/linux-pam
./configure --prefix=/usr --sysconfdir=/etc --libdir=/usr/lib --enable-securedir=/lib/security 1>>$LOGS/linux-pam.log 2>>$LOGS/linux-pam.err
make 1>>$LOGS/linux-pam.log 2>>$LOGS/linux-pam.err
make install 1>>$LOGS/linux-pam.log 2>>$LOGS/linux-pam.err

cd $SRC/openssh
install -v -m700 -d /var/lib/sshd
chown   -v root:sys /var/lib/sshd
groupadd -g 50 sshd
useradd -c 'sshd PrivSep' -d /var/lib/sshd -g sshd -s /bin/false -u 50 sshd
./configure --prefix=/usr --sysconfdir=/etc/ssh --with-md5-passwords \
 --with-privsep-path=/var/lib/sshd --with-pam --with-ipaddr-display --with-4in6 1>>$LOGS/openssh.log 2>>$LOGS/openssh.err
make 1>>$LOGS/openssh.log 2>>$LOGS/openssh.err
make install 1>>$LOGS/openssh.log 2>>$LOGS/openssh.err

cd $SRC/curl
./configure --prefix=/usr --disable-static \
 --enable-threaded-resolver --with-ssl 1>>$LOGS/curl.log 2>>$LOGS/curl.err
make 1>>$LOGS/curl.log 2>>$LOGS/curl.err
make install 1>>$LOGS/curl.log 2>>$LOGS/curl.err

cd $SRC/git
./configure --prefix=/usr --with-openssl=$APPQUEUE/openssl --with-curl 1>>$LOGS/git.log 2>>$LOGS/git.err
make 1>>$LOGS/git.log 2>>$LOGS/git.err
make install 1>>$LOGS/git.log 2>>$LOGS/git.err

cd $SRC/dhcp
./configure --prefix=/usr 1>>$LOGS/dhcp.log 2>>$LOGS/dhcp.err
make 1>>$LOGS/dhcp.log 2>>$LOGS/dhcp.err
make install 1>>$LOGS/dhcp.log 2>>$LOGS/dhcp.err
cat client/scripts/linux | sed 's/bash/ash/g' > /usr/sbin/dhclient-script

cd $SRC/squashfs/squashfs-tools
mv Makefile Makefile.orig 1>>$LOGS/sqfs.log 2>>$LOGS/sqfs.err
cat Makefile.orig | sed 's/#XZ_SUPPORT/XZ_SUPPORT/g' | sed 's/\/usr\/local\/bin/\/usr\/bin/g' > Makefile
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

cd $SRC/nano
./configure --prefix=/usr --sysconfdir=/etc --enable-utf8 1>>$LOGS/nano.log 2>>$LOGS/nano.err
make 1>>$LOGS/nano.log 2>>$LOGS/nano.err
make install 1>>$LOGS/nano.log 2>>$LOGS/nano.err

cd $SRC/haveged
./configure --prefix=/usr --with-gnu-ld --with-pic --enable-shared --disable-static 1>>$LOGS/haveged.log 2>>$LOGS/haveged.err
make 1>>$LOGS/haveged.log 2>>$LOGS/haveged.err
make install 1>>$LOGS/haveged.log 2>>$LOGS/haveged.err

cd $SRC/sqlite
./configure --prefix=/usr 1>>$LOGS/sqlite.log 2>>$LOGS/sqlite.err
make 1>>$LOGS/sqlite.log 2>>$LOGS/sqlite.err
make install 1>>$LOGS/sqlite.log 2>>$LOGS/sqlite.err

cd $SRC/python
./configure --prefix=/usr --enable-shared --with-system-expat --with-system-ffi --enable-unicode=ucs4 1>>$LOGS/python.log 2>>$LOGS/python.err
make 1>>$LOGS/python.log 2>>$LOGS/python.err
make install 1>>$LOGS/python.log 2>>$LOGS/python.err

cd $SRC/iojs
./configure --prefix=/usr 1>>$LOGS/iojs.log 2>>$LOGS/iojs.err
make 1>>$LOGS/iojs.log 2>>$LOGS/iojs.err
make install 1>>$LOGS/iojs.log 2>>$LOGS/iojs.err

ln -sf /sbin/busybox /usr/bin/vi

cd $SRC
source ./bld-cpio.sh

exit
