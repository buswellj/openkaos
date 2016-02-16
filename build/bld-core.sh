#
# Open Kernel Attached Operating System (OpenKaOS)
# Platform Build System version 5.0.0
#
# Copyright (c) 2009-2016 Opaque Systems, LLC 
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
mkdir -p $APPCONFIG
mkdir -p $APPQ
mkdir -p $APPSTATE

cd $SRC/cpio
./configure --prefix=/usr --bindir=/bin --enable-mt --with-rmt=/usr/libexec/rmt --with-gnu-ld 1>>$LOGS/cpio.log 2>>$LOGS/cpio.err
make 1>>$LOGS/cpio.log 2>>$LOGS/cpio.err
make install 1>>$LOGS/cpio.log 2>>$LOGS/cpio.err

cd $SRC/lzo
./configure --prefix=/usr --enable-shared --disable-static 1>>$LOGS/lzo.log 2>>$LOGS/lzo.err
make 1>>$LOGS/lzo.log 2>>$LOGS/lzo.err
make install 1>>$LOGS/lzo.log 2>>$LOGS/lzo.err
ldconfig

cd $SRC/bridge-utils
patch -Np1 -i ../patches/bridge-utils-1.5-linux_3.8_fix-1.patch
autoconf -o configure configure.in  1>>$LOGS/bridge-utils.log 2>>$LOGS/bridge-utils.err
./configure --prefix=/usr --sbindir=/sbin --bindir=/bin 1>>$LOGS/bridge-utils.log 2>>$LOGS/bridge-utils.err
make 1>>$LOGS/bridge-utils.log 2>>$LOGS/bridge-utils.err
make install 1>>$LOGS/bridge-utils.log 2>>$LOGS/bridge-utils.err

cd $SRC/openssl
./config --prefix=/usr --openssldir=/etc/ssl --libdir=lib zlib-dynamic shared 1>>$LOGS/openssl.log 2>>$LOGS/openssl.err
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
chmod -v 4755 /sbin/unix_chkpwd &&

for file in pam pam_misc pamc
do
  mv -v /usr/lib/lib${file}.so.* /lib &&
  ln -sfv ../../lib/$(readlink /usr/lib/lib${file}.so) /usr/lib/lib${file}.so
done


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

cd $SRC/dhcp
#patch -Np1 -i ../patches/dhcp-4.3.3-P1-nosupport_ipv6-1.patch
patch -Np1 -i ../patches/dhcp-4.3.3-P1-client_script-1.patch
CFLAGS="-D_PATH_DHCLIENT_SCRIPT='\"/sbin/dhclient-script\"'         \
        -D_PATH_DHCPD_CONF='\"/etc/dhcp/dhcpd.conf\"'               \
        -D_PATH_DHCLIENT_CONF='\"/etc/dhcp/dhclient.conf\"'"        \
./configure --prefix=/usr                                           \
            --sysconfdir=/etc/dhcp                                  \
            --localstatedir=/var                                    \
            --with-srv-lease-file=/var/lib/dhcpd/dhcpd.leases       \
            --with-srv6-lease-file=/var/lib/dhcpd/dhcpd6.leases     \
            --with-cli-lease-file=/var/lib/dhclient/dhclient.leases \
            --with-cli6-lease-file=/var/lib/dhclient/dhclient6.leases 1>>$LOGS/dhcp.log 2>>$LOGS/dhcp.err
make -j1 1>>$LOGS/dhcp.log 2>>$LOGS/dhcp.err
make install 1>>$LOGS/dhcp.log 2>>$LOGS/dhcp.err
mv -v /usr/sbin/dhclient /sbin
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
./configure --prefix=/usr --sbindir=/sbin --disable-nftables --enable-libipq --with-xtlibdir=/lib/xtables 1>>$LOGS/iptables.log 2>>$LOGS/iptables.err
make 1>>$LOGS/iptables.log 2>>$LOGS/iptables.err
make install 1>>$LOGS/iptables.log 2>>$LOGS/iptables.err
ln -sfv ../../sbin/xtables-multi /usr/bin/iptables-xml &&

for file in ip4tc ip6tc ipq iptc xtables
do
  mv -v /usr/lib/lib${file}.so.* /lib &&
  ln -sfv ../../lib/$(readlink /usr/lib/lib${file}.so) /usr/lib/lib${file}.so
done
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
./configure --prefix=/usr --disable-static        \
            CFLAGS="-g -O2 -DSQLITE_ENABLE_FTS3=1 \
            -DSQLITE_ENABLE_COLUMN_METADATA=1     \
            -DSQLITE_ENABLE_UNLOCK_NOTIFY=1       \
            -DSQLITE_SECURE_DELETE=1              \
            -DSQLITE_ENABLE_DBSTAT_VTAB=1" 1>>$LOGS/sqlite.log 2>>$LOGS/sqlite.err
make -j1 1>>$LOGS/sqlite.log 2>>$LOGS/sqlite.err
make install 1>>$LOGS/sqlite.log 2>>$LOGS/sqlite.err

cd $SRC/libffi
sed -e '/^includesdir/ s/$(libdir).*$/$(includedir)/' \
    -i include/Makefile.in
sed -e '/^includedir/ s/=.*$/=@includedir@/' \
    -e 's/^Cflags: -I${includedir}/Cflags:/' \
    -i libffi.pc.in
./configure --prefix=/usr --disable-static 1>>$LOGS/libffi.log 2>>$LOGS/libffi.err
make 1>>$LOGS/libffi.log 2>>$LOGS/libffi.err
make install 1>>$LOGS/libffi.log 2>>$LOGS/libffi.err
ldconfig

cd $SRC/python
./configure --prefix=/usr --enable-shared --with-system-expat --with-system-ffi --enable-unicode=ucs4 1>>$LOGS/python.log 2>>$LOGS/python.err
make 1>>$LOGS/python.log 2>>$LOGS/python.err
make install 1>>$LOGS/python.log 2>>$LOGS/python.err

ldconfig

cd $SRC/git
./configure --prefix=/usr --with-gitconfig=/etc/gitconfig --with-curl 1>>$LOGS/git.log 2>>$LOGS/git.err
make 1>>$LOGS/git.log 2>>$LOGS/git.err
make install 1>>$LOGS/git.log 2>>$LOGS/git.err

cd $SRC/node
./configure --prefix=/usr 1>>$LOGS/nodejs.log 2>>$LOGS/nodejs.err
make 1>>$LOGS/nodejs.log 2>>$LOGS/nodejs.err
make install 1>>$LOGS/nodejs.log 2>>$LOGS/nodejs.err

cd $SRC/kexec-tools
./configure --prefix=/usr 1>>$LOGS/kexec-tools.log 2>>$LOGS/kexec-tools.err
make 1>>$LOGS/kexec-tools.log 2>>$LOGS/kexec-tools.err
make install 1>>$LOGS/kexec-tools.log 2>>$LOGS/kexec-tools.err

ln -sf /sbin/busybox /usr/bin/vi

cd $SRC
source ./bld-cpio.sh

exit
