Open Kernel Attached Operating System (OpenKaOS)
=================================================

OpenKaOS is a developer toolkit for building lightweight multi-purpose Linux 
based platforms on various architectures. It is intended as a foundation
for developers to build their own Linux based platform that is embedded
directly into the Linux kernel using initramfs.

#############################################################################

LICENSE:	GNU General Public License Version 2.0

#############################################################################

Helpful Links:

 http://www.opaquesystems.com

 https://www.github.com/opaquesystems/

#############################################################################

What is OpenKaOS?

OpenKaOS is a lightweight multi-purpose Linux platform. It was originally
designed for cloud computing and virtualized environments as a highly
optimized platform for applications. However it is equally well suited for
baremetal, virtual guests and embedded platforms. OpenKaOS is an excellent 
choice for building virtual appliances, embedded appliances, cloud instances 
or any other scenario where you need a lightweight Linux platform.

The OpenKaOS Platform Build System (PBS), located in the build/ directory
of this source distribution, enables you to build a Linux platform from
scratch with just a handful of shell commands.

#############################################################################

Why is it called OpenKaOS?

OpenKaOS leverages a feature in the Linux 2.6+ kernels that enables an 
initramfs image to be embedded within the bootable Linux kernel. The OS is 
so small and modular that it can easily fit within the initramfs image.
The OS is essentially "attached" to the Kernel. This eliminates some points 
of failure, has some potential security benefits depending on your build, 
and allows for a switch/router style firmware image to be generated from 
the combination of kernel + OS.

#############################################################################

System Requirements

To build OpenKaOS you will need a recent Linux development environment, we
recommend Fedora 20 or later. When using a basic Fedora 20 install you will
need to run the following commands:

 yum update
 yum group install "Development Tools"
 yum install patch mpfr mpfr-devel flex bison byacc

#############################################################################

How do I build OpenKaOS?

Using a recent Linux system of your choice (Arch Linux, Fedora, Ubuntu,
Red Hat Enterprise, Linux Mint, etc will all work just fine) with build
tools installed (gcc, make, sudo etc.). Make sure your non-root user
performing the build is in the sudoers file. The quickest way to do this is
to add the user to the wheel group, and check /etc/sudoers to make sure
the wheel configuration option with NOPASSWD is uncommented:

 %wheel ALL=(ALL) NOPASSWD: ALL

then verify the user is in the wheel group, here our user is kaostest:

 # groups kaostest

 wheel users

Assuming you have a reasonable working environment...

First create a workspace using the wsbld.sh utility:

 > cd build

 > ./wsbld.sh

 KaOS Platform Build System, version 1.0.0

 Copyright (c) 2009-2014 Opaque Systems, LLC

 Building workspace for kaostest in /home/kaostest/kaos-ws/kaos-1400595098

 Build tag is kaos-1400595098

 The active workspace is now /home/kaostest/kaos-ws/kaos-1400595098

 > 

This has created a new workspace environment in the ~/kaos-ws/ directory
for our build user. The sequence of numbers following kaos- reflects the
timestamp that the workspace was created in UNIX time. This was done to
keep the workspace namespace unique.

Next you need to retrieve the Open Source code to build the base platform,
this is done with the fetch-opensrc.sh utility. You need to have an active
connection to the Internet for this to work, it is quite bandwidth
intensive:

 > ./fetch-opensrc.sh

This takes anywhere from a few minutes to over an hour depending on
the bandwidth available to you. The source and patches are stored in the pkg/ 
directory in the newly created workspace. The opensrc code directories 
are also tagged with the unix time that the script was run. You can have 
multiple sources within a single workspace.

 $ pwd

 /home/kaostest/kaos-ws/kaos-1400595098/pkg/opensrc-1400595147

 $ ls

 archive    cracklib   gcc2     iana-etc     m4         pcre        systemd

 autoconf   dejagnu    gdbm     inetutils    make       perl        tar

 automake   diffutils  gettext  iproute2     man-db     pkg-config  tcl

 bash       e2fsprogs  glib     kbd          man-pages  procps      texinfo

 bc         expect     glibc    kmod         mpc        psmisc      tzdata

 binutils   file       gmp      less         mpfr       readline    udev

 bison      findutils  grep     libpipeline  ncurses    sed         util-linux

 bzip2      flex       groff    libtool      notused    shadow      xz

 check      gawk       grub     linux        patch      sysklogd    zlib

 coreutils  gcc        gzip     log          patches    syslinux


This script uses third-party servers to retrieve the source code. You
should check the output of fetch-opensrc.sh to make sure there are no
errors, from time to time these servers change paths or become unavailable.

Finally, you need to start the build, this is done by running:

 > ./bld-kaos.sh opensrc-1400595147

The script generates logs in the bld-<timestamp> directory for each
component:

 /home/kaostest/kaos-ws/kaos-1400595098/bld-1400596160

However if you want to completely log the output of the entire script:

 > ./bld-kaos.sh opensrc-1400595147 1>>~/build-3.0.log 2>>~/build-3.0.err

This will place the stdout in build-3.0.log and stderr in build-3.0.err.

When the build is complete you will see new bld-<timestamp> and log-<timestamp> 
directories in the workspace you used. The completed SDK / chroot environment 
is in bld-<timestamp>/bld.

#############################################################################

How do I test OpenKaOS?

Run the chroot-fcs.sh script referencing the build:

        > ls ~/kaos-ws/kaos-1307664362/

        bld-1308375981 log-1308375981 pkg

        > ./chroot-fcs.sh bld-1308375981

        Open Kernel Attached Operating System (KaOS)

        Copyright (c) 2009-2014 Opaque Systems, LLC 

        Build Environment: bld-1308375981

          [.] Loading environment 

              Env is /home/kaos/kaos-ws/kaos-1307664362/bld-1308375981

              Build is /home/kaos/kaos-ws/kaos-1307664362/bld-1308375981/bld/

          [.] Mounting Virtual File Systems

              /dev on /home/kaos/kaos-ws/kaos-1307664362/bld-1308375981/bld/dev type none (rw,bind)

              devpts on /home/kaos/kaos-ws/kaos-1307664362/bld-1308375981/bld/dev/pts type devpts (rw)

              shm on /home/kaos/kaos-ws/kaos-1307664362/bld-1308375981/bld/dev/shm type tmpfs (rw)

              proc on /home/kaos/kaos-ws/kaos-1307664362/bld-1308375981/bld/proc type proc (rw)

              sysfs on /home/kaos/kaos-ws/kaos-1307664362/bld-1308375981/bld/sys type sysfs (rw)

          [.] Entering chroot

        root:/#

Simply type exit to leave the OpenKaOS environment.

#############################################################################

Need more information or help?

Visit http://www.opaquesystems.com for further information.

You can also file bugs, contribute changes or ask questions using GitHub:

https://github.com/opaquesystems/openkaos/issues

#############################################################################

Copyright (c) 2014 Opaque Systems, LLC 
