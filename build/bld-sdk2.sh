#
# Open Kernel Attached Operating System (OpenKaOS)
# Platform Build System version 4.0.0
#
# Copyright (c) 2009-2015 Opaque Systems, LLC 
#
# script : bld-sdk.sh
# purpose: sdk build script 2 of 3, creates SDK chroot from toolchain
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
echo "  [*] Building SDK: stage 2 of 3..."

echo "  [.] bc"
cd $SRC/bc
patch -Np1 -i ../patches/bc-1.06.95-memory_leak-1.patch 1>>$LOGS/bc.log 2>>$LOGS/bc.err
./configure --prefix=/usr --with-readline 1>>$LOGS/bc.log 2>>$LOGS/bc.err
make 1>>$LOGS/bc.log 2>>$LOGS/bc.err
make install 1>>$LOGS/bc.log 2>>$LOGS/bc.err

echo "  [.] libtool"
cd $SRC/libtool
./configure --prefix=/usr 1>>$LOGS/libtool.log 2>>$LOGS/libtool.err
make 1>>$LOGS/libtool.log 2>>$LOGS/libtool.err
make check 1>>$LOGS/libtool.log 2>>$LOGS/libtool.err
make install 1>>$LOGS/libtool.log 2>>$LOGS/libtool.err

echo "  [.] gdbm "
cd $SRC/gdbm
./configure --prefix=/usr --disable-static --enable-libgdbm-compat 1>>$LOGS/gdbm.log 2>>$LOGS/gdbm.err
make 1>>$LOGS/gdbm.log 2>>$LOGS/gdbm.err
make install 1>>$LOGS/gdbm.log 2>>$LOGS/gdbm.err

echo "  [.] expat "
cd $SRC/expat
./configure --prefix=/usr --disable-static 1>$LOGS/expat.log 2>$LOGS/expat.err
make 1>>$LOGS/expat.log 2>>$LOGS/expat.err
make install 1>>$LOGS/expat.log 2>>$LOGS/expat.err

echo "  [.] inetutils"
cd $SRC/inetutils
echo '#define PATH_PROCNET_DEV "/proc/net/dev"' >> ifconfig/system/linux.h
./configure --prefix=/usr --libexecdir=/usr/sbin \
    --localstatedir=/var \
    --disable-logger --disable-whois \
    --disable-servers 1>>$LOGS/inetutils.log 2>>$LOGS/inetutils.err

make 1>>$LOGS/inetutils.log 2>>$LOGS/inetutils.err
make install 1>>$LOGS/inetutils.log 2>>$LOGS/inetutils.err
mv -v /usr/bin/{hostname,ping,ping6,traceroute} /bin
mv -v /usr/bin/ifconfig /sbin

echo "  [.] perl"
cd $SRC/perl
echo "127.0.0.1 localhost $(hostname)" > /etc/hosts
export BUILD_ZLIB=False
export BUILD_BZIP2=0
#patch -Np1 -i ../patches/perl-5.20.2-gcc5_fixes-1.patch 1>>$LOGS/perl.log 2>>$LOGS/perl.err
sh Configure -des -Dprefix=/usr \
                  -Dvendorprefix=/usr           \
                  -Dman1dir=/usr/share/man/man1 \
                  -Dman3dir=/usr/share/man/man3 \
                  -Dpager="/usr/bin/less -isR" \
                  -Duseshrplib 1>>$LOGS/perl.log 2>>$LOGS/perl.err

make 1>>$LOGS/perl.log 2>>$LOGS/perl.err
make -k test 1>>$LOGS/perl.log 2>>$LOGS/perl.err
make install 1>>$LOGS/perl.log 2>>$LOGS/perl.err
unset BUILD_ZLIB BUILD_BZIP2

echo "  [.] XML-Parser "
cd $SRC/XML-Parser
perl Makefile.PL 1>>$LOGS/xmlparser.log 2>>$LOGS/xmlparser.err
make 1>>$LOGS/xmlparser.log 2>>$LOGS/xmlparser.err
make test 1>>$LOGS/xmlparser.log 2>>$LOGS/xmlparser.err
make install 1>>$LOGS/xmlparser.log 2>>$LOGS/xmlparser.err

echo "  [.] autoconf"
cd $SRC/autoconf
./configure --prefix=/usr 1>>$LOGS/autoconf.log 2>>$LOGS/autoconf.err
make 1>>$LOGS/autoconf.log 2>>$LOGS/autoconf.err
#make check 1>>$LOGS/autoconf.log 2>>$LOGS/autoconf.err
make install 1>>$LOGS/autoconf.log 2>>$LOGS/autoconf.err

echo "  [.] automake"
cd $SRC/automake
./configure --prefix=/usr --docdir=/usr/share/doc/automake-1.14.1 1>>$LOGS/automake.log 2>>$LOGS/automake.err
make 1>>$LOGS/automake.log 2>>$LOGS/automake.err
make install 1>>$LOGS/automake.log 2>>$LOGS/automake.err

echo "  [.] diffutils"
cd $SRC/diffutils
sed -i 's:= @mkdir_p@:= /bin/mkdir -p:' po/Makefile.in.in
./configure --prefix=/usr 1>>$LOGS/diffutils.log 2>>$LOGS/diffutils.err
make 1>>$LOGS/diffutils.log 2>>$LOGS/diffutils.err
make install 1>>$LOGS/diffutils.log 2>>$LOGS/diffutils.err

echo "  [.] gawk"
cd $SRC/gawk
./configure --prefix=/usr --libexecdir=/usr/lib 1>>$LOGS/gawk.log 2>>$LOGS/gawk.err
make 1>>$LOGS/gawk.log 2>>$LOGS/gawk.err
make install 1>>$LOGS/gawk.log 2>>$LOGS/gawk.err

echo "  [.] findutils "
cd $SRC/findutils
./configure --prefix=/usr \
    --localstatedir=/var/lib/locate 1>>$LOGS/findutils.log 2>>$LOGS/findutils.err
make 1>>$LOGS/findutils.log 2>>$LOGS/findutils.err
make install 1>>$LOGS/findutils.log 2>>$LOGS/findutils.err
mv -v /usr/bin/find /bin 1>>$LOGS/findutils.log 2>>$LOGS/findutils.err
sed -i 's/find:=${BINDIR}/find:=\/bin/' /usr/bin/updatedb 1>>$LOGS/findutils.log 2>>$LOGS/findutils.err

echo "  [.] gettext"
cd $SRC/gettext
./configure --prefix=/usr \
            --docdir=/usr/share/doc/gettext 1>>$LOGS/gettext.log 2>>$LOGS/gettext.err
make 1>>$LOGS/gettext.log 2>>$LOGS/gettext.err
#make check 1>>$LOGS/gettext.log 2>>$LOGS/gettext.err
make install 1>>$LOGS/gettext.log 2>>$LOGS/gettext.err

echo "  [.] intltool"
cd $SRC/intltool
./configure --prefix=/usr 1>$LOGS/intltool.log 2>$LOGS/intltool.err
make 1>>$LOGS/intltool.log 2>>$LOGS/intltool.err
make install 1>>$LOGS/intltool.log 2>>$LOGS/intltool.err

echo "  [.] gperf"
cd $SRC/gperf
./configure --prefix=/usr 1>$LOGS/gperf.log 2>$LOGS/gperf.err
make 1>>$LOGS/gperf.log 2>>$LOGS/gperf.err
make install 1>>$LOGS/gperf.log 2>>$LOGS/gperf.err

echo "  [.] groff"
cd $SRC/groff
PAGE=A4 ./configure --prefix=/usr 1>>$LOGS/groff.log 2>>$LOGS/groff.err
make 1>>$LOGS/groff.log 2>>$LOGS/groff.err
make docdir=/usr/share/doc/groff install 1>>$LOGS/groff.log 2>>$LOGS/groff.err
ln -sv eqn /usr/bin/geqn
ln -sv tbl /usr/bin/gtbl

echo "  [.] xz"
cd $SRC/xz
./configure --prefix=/usr --disable-static --libdir=/lib --docdir=/usr/share/doc/xz 1>>$LOGS/xz.log 2>>$LOGS/xz.err
make 1>>$LOGS/xz.log 2>>$LOGS/xz.err
#make check 1>>$LOGS/xz.log 2>>$LOGS/xz.err
make install 1>>$LOGS/xz.log 2>>$LOGS/xz.err
mv -v   /usr/bin/{lzma,unlzma,lzcat,xz,unxz,xzcat} /bin 1>>$LOGS/xz.log 2>>$LOGS/xz.err
mv -v /usr/lib/liblzma.so.* /lib 1>>$LOGS/xz.log 2>>$LOGS/xz.err
ln -svf ../../lib/$(readlink /lib/liblzma.so) /usr/lib/liblzma.so 1>>$LOGS/xz.log 2>>$LOGS/xz.err

echo "  [.] less"
cd $SRC/less
./configure --prefix=/usr --sysconfdir=/etc 1>>$LOGS/less.log 2>>$LOGS/less.err
make 1>>$LOGS/less.log 2>>$LOGS/less.err
make install 1>>$LOGS/less.log 2>>$LOGS/less.err

echo "  [.] gzip"
cd $SRC/gzip
./configure --prefix=/usr --bindir=/bin 1>>$LOGS/gzip.log 2>>$LOGS/gzip.err
make 1>>$LOGS/gzip.log 2>>$LOGS/gzip.err
#make check 1>>$LOGS/gzip.log 2>>$LOGS/gzip.err
make install 1>>$LOGS/gzip.log 2>>$LOGS/gzip.err
mv -v /bin/{gzexe,uncompress,zcmp,zdiff,zegrep} /usr/bin
mv -v /bin/{zfgrep,zforce,zgrep,zless,zmore,znew} /usr/bin

echo "  [.] iproute2"
cd $SRC/iproute2
sed -i '/^TARGETS/s@arpd@@g' misc/Makefile
sed -i /ARPD/d Makefile
sed -i 's/arpd.8//' man/man8/Makefile
make DESTDIR=  1>>$LOGS/iproute2.log 2>>$LOGS/iproute2.err
make DESTDIR= SBINDIR=/sbin MANDIR=/usr/share/man \
     DOCDIR=/usr/share/doc/iproute2 install 1>>$LOGS/iproute2.log 2>>$LOGS/iproute2.err

echo "  [.] kbd"
cd $SRC/kbd
patch -Np1 -i ../patches/kbd-2.0.2-backspace-1.patch 1>>$LOGS/kbd.log 2>>$LOGS/kbd.err
sed -i 's/\(RESIZECONS_PROGS=\)yes/\1no/g' configure
sed -i 's/resizecons.8 //' man/man8/Makefile.in
PKG_CONFIG_PATH=$TOOLS/lib/pkgconfig ./configure --prefix=/usr --disable-vlock 1>>$LOGS/kbd.log 2>>$LOGS/kbd.err
make 1>>$LOGS/kbd.log 2>>$LOGS/kbd.err
make install 1>>$LOGS/kbd.log 2>>$LOGS/kbd.err

echo "  [.] kmod"
cd $SRC/kmod
./configure --prefix=/usr       \
            --bindir=/bin       \
            --libdir=/lib       \
            --sysconfdir=/etc   \
            --disable-manpages  \
            --with-xz           \
            --with-zlib 1>>$LOGS/kmod.log 2>>$LOGS/kmod.err
make 1>>$LOGS/kmod.log 2>>$LOGS/kmod.err
make install 1>>$LOGS/kmod.log 2>>$LOGS/kmod.err
for target in depmod insmod modinfo modprobe rmmod; do
  ln -sv ../bin/kmod /sbin/$target
done
ln -sv kmod /bin/lsmod

echo "  [.] libpipeline"
cd $SRC/libpipeline
PKG_CONFIG_PATH=$TOOLS/lib/pkgconfig ./configure --prefix=/usr 1>>$LOGS/libpipeline.log 2>>$LOGS/libpipeline.err
make 1>>$LOGS/libpipeline.log 2>>$LOGS/libpipeline.err
make install 1>>$LOGS/libpipeline.log 2>>$LOGS/libpipeline.err

echo "  [.] make"
cd $SRC/make
./configure --prefix=/usr 1>>$LOGS/make.log 2>>$LOGS/make.err
make 1>>$LOGS/make.log 2>>$LOGS/make.err
#make check 1>>$LOGS/make.log 2>>$LOGS/make.err
make install 1>>$LOGS/make.log 2>>$LOGS/make.err

echo "  [.] patch "
cd $SRC/patch
./configure --prefix=/usr 1>>$LOGS/patch.log 2>>$LOGS/patch.err
make 1>>$LOGS/patch.log 2>>$LOGS/patch.err
make install 1>>$LOGS/patch.log 2>>$LOGS/patch.err

echo "  [.] sysklogd"
cd $SRC/sysklogd
sed -i '/Error loading kernel symbols/{n;n;d}' ksym_mod.c 1>>$LOGS/sysklogd.log 2>>$LOGS/sysklogd.err
make 1>>$LOGS/sysklogd.log 2>>$LOGS/sysklogd.err
make BINDIR=/sbin install 1>>$LOGS/sysklogd.log 2>>$LOGS/sysklogd.err
cat > /etc/syslog.conf << "EOF"
# Begin /etc/syslog.conf

auth,authpriv.* -/var/log/auth.log
*.*;auth,authpriv.none -/var/log/sys.log
daemon.* -/var/log/daemon.log
kern.* -/var/log/kern.log
mail.* -/var/log/mail.log
user.* -/var/log/user.log
*.emerg *

# End /etc/syslog.conf
EOF

echo "  [.] tar"
cd $SRC/tar
FORCE_UNSAFE_CONFIGURE=1 ./configure --prefix=/usr --bindir=/bin --libexecdir=/usr/sbin 1>>$LOGS/tar.log 2>>$LOGS/tar.err
make 1>>$LOGS/tar.log 2>>$LOGS/tar.err
make check 1>>$LOGS/tar.log 2>>$LOGS/tar.err
make install 1>>$LOGS/tar.log 2>>$LOGS/tar.err

echo "  [.] texinfo"
cd $SRC/texinfo
./configure --prefix=/usr 1>>$LOGS/texinfo.log 2>>$LOGS/texinfo.err
make 1>>$LOGS/texinfo.log 2>>$LOGS/texinfo.err
#make check 1>>$LOGS/texinfo.log 2>>$LOGS/texinfo.err
make install 1>>$LOGS/texinfo.log 2>>$LOGS/texinfo.err
make TEXMF=/usr/share/texmf install-tex 1>>$LOGS/texinfo.log 2>>$LOGS/texinfo.err
cd /usr/share/info
rm -v dir
for f in *
do install-info $f dir 2>/dev/null
done

echo "  [.] eudev"
cd $SRC/eudev
sed -r -i 's|/usr(/bin/test)|\1|' test/udev-test.pl 1>$LOGS/eudev.log 2>$LOGS/eudev.err

cat > config.cache << "EOF"
HAVE_BLKID=1
BLKID_LIBS="-lblkid"
BLKID_CFLAGS="-I/tools/include"
EOF

./configure --prefix=/usr           \
            --bindir=/sbin          \
            --sbindir=/sbin         \
            --libdir=/usr/lib       \
            --sysconfdir=/etc       \
            --libexecdir=/lib       \
            --with-rootprefix=      \
            --with-rootlibdir=/lib  \
            --enable-split-usr      \
            --enable-manpages       \
            --enable-hwdb           \
            --disable-introspection \
            --disable-gudev         \
            --disable-static        \
            --config-cache          \
            --disable-gtk-doc-html 1>>$LOGS/eudev.log 2>>$LOGS/eudev.err
LIBRARY_PATH=$TOOLS/lib make 1>>$LOGS/eudev.log 2>>$LOGS/eudev.err
mkdir -pv /lib/udev/rules.d 1>>$LOGS/eudev.log 2>>$LOGS/eudev.err
mkdir -pv /etc/udev/rules.d 1>>$LOGS/eudev.log 2>>$LOGS/eudev.err
make LD_LIBRARY_PATH=$TOOLS/lib install 1>>$LOGS/eudev.log 2>>$LOGS/eudev.err
cp -a $SRC/udev udev-lfs-20140408 1>>$LOGS/eudev.log 2>>$LOGS/eudev.err
make -f udev-lfs-20140408/Makefile.lfs install 1>>$LOGS/eudev.log 2>>$LOGS/eudev.err
LD_LIBRARY_PATH=$TOOLS/lib udevadm hwdb --update 1>>$LOGS/eudev.log 2>>$LOGS/eudev.err

echo "  [.] util-linux "
cd $SRC/util-linux
mkdir -pv /var/lib/hwclock
./configure ADJTIME_PATH=/var/lib/hwclock/adjtime     \
            --docdir=/usr/share/doc/util-linux-2.26 \
            --disable-chfn-chsh  \
            --disable-login      \
            --disable-nologin    \
            --disable-su         \
            --disable-setpriv    \
            --disable-runuser    \
            --disable-pylibmount \
            --disable-static     \
            --without-python     \
            --without-systemd    \
            --without-systemdsystemunitdir 1>$LOGS/util-linux.log 2>$LOGS/util-linux.err
make 1>>$LOGS/util-linux.log 2>>$LOGS/util-linux.err
make install 1>>$LOGS/util-linux.log 2>>$LOGS/util-linux.err

echo "  [.] man-db"
cd $SRC/man-db
./configure --prefix=/usr --libexecdir=/usr/lib \
    --docdir=/usr/share/doc/man-db-2.7.1 \
    --sysconfdir=/etc --disable-setuid \
    --with-browser=/usr/bin/lynx --with-vgrind=/usr/bin/vgrind \
    --with-grap=/usr/bin/grap 1>>$LOGS/mandb.log 2>>$LOGS/mandb.err

make 1>>$LOGS/mandb.log 2>>$LOGS/mandb.err
#make check 1>>$LOGS/mandb.log 2>>$LOGS/mandb.err
make install 1>>$LOGS/mandb.log 2>>$LOGS/mandb.err

exit

