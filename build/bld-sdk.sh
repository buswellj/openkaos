#
# Open Kernel Attached Operating System (OpenKaOS)
# Platform Build System version 5.0.0
#
# Copyright (c) 2009-2016 Opaque Systems, LLC 
#
# script : bld-sdk.sh
# purpose: sdk build script 1 of 3, creates SDK chroot from toolchain
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
mkdir -p $LOGS
cd /

echo "  [*] Building SDK: stage 1 of 3..."
echo ""
echo "  [.] creating directory structure"
mkdir -pv /{bin,boot,etc/{opt,sysconfig},home,lib/firmware,mnt,opt}
mkdir -pv /{media/{floppy,cdrom},sbin,srv,var}
install -dv -m 0750 /root
install -dv -m 1777 /tmp /var/tmp
mkdir -pv /usr/{,local/}{bin,include,lib,sbin,src}
mkdir -pv /usr/{,local/}share/{color,dict,doc,info,locale,man}
mkdir -v  /usr/{,local/}share/{misc,terminfo,zoneinfo}
mkdir -v  /usr/libexec
mkdir -pv /usr/{,local/}share/man/man{1..8}
case $(uname -m) in
 x86_64) ln -sv lib /lib64 && ln -sv lib /usr/lib64 && ln -sv lib /usr/local/lib64 ;;
esac
mkdir -v /var/{log,mail,spool}
ln -sv /run /var/run
ln -sv /run/lock /var/lock
mkdir -pv /var/{opt,cache,lib/{color,misc,locate},local}

echo ""
echo "  [.] Initial File Setup"
echo ""

ln -sv $TOOLS/bin/{bash,cat,echo,pwd,stty} /bin
ln -sv $TOOLS/bin/perl /usr/bin
ln -sv $TOOLS/lib/libgcc_s.so{,.1} /usr/lib
ln -sv $TOOLS/lib/libstdc++.so{,.6} /usr/lib
echo "sed 's/\\$TOOLS/\/usr/' $TOOLS/lib/libstdc++.la > /usr/lib/libstdc++.la" > $SRC/swapstdc.sh
chmod 755 $SRC/swapstdc.sh
$SRC/swapstdc.sh
ln -sv bash /bin/sh
ln -sv /proc/self/mounts /etc/mtab
cat > /etc/passwd << "EOF"
root:x:0:0:root:/root:/bin/bash
bin:x:1:1:bin:/dev/null:/bin/false
daemon:x:6:6:Daemon User:/dev/null:/bin/false
messagebus:x:18:18:D-Bus Message Daemon User:/var/run/dbus:/bin/false
nobody:x:99:99:Unprivileged User:/dev/null:/bin/false
EOF

cat > /etc/group << "EOF"
root:x:0:
bin:x:1:
sys:x:2:
kmem:x:3:
tape:x:4:
tty:x:5:
daemon:x:6:
floppy:x:7:
disk:x:8:
lp:x:9:
dialout:x:10:
audio:x:11:
video:x:12:
utmp:x:13:
usb:x:14:
cdrom:x:15:
adm:x:16:
messagebus:x:18:
systemd-journal:x:23:
input:x:24:
mail:x:34:
nogroup:x:99:
docker:x:100:
users:x:1000:
EOF

touch /var/run/utmp /var/log/{btmp,lastlog,wtmp}
chgrp -v utmp /var/run/utmp /var/log/lastlog
chmod -v 664 /var/run/utmp /var/log/lastlog
chmod -v 600  /var/log/btmp


#
# These use the public Google nameservers by default (8.8.x.x)
# Added OpenDNS public nameservers (208.67.x.x)
#
cat > /etc/resolv.conf << "EOF"
nameserver 8.8.8.8
nameserver 8.8.4.4
nameserver 208.67.222.222
nameserver 208.67.220.220
EOF

echo "  [.] Linux API Headers"
cd $SRC/linux
make mrproper 1>>$LOGS/linux.log 2>>$LOGS/linux.err
make INSTALL_HDR_PATH=dest headers_install 1>>$LOGS/linux.log 2>>$LOGS/linux.err
find dest/include \( -name .install -o -name ..install.cmd \) -delete 1>>$LOGS/linux.log 2>>$LOGS/linux.err
cp -rv dest/include/* /usr/include 1>>$LOGS/linux.log 2>>$LOGS/linux.err

echo "  [.] Man pages"
cd $SRC/man-pages
make install 1>>$LOGS/man-pages.log 2>>$LOGS/man-pages.err

echo "  [.] glibc "
cd $SRC/glibc
patch -Np1 -i ../patches/glibc-2.23-fhs-1.patch 1>>$LOGS/glibc.log 2>>$LOGS/glibc.err

mkdir -v ../glibc-build
cd ../glibc-build
../glibc/configure --prefix=/usr \
    --disable-profile \
    --enable-kernel=2.6.32 --enable-obsolete-rpc  1>>$LOGS/glibc.log 2>>$LOGS/glibc.err
make 1>>$LOGS/glibc.log 2>>$LOGS/glibc.err
#make -k check 2>&1 | tee glibc-check-log
#grep Error glibc-check-log 1>>$LOGS/glibc.log 2>>$LOGS/glibc.err

touch /etc/ld.so.conf
make install 1>>$LOGS/glibc.log 2>>$LOGS/glibc.err
# install NIS and RPC related headers - needed to rebuild glibc
cp -v ../glibc/nscd/nscd.conf /etc/nscd.conf
mkdir -pv /var/cache/nscd
make localedata/install-locales 1>>$LOGS/glibc.log 2>>$LOGS/glibc.err

cat > /etc/nsswitch.conf << "EOF"
# Begin /etc/nsswitch.conf
passwd: files
group: files
shadow: files

hosts: files dns
networks: files

protocols: files
services: files
ethers: files
rpc: files
# End /etc/nsswitch.conf
EOF

# TimeZone setup

cd $SRC/tzdata
ZONEINFO=/usr/share/zoneinfo
mkdir -pv $ZONEINFO/{posix,right}

for tz in etcetera southamerica northamerica europe africa antarctica  \
          asia australasia backward pacificnew \
          systemv; do
    zic -L /dev/null   -d $ZONEINFO       -y "sh yearistype.sh" ${tz}
    zic -L /dev/null   -d $ZONEINFO/posix -y "sh yearistype.sh" ${tz}
    zic -L leapseconds -d $ZONEINFO/right -y "sh yearistype.sh" ${tz}
done

cp -v zone.tab zone1970.tab iso3166.tab $ZONEINFO
zic -d $ZONEINFO -p America/New_York
unset ZONEINFO

cp -v --remove-destination /usr/share/zoneinfo/UTC /etc/localtime

cat > /etc/ld.so.conf << "EOF"
# Begin /etc/ld.so.conf
/usr/local/lib
/opt/lib

# End /etc/ld.so.conf
EOF

cat >> /etc/ld.so.conf << "EOF"
# Add an include directory
include /etc/ld.so.conf.d/*.conf

EOF
mkdir /etc/ld.so.conf.d

echo "  [.] Adjusting Toolchain"
cd $SRC/
#mv -v $TOOLS/bin/{ld,ld-old}
#mv -v $TOOLS/$(gcc -dumpmachine)/bin/{ld,ld-old}
#mv -v $TOOLS/bin/{ld-new,ld}
#ln -sv $TOOLS/bin/ld $TOOLS/$(gcc -dumpmachine)/bin/ld

mv -v $TOOLS/bin/{ld,ld-old}
mv -v $TOOLS/$(uname -m)-pc-linux-gnu/bin/{ld,ld-old}
mv -v $TOOLS/bin/{ld-new,ld}
ln -sv $TOOLS/bin/ld /tools/$(uname -m)-pc-linux-gnu/bin/ld

echo "#!/bin/bash" > chroot-adj3.sh
echo "gcc -dumpspecs | sed -e 's@$TOOLS@@g' \\" >> chroot-adj3.sh
echo "    -e '/\\*startfile_prefix_spec:/{n;s@.*@/usr/lib/ @}' \\" >> chroot-adj3.sh
echo "    -e '/\\*cpp:/{n;s@\$@ -isystem /usr/include@}' > \\" >> chroot-adj3.sh
echo "    \`dirname \$(gcc --print-libgcc-file-name)\`/specs " >> chroot-adj3.sh

chmod 755 chroot-adj3.sh
./chroot-adj3.sh

echo 'main(){}' > dummy.c
cc dummy.c -v -Wl,--verbose &> dummy.log
readelf -l a.out | grep ': /lib' 1>$LOGS/inspection-chroot-adj3.log 2>$LOGS/inspection-chroot-adj3.err

grep -o '/usr/lib.*/crt[1in].*succeeded' dummy.log 1>>$LOGS/inspection-chroot-adj3.log 2>>$LOGS/inspection-chroot-adj3.err
grep -B1 '^ /usr/include' dummy.log 1>>$LOGS/inspection-chroot-adj3.log 2>>$LOGS/inspection-chroot-adj3.err
grep 'SEARCH.*/usr/lib' dummy.log |sed 's|; |\n|g' 1>>$LOGS/inspection-chroot-adj3.log 2>>$LOGS/inspection-chroot-adj3.err
grep "/lib.*/libc.so.6 " dummy.log 1>>$LOGS/inspection-chroot-adj3.log 2>>$LOGS/inspection-chroot-adj3.err
grep found dummy.log 1>>$LOGS/inspection-chroot-adj3.log 2>>$LOGS/inspection-chroot-adj3.err

echo "  [.] zlib"
cd $SRC/zlib
./configure --prefix=/usr 1>>$LOGS/zlib.log 2>>$LOGS/zlib.err
make 1>>$LOGS/zlib.log 2>>$LOGS/zlib.err
make check 1>>$LOGS/zlib.log 2>>$LOGS/zlib.err
make install 1>>$LOGS/zlib.log 2>>$LOGS/zlib.err
mv -v /usr/lib/libz.so.* /lib
ln -sfv ../../lib/$(readlink /usr/lib/libz.so) /usr/lib/libz.so

echo "  [.] file"
cd $SRC/file
./configure --prefix=/usr 1>>$LOGS/file.log 2>>$LOGS/file.err
make 1>>$LOGS/file.log 2>>$LOGS/file.err
make check 1>>$LOGS/file.log 2>>$LOGS/file.err
make install 1>>$LOGS/file.log 2>>$LOGS/file.err

echo "  [.] binutils"
cd $SRC/binutils
expect -c "spawn ls" 1>>$LOGS/binutils.log 2>>$LOGS/binutils.err
patch -Np1 -i ../patches/binutils-2.26-upstream_fix-2.patch 1>>$LOGS/binutils.log 2>>$LOGS/binutils.err
mkdir -v ../binutils-build
cd ../binutils-build
../binutils/configure --prefix=/usr --enable-shared --disable-werror --enable-plugins 1>>$LOGS/binutils.log 2>>$LOGS/binutils.err
make tooldir=/usr 1>>$LOGS/binutils.log 2>>$LOGS/binutils.err
make check 1>>$LOGS/binutils.log 2>>$LOGS/binutils.err
make tooldir=/usr install 1>>$LOGS/binutils.log 2>>$LOGS/binutils.err

echo "  [.] gmp"
cd $SRC/gmp
###
### Note to compile 32-bit on 64-bit add ABI=32 prefix to this configure command
###
./configure --prefix=/usr --enable-cxx --disable-static 1>>$LOGS/gmp.log 2>>$LOGS/gmp.err
make 1>>$LOGS/gmp.log 2>>$LOGS/gmp.err
make check 2>&1 | tee gmp-check-logmake check 2>&1 | tee gmp-check-log 1>>$LOGS/gmp.log 2>>$LOGS/gmp.err
awk '/tests passed/{total+=$2} ; END{print total}' gmp-check-log 1>>$LOGS/gmp.log 2>>$LOGS/gmp.err
make install 1>>$LOGS/gmp.log 2>>$LOGS/gmp.err

echo "  [.] mpfr"
cd $SRC/mpfr
patch -Np1 -i ../patches/mpfr-3.1.3-upstream_fixes-2.patch 1>>$LOGS/mpfr.log 2>>$LOGS/mpfr.err
./configure --prefix=/usr --disable-static --enable-thread-safe --docdir=/usr/share/doc/mpfr 1>>$LOGS/mpfr.log 2>>$LOGS/mpfr.err
make 1>>$LOGS/mpfr.log 2>>$LOGS/mpfr.err
make check 1>>$LOGS/mpfr.log 2>>$LOGS/mpfr.err
make install 1>>$LOGS/mpfr.log 2>>$LOGS/mpfr.err

echo "  [.] mpc"
cd $SRC/mpc
./configure --prefix=/usr --disable-static 1>>$LOGS/mpc.log 2>>$LOGS/mpc.err
make 1>>$LOGS/mpc.log 2>>$LOGS/mpc.err
make check 1>>$LOGS/mpc.log 2>>$LOGS/mpc.err
make install 1>>$LOGS/mpc.log 2>>$LOGS/mpc.err

echo "  [.] gcc"
cd $SRC/gcc
mv gmp kaos_magic.gmp
mv mpc kaos_magic.mpc
mv mpfr kaos_magic.mpfr
mkdir -v ../gcc-build
cd ../gcc-build
SED=sed ../gcc/configure --prefix=/usr \
    --libexecdir=/usr/lib --enable-shared \
    --enable-languages=c,c++ \
    --disable-multilib --disable-bootstrap --with-system-zlib 1>>$LOGS/gcc.log 2>>$LOGS/gcc.err
make 1>>$LOGS/gcc.log 2>>$LOGS/gcc.err
ulimit -s 32768
#make -k check 1>>$LOGS/gcc.log 2>>$LOGS/gcc.err
#../gcc/contrib/test_summary 1>>$LOGS/gcc.log 2>>$LOGS/gcc.err
make install 1>>$LOGS/gcc.log 2>>$LOGS/gcc.err
ln -sv ../usr/bin/cpp /lib
ln -sv gcc /usr/bin/cc
install -v -dm755 /usr/lib/bfd-plugins
ln -sfv ../../libexec/gcc/$(gcc -dumpmachine)/5.3.0/liblto_plugin.so /usr/lib/bfd-plugins/
echo 'main(){}' > dummy.c
cc dummy.c -v -Wl,--verbose &> dummy.log
readelf -l a.out | grep ': /lib' 1>>$LOGS/gcc.log 2>>$LOGS/gcc.err
grep -o '/usr/lib.*/crt[1in].*succeeded' dummy.log 1>>$LOGS/gcc.log 2>>$LOGS/gcc.err
grep -B4 '^ /usr/include' dummy.log 1>>$LOGS/gcc.log 2>>$LOGS/gcc.err
grep 'SEARCH.*/usr/lib' dummy.log |sed 's|; |\n|g' 1>>$LOGS/gcc.log 2>>$LOGS/gcc.err
grep "/lib.*/libc.so.6 " dummy.log 1>>$LOGS/gcc.log 2>>$LOGS/gcc.err
grep found dummy.log 1>>$LOGS/gcc.log 2>>$LOGS/gcc.err
mkdir -pv /usr/share/gdb/auto-load/usr/lib
mv -v /usr/lib/*gdb.py /usr/share/gdb/auto-load/usr/lib

echo "  [.] bzip2"
cd $SRC/bzip2
patch -Np1 -i ../patches/bzip2-1.0.6-install_docs-1.patch 1>>$LOGS/bzip2.log 2>>$LOGS/bzip2.err
sed -i 's@\(ln -s -f \)$(PREFIX)/bin/@\1@' Makefile
sed -i "s@(PREFIX)/man@(PREFIX)/share/man@g" Makefile
make -f Makefile-libbz2_so 1>>$LOGS/bzip2.log 2>>$LOGS/bzip2.err
make clean 1>>$LOGS/bzip2.log 2>>$LOGS/bzip2.err
make 1>>$LOGS/bzip2.log 2>>$LOGS/bzip2.err
make PREFIX=/usr install 1>>$LOGS/bzip2.log 2>>$LOGS/bzip2.err 1>>$LOGS/bzip2.log 2>>$LOGS/bzip2.err
cp -v bzip2-shared /bin/bzip2 1>>$LOGS/bzip2.log 2>>$LOGS/bzip2.err
cp -av libbz2.so* /lib 1>>$LOGS/bzip2.log 2>>$LOGS/bzip2.err
ln -sv ../../lib/libbz2.so.1.0 /usr/lib/libbz2.so 1>>$LOGS/bzip2.log 2>>$LOGS/bzip2.err
rm -v /usr/bin/{bunzip2,bzcat,bzip2} 1>>$LOGS/bzip2.log 2>>$LOGS/bzip2.err
ln -sv bzip2 /bin/bunzip2 1>>$LOGS/bzip2.log 2>>$LOGS/bzip2.err
ln -sv bzip2 /bin/bzcat 1>>$LOGS/bzip2.log 2>>$LOGS/bzip2.err

echo "  [.] pcre "
cd $SRC/pcre
./configure --prefix=/usr \
            --docdir=/usr/share/doc/pcre \
            --enable-utf8 \
            --enable-unicode-properties \
            --enable-pcregrep-libz \
            --enable-pcregrep-libbz2 1>>$LOGS/pcre.log 2>>$LOGS/pcre.err
make 1>>$LOGS/pcre.log 2>>$LOGS/pcre.err
make install 1>>$LOGS/pcre.log 2>>$LOGS/pcre.err
mv -v /usr/lib/libpcre.so.* /lib/ 1>>$LOGS/pcre.log 2>>$LOGS/pcre.err
ln -v -sf ../../lib/libpcre.so.0 /usr/lib/libpcre.so 1>>$LOGS/pcre.log 2>>$LOGS/pcre.err

echo "  [.] glib "
cd $SRC/glib
PCRE_LIBS="-L/usr/lib -lpcre" PCRE_CFLAGS="-I/usr/include" ./configure --prefix=/usr --sysconfdir=/etc --with-pcre=system 1>>$LOGS/glib.log 2>>$LOGS/glib.err
make 1>>$LOGS/glib.log 2>>$LOGS/glib.err
make install 1>>$LOGS/glib.log 2>>$LOGS/glib.err

echo "  [.] pkg-config "
cd $SRC/pkg-config
./configure --prefix=/usr --with-internal-glib --disable-host-tool --docdir=/usr/share/doc/pkg-config 1>>$LOGS/pkg-config.log 2>>$LOGS/pkg-config.err
make 1>>$LOGS/pkg-config.log 2>>$LOGS/pkg-config.err
make check 1>>$LOGS/pkg-config.log 2>>$LOGS/pkg-config.err
make install 1>>$LOGS/pkg-config.log 2>>$LOGS/pkg-config.err

echo "  [.] ncurses "
cd $SRC/ncurses
sed -i '/LIBTOOL_INSTALL/d' c++/Makefile.in
./configure --prefix=/usr --with-shared --without-debug --without-normal --enable-pc-files --enable-widec --mandir=/usr/share/man 1>>$LOGS/ncurses.log 2>>$LOGS/ncurses.err
make 1>>$LOGS/ncurses.log 2>>$LOGS/ncurses.err
make install 1>>$LOGS/ncurses.log 2>>$LOGS/ncurses.err
mv -v /usr/lib/libncursesw.so.6* /lib 1>>$LOGS/ncurses.log 2>>$LOGS/ncurses.err
ln -sfv ../../lib/$(readlink /usr/lib/libncursesw.so) /usr/lib/libncursesw.so 1>>$LOGS/ncurses.log 2>>$LOGS/ncurses.err
for lib in ncurses form panel menu ; do \
    rm -vf /usr/lib/lib${lib}.so ; \
    echo "INPUT(-l${lib}w)" > /usr/lib/lib${lib}.so ; \
    ln -sfv ${lib}w.pc /usr/lib/pkgconfig/${lib}.pc
done
rm -vf /usr/lib/libcursesw.so 1>>$LOGS/ncurses.log 2>>$LOGS/ncurses.err
echo "INPUT(-lncursesw)" >/usr/lib/libcursesw.so
ln -sfv libncurses.so /usr/lib/libcurses.so 1>>$LOGS/ncurses.log 2>>$LOGS/ncurses.err

echo "  [.] cracklib"
cd $SRC/cracklib
./configure --prefix=/usr \
            --with-default-dict=/lib/cracklib/pw_dict 1>>$LOGS/cracklib.log 2>>$LOGS/cracklib.err
make 1>>$LOGS/cracklib.log 2>>$LOGS/cracklib.err
make install 1>>$LOGS/cracklib.log 2>>$LOGS/cracklib.err
mv -v /usr/lib/libcrack.so.2* /lib 1>>$LOGS/cracklib.log 2>>$LOGS/cracklib.err
ln -v -sf ../../lib/libcrack.so.2.9.1 /usr/lib/libcrack.so 1>>$LOGS/cracklib.log 2>>$LOGS/cracklib.err
install -v -m644 -D ./cracklib-words-2.9.6.gz \
    /usr/share/dict/cracklib-words.gz 1>>$LOGS/cracklib.log 2>>$LOGS/cracklib.err
gunzip -v /usr/share/dict/cracklib-words.gz 1>>$LOGS/cracklib.log 2>>$LOGS/cracklib.err
ln -v -s cracklib-words /usr/share/dict/words 1>>$LOGS/cracklib.log 2>>$LOGS/cracklib.err
echo $(hostname) >>/usr/share/dict/cracklib-extra-words 1>>$LOGS/cracklib.log 2>>$LOGS/cracklib.err
install -v -m755 -d /lib/cracklib 1>>$LOGS/cracklib.log 2>>$LOGS/cracklib.err
create-cracklib-dict /usr/share/dict/cracklib-words \
                     /usr/share/dict/cracklib-extra-words 1>>$LOGS/cracklib.log 2>>$LOGS/cracklib.err
make test 1>>$LOGS/cracklib.log 2>>$LOGS/cracklib.err

echo "  [.] attr "
cd $SRC/attr
sed -i -e 's|/@pkg_name@|&-@pkg_version@|' include/builddefs.in
sed -i -e "/SUBDIRS/s|man2||" man/Makefile
./configure --prefix=/usr --bindir=/bin --disable-static 1>>$LOGS/attr.log 2>>$LOGS/attr.err
make  1>>$LOGS/attr.log 2>>$LOGS/attr.err
make install install-dev install-lib  1>>$LOGS/attr.log 2>>$LOGS/attr.err
chmod -v 755 /usr/lib/libattr.so  1>>$LOGS/attr.log 2>>$LOGS/attr.err
mv -v /usr/lib/libattr.so.* /lib 1>>$LOGS/attr.log 2>>$LOGS/attr.err
ln -sfv ../../lib/$(readlink /usr/lib/libattr.so) /usr/lib/libattr.so 1>>$LOGS/attr.log 2>>$LOGS/attr.err

echo "  [.] acl "
cd $SRC/acl
sed -i -e 's|/@pkg_name@|&-@pkg_version@|' include/builddefs.in
sed -i "s:| sed.*::g" test/{sbits-restore,cp,misc}.test
sed -i -e "/TABS-1;/a if (x > (TABS-1)) x = (TABS-1);" \
    libacl/__acl_to_any_text.c
./configure --prefix=/usr \
            --bindir=/bin --disable-static \
            --libexecdir=/usr/lib 1>>$LOGS/acl.log 2>>$LOGS/acl.err
make 1>>$LOGS/acl.log 2>>$LOGS/acl.err
make install install-dev install-lib 1>>$LOGS/acl.log 2>>$LOGS/acl.err
chmod -v 755 /usr/lib/libacl.so 1>>$LOGS/acl.log 2>>$LOGS/acl.err
mv -v /usr/lib/libacl.so.* /lib 1>>$LOGS/acl.log 2>>$LOGS/acl.err
ln -sfv ../../lib/$(readlink /usr/lib/libacl.so) /usr/lib/libacl.so 1>>$LOGS/acl.log 2>>$LOGS/acl.err

echo "  [.] libcap "
cd $SRC/libcap
sed -i '/install.*STALIBNAME/d' libcap/Makefile
make 1>>$LOGS/libcap.log 2>>$LOGS/libcap.err
make RAISE_SETFCAP=no prefix=/usr install 1>>$LOGS/libcap.log 2>>$LOGS/libcap.err
chmod -v 755 /usr/lib/libcap.so 1>>$LOGS/libcap.log 2>>$LOGS/libcap.err
mv -v /usr/lib/libcap.so.* /lib 1>>$LOGS/libcap.log 2>>$LOGS/libcap.err
ln -sfv ../../lib/$(readlink /usr/lib/libcap.so) /usr/lib/libcap.so 1>>$LOGS/libcap.log 2>>$LOGS/libcap.err

echo "  [.] sed "
cd $SRC/sed
./configure --prefix=/usr --bindir=/bin --htmldir=/usr/share/doc/sed-4.2.2 1>>$LOGS/sed.log 2>>$LOGS/sed.err
make 1>>$LOGS/sed.log 2>>$LOGS/sed.err1>>$LOGS/sed.log 2>>$LOGS/sed.err
make html 1>>$LOGS/sed.log 2>>$LOGS/sed.err
make check 1>>$LOGS/sed.log 2>>$LOGS/sed.err
make install 1>>$LOGS/sed.log 2>>$LOGS/sed.err

echo "  [.] shadow"
cd $SRC/shadow
sed -i 's/groups$(EXEEXT) //' src/Makefile.in
find man -name Makefile.in -exec sed -i 's/groups\.1 / /' {} \;
sed -i -e 's@#ENCRYPT_METHOD DES@ENCRYPT_METHOD SHA512@' \
       -e 's@/var/spool/mail@/var/mail@' etc/login.defs
sed -i 's@DICTPATH.*@DICTPATH\t/lib/cracklib/pw_dict@' \
    etc/login.defs
./configure --sysconfdir=/etc --with-libcrack --with-group-name-max-length=32 1>>$LOGS/shadow.log 2>>$LOGS/shadow.err
make 1>>$LOGS/shadow.log 2>>$LOGS/shadow.err
make install 1>>$LOGS/shadow.log 2>>$LOGS/shadow.err
mv -v /usr/bin/passwd /bin
sed -i 's/yes/no/' /etc/default/useradd 1>>$LOGS/shadow.log 2>>$LOGS/shadow.err

pwconv 1>>$LOGS/shadow.log 2>>$LOGS/shadow.err
grpconv 1>>$LOGS/shadow.log 2>>$LOGS/shadow.err

echo "  [.] psmisc "
cd $SRC/psmisc
./configure --prefix=/usr 1>>$LOGS/psmisc.log 2>>$LOGS/psmisc.err
make 1>>$LOGS/psmisc.log 2>>$LOGS/psmisc.err
make install 1>>$LOGS/psmisc.log 2>>$LOGS/psmisc.err
mv -v /usr/bin/fuser /bin 1>>$LOGS/psmisc.log 2>>$LOGS/psmisc.err
mv -v /usr/bin/killall /bin 1>>$LOGS/psmisc.log 2>>$LOGS/psmisc.err

echo "  [.] procps "
cd $SRC/procps
./configure --prefix=/usr                           \
            --exec-prefix=                          \
            --libdir=/usr/lib                       \
            --docdir=/usr/share/doc/procps-ng-3.3.11 \
            --disable-static                        \
            --disable-kill 1>>$LOGS/procps.log 2>>$LOGS/procps.err
make 1>>$LOGS/procps.log 2>>$LOGS/procps.err
make install 1>>$LOGS/procps.log 2>>$LOGS/procps.err
#mv -v /usr/bin/pidof /bin
mv -v /usr/lib/libprocps.so.* /lib
ln -sfv ../../lib/$(readlink /usr/lib/libprocps.so) /usr/lib/libprocps.so

echo "  [.] e2fsprogs "
cd $SRC/e2fsprogs
mkdir -v build
cd build
LIBS=-L$TOOLS/lib \
CFLAGS=-I$TOOLS/include \
PKG_CONFIG_PATH=$TOOLS/lib/pkgconfig \
../configure --prefix=/usr --with-root-prefix="" --bindir=/bin \
    --enable-elf-shlibs --disable-libblkid --disable-libuuid \
    --disable-uuidd --disable-fsck 1>>$LOGS/e2fsprogs.log 2>>$LOGS/e2fsprogs.err
make 1>>$LOGS/e2fsprogs.log 2>>$LOGS/e2fsprogs.err
make install 1>>$LOGS/e2fsprogs.log 2>>$LOGS/e2fsprogs.err
make install-libs 1>>$LOGS/e2fsprogs.log 2>>$LOGS/e2fsprogs.err
chmod -v u+w /usr/lib/{libcom_err,libe2p,libext2fs,libss}.a 1>>$LOGS/e2fsprogs.log 2>>$LOGS/e2fsprogs.err
gunzip -v /usr/share/info/libext2fs.info.gz 1>>$LOGS/e2fsprogs.log 2>>$LOGS/e2fsprogs.err
install-info --dir-file=/usr/share/info/dir \
             /usr/share/info/libext2fs.info 1>>$LOGS/e2fsprogs.log 2>>$LOGS/e2fsprogs.err

echo "  [.] iana-etc "
cd $SRC/iana-etc
make 1>>$LOGS/iana-etc.log 2>>$LOGS/iana-etc.err
make install 1>>$LOGS/iana-etc.log 2>>$LOGS/iana-etc.err

echo "  [.] m4 "
cd $SRC/m4
./configure --prefix=/usr 1>>$LOGS/m4.log 2>>$LOGS/m4.err
make 1>>$LOGS/m4.log 2>>$LOGS/m4.err
make check 1>>$LOGS/m4.log 2>>$LOGS/m4.err
make install 1>>$LOGS/m4.log 2>>$LOGS/m4.err

echo "  [.] bison "
cd $SRC/bison
./configure --prefix=/usr 1>>$LOGS/bison.log 2>>$LOGS/bison.err
make 1>>$LOGS/bison.log 2>>$LOGS/bison.err
make check 1>>$LOGS/bison.log 2>>$LOGS/bison.err
make install 1>>$LOGS/bison.log 2>>$LOGS/bison.err

echo "  [.] flex"
cd $SRC/flex
./configure --prefix=/usr --disable-static --docdir=/usr/share/doc/flex 1>>$LOGS/flex.log 2>>$LOGS/flex.err
make 1>>$LOGS/flex.log 2>>$LOGS/flex.err
make check 1>>$LOGS/flex.log 2>>$LOGS/flex.err
make install 1>>$LOGS/flex.log 2>>$LOGS/flex.err
ln -sv flex /usr/bin/lex

echo "  [.] grep "
cd $SRC/grep
./configure --prefix=/usr \
    --bindir=/bin 1>>$LOGS/grep.log 2>>$LOGS/grep.err
make 1>>$LOGS/grep.log 2>>$LOGS/grep.err
make check 1>>$LOGS/grep.log 2>>$LOGS/grep.err
make install 1>>$LOGS/grep.log 2>>$LOGS/grep.err

echo "  [.] readline "
cd $SRC/readline
patch -Np1 -i ../patches/readline-6.3-upstream_fixes-3.patch 1>>$LOGS/readline.log 2>>$LOGS/readline.err
sed -i '/MV.*old/d' Makefile.in
sed -i '/{OLDSUFF}/c:' support/shlib-install
./configure --prefix=/usr --disable-static 1>>$LOGS/readline.log 2>>$LOGS/readline.err
make SHLIB_LIBS=-lncurses 1>>$LOGS/readline.log 2>>$LOGS/readline.err
make SHLIB_LIBS=-lncurses install 1>>$LOGS/readline.log 2>>$LOGS/readline.err
mv -v /usr/lib/lib{readline,history}.so.* /lib 1>>$LOGS/readline.log 2>>$LOGS/readline.err
ln -sfv ../../lib/$(readlink /usr/lib/libreadline.so) /usr/lib/libreadline.so 1>>$LOGS/readline.log 2>>$LOGS/readline.err
ln -sfv ../../lib/$(readlink /usr/lib/libhistory.so ) /usr/lib/libhistory.so 1>>$LOGS/readline.log 2>>$LOGS/readline.err

echo "  [.] binutils-gold"
cd $SRC/binutils
expect -c "spawn ls" 1>>$LOGS/binutils-gold.log 2>>$LOGS/binutils-gold.err
#patch -Np1 -i ../patches/binutils-2.26-upstream_fix-2.patch 1>>$LOGS/binutils-gold.log 2>>$LOGS/binutils-gold.err
mkdir -v ../binutils-build2
cd ../binutils-build2
../binutils/configure --prefix=/usr --enable-shared --disable-werror \
 --enable-gold=yes --enable-ld=default --enable-plugins 1>>$LOGS/binutils-gold.log 2>>$LOGS/binutils-gold.err
make tooldir=/usr 1>>$LOGS/binutils-gold.log 2>>$LOGS/binutils-gold.err
make check 1>>$LOGS/binutils-gold.log 2>>$LOGS/binutils-gold.err
make tooldir=/usr all-gold 1>>$LOGS/binutils-gold.log 2>>$LOGS/binutils-gold.err
make tooldir=/usr install-gold 1>>$LOGS/binutils-gold.log 2>>$LOGS/binutils-gold.err


echo "  [.] bash "
cd $SRC/bash
patch -Np1 -i ../patches/bash-4.3.30-upstream_fixes-3.patch 1>$LOGS/bash.log 2>$LOGS/bash.err
./configure --prefix=/usr \
    --docdir=/usr/share/doc/bash-4.3.30 --without-bash-malloc \
    --with-installed-readline 1>>$LOGS/bash.log 2>>$LOGS/bash.err
make 1>>$LOGS/bash.log 2>>$LOGS/bash.err
#chown -Rv nobody .
#su  nobody -s /bin/bash -c "$PATH=$PATH make tests"
make install 1>>$LOGS/bash.log 2>>$LOGS/bash.err
mv -vf /usr/bin/bash /bin

exit
