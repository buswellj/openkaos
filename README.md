###OpenKaOS: the Linux Kernel Attached Operating System
===================================================================================

OpenKaOS is an open source project to build lightweight Linux platforms
that are embedded directly into the Linux kernel. The entire Linux platform
sits inside a single bzImage and boots from initramfs.


OpenKaOS is a powerful Linux platform that can be dropped in as a replacement
for any Linux distribution by simply adding the OpenKaOS Linux kernel and
rebooting the system. 


OpenKaOS is designed to provide maximum resources to the application supported
by the operating system, it is optimized for deployment on Cloud Instances and
Virtual Machines (KVM, VMware, Xen etc). OpenKaOS is being used as a base
platform for Docker and other Linux container based platforms.


OpenKaOS is not based off any existing Linux distribution. OpenKaOS is built
from vanilla open source project code, with specially selected patches when
needed. 


This open source project is not intended to provide a complete Linux distribution,
it provides a developer toolkit from which you can build Linux platforms such as
Linux distributions, software appliances, virtual appliances, containers, cloud
instances, embedded platforms and so on.


This document provides some project related information such as handling security
issues, release schedules, feature development, licensing and how to use this
project.


###Security Issues
====================================================================================

Security issues are extremely important to us, if you encounter a security issue,
we appreciate your responsible co-operation by notifying us of the issue by sending
an email to (security@opaquesystems.com). Please do not create github issues related
to security. We use the security tag in GitHub issues for security advisory 
announcements once a fix is available.

###What does OpenKaOS do?
====================================================================================

This project will build a base Linux system and SDK from vanilla open source code 
freely available on the Internet. The SDK can be used to produce a working Linux
Kernel containing the embedded OpenKaOS platform, it can be used as a chroot or
container environment as well. It is designed for developers to use as a starting
point and to augment for their particular needs.


OpenKaOS is relative easy to understand, it performs the following tasks:


 1. Creates a new project workspace
 2. Downloads all the open source source code from the Internet
 3. It verifies all the open source source code downloaded OK
 4. It builds a prestine toolchain using the tools on the host system
 5. SDK Stage 1 uses the toolchain to build the SDK environment
 6. SDK Stage 2 uses the base SDK to build the rest of the SDK environment
 7. SDK Stage 3 cleans up the base SDK environment
 8. SDK Stage 4 builds the core packages and cpio environment
 9. The user can now use the SDK environment and tweak the Linux kernel config
 0. The user then builds the kernel which produces the bzImage with OpenKaOS inside


OpenKaOS stores all of its files in $HOME/openkaos/. This project makes heavy use
of the "unix time" timestamp, it is how we tag builds and versions of the build
that the user creates. Unixtime increments by 1 every second and is a running
count of the number of seconds since January 1st 1970.


 * autobuild (contains logs/*timestamp*/ - use to monitor builds)
 * pkg (contains packaged openkaos sdks) - generated with the pkg-* scripts
 * kaos-*timestamp* - contains the actual OpenKaOS workspace
 * .current - points the current active workspace
 * .toolchain - points to the current active toolchain
 * .latest-src - points to the current active opensource downloads


Below we go through each of the scripts as they are executed and explain what they
do at a very high level...


  Script             | Description
 --------------------|------------------------------------------------------------
  autobuild-kaos.sh  | This script can be used to build the entire OpenKaOS project
  wsbld.sh           | This script creates a workspace in ~/openkaos/kaos-*timestamp*
  opensrc-list       | Not a script but a list of links to download source code
  fetch-opensrc.sh   | Downloads and processes the open source source code
  verify-opensrc.sh  | Checks that the open source source code has downloaded ok
  bld-kaos.sh        | Main build control script for the project
  bld-toolchain.sh   | This sets up and builds the toolchain from source code
  bld-prepsdk.sh     | This prepares the SDK chroot environment, copies in source etc.
  bld-sdk.sh         | This builds the initial SDK environment using the toolchain
  bld-sdk2.sh        | This pivots and uses the SDK environment to build the rest of the SDK
  bld-sdk3.sh        | This cleans up and removes unnecessary components from the SDK
  bld-core.sh        | This builds additional tools (busybox, dhcp, openssl, openssh)
  bld-cpio.sh        | This builds the cpio image and sets up the /sdk path
  chroot-fcs.sh      | This is a development tool to enter a built SDK within the workspace
  openkaos-sdk.sh    | This is script is used to access a completed SDK outside of the workspace
  pkg-toolchain.sh   | This script packages a toolchain from the workspace into ~/openkaos/pkg/
  pkg-sdk.sh         | This script packages a completed SDK environment into ~/openkaos/pkg/


###System Requirements
====================================================================================

We build OpenKaOS on a Linode 8192 plan cloud instances (8GB ram, 6 CPU) and on 2.4GHz
Quad-Core Intel Servers with 4GB ram, single processor - quad core systems. It should
build, while slower on systems with as little as 2GB of ram.

To build OpenKaOS you will need a recent Linux development environment, we
recommend Fedora 20 or later. When using a basic Fedora 20 install you will
need to run the following commands:

 ```
 yum update
 yum group install "Development Tools"
 yum install patch mpfr mpfr-devel flex bison byacc
 ```

Using a recent Linux system of your choice (Arch Linux, Fedora, Ubuntu,
Red Hat Enterprise, Linux Mint, etc will all work just fine) with build
tools installed (gcc, make, sudo etc.). Make sure your non-root user
performing the build is in the sudoers file. The quickest way to do this is
to add the user to the wheel group, and check /etc/sudoers to make sure
the wheel configuration option with NOPASSWD is uncommented:

 ```
 %wheel ALL=(ALL) NOPASSWD: ALL
 ```

then verify the user is in the wheel group, here our user is kaostest:

 ```
 # groups kaostest

 wheel users
 ```

###Building the System
====================================================================================

Assuming you have a reasonable working environment, you can pull the code
down using git and start an autobuild. This should be done as a non-root user who
has been assigned sudoers access as described in the previous section.

 ```
 git clone https://github.com/opaquesystems/openkaos.git
 cd openkaos/build/
 ./autobuild-kaos.sh
 ```
 
This will take some time to complete, you can check the progress in **~/openkaos/autobuild/logs**

When it is completed you will see something like this:

```
  [.] SDK phase 3

  [*] Building SDK: stage 3 of 3...

  [.] Stripping debug information from execs...

  [.] SDK core build
install: creating directory '/var/lib/sshd'
changed ownership of '/var/lib/sshd' from root:root to root:sys
  [.] Cleaning SDK environment
  [*] Build complete.
  [-] Build Information:

        Build ID is 1433809754
        User is pagan (/home/pagan)
        Building kaos-1433809225 in /home/pagan/openkaos/kaos-1433809225/bld-1433809754
        Source is /home/pagan/openkaos/kaos-1433809225/pkg/opensrc-1433809225
        Logs stored in /home/pagan/openkaos/kaos-1433809225/log-1433809754

        Run chroot-fcs.sh bld-1433809754 to enter chroot environment

```

You will want to note the number after bld- as this is your build number. To check the
environment out you can use:

 ```
  ./chroot-fcs.sh bld-1433809754
 ```

Obviously, replace bld-1433809754 with the output your build produces. When you are
happy with the build you can package it up for use...

 ```
  ./pkg-sdk.sh bld-1433809754
 ```

This will produce the following output along with a list of files as its archived...

```
Open Kernel Attached Operating System (OpenKaOS)
Copyright (c) 2009-2015 Opaque Systems, LLC

Source Build Environment: bld-1433809754

  [.] Preparing packaging environment
  [.] Loading environment 
      Env is /home/pagan/openkaos/kaos-1433809225/bld-1433809754
      Build is /home/pagan/openkaos/kaos-1433809225/bld-1433809754/bld/

  [.] Found SDK - /home/pagan/openkaos/kaos-1433809225/bld-1433809754/bld/
  [.] Packaging SDK in /home/pagan/openkaos/pkg/sdk/1433823730
  [.] Installing /home/pagan/openkaos/kaos-1433809225/bld-1433809754/bld/ in package

...

sdk/sbin/rtstat
sdk/sbin/ip6tables
sdk/dev/
sdk/dev/null
sdk/dev/console
openkaos-sdk.sh
  [.] Package sdk-1433823730.tar.xz is complete
  [.] Cleaning up

  [.] Packaging complete

```

When it is complete, you can use the archive file on any Linux system that supports
the same architecture (most likely x86-64). 

###Using the SDK
====================================================================================

The sdk is stored in ~/openkaos/pkg/sdk/*timestamp*/sdk-*timestamp*.tar.xz

```
du -s -h ~/openkaos/pkg/sdk/1433823730/sdk-1433823730.tar.xz 
185M    /home/pagan/openkaos/pkg/sdk/1433823730/sdk-1433823730.tar.xz
```

This sdk can be copied to any Linux system and is completely self-contained. Provided
the Linux system has tar, xz and chroot support (most reasonably modern Linux systems
would have this), the SDK will work.

```
[pagan@build-system-01 ~]$ mkdir myproject
[pagan@build-system-01 ~]$ cd myproject/
[pagan@build-system-01 myproject]$ sudo tar xvf ~/openkaos/pkg/sdk/1433823730/sdk-1433823730.tar.xz 
...
(patiently wait)
...
sdk/dev/null
sdk/dev/console
openkaos-sdk.sh
```

It will take some time for this to uncompress. When its done you can invoke the SDK...

```
[pagan@build-server-01 myproject]$ ./openkaos-sdk.sh 

Open Kernel Attached Operating System (OpenKaOS)
Copyright (c) 2009-2015 Opaque Systems, LLC

  [.] Testing Architecture 
SDK version 4.0.0

 [.] Mounting Virtual File Systems
mount: /dev bound on /home/pagan/myproject/sdk/dev.
mount: devpts mounted on /home/pagan/myproject/sdk/dev/pts.
mount: shm mounted on /home/pagan/myproject/sdk/dev/shm.
mount: proc mounted on /home/pagan/myproject/sdk/proc.
mount: sysfs mounted on /home/pagan/myproject/sdk/sys.

 [.] Entering SDK
root:/# 

```

At this point you are now inside the SDK environment. Below you can see the output from some
basic commands. It looks very much like a standard Linux system, the two differences are the /app and
/sdk directories. The /app directory contains some packaged code, and you can use this area to install
other open source components you build from source. The /sdk directory contains the development tools.


```
root:/# ls
app  bin  boot  dev  etc  home  lib  lib64  media  mnt  opt  proc  root  run  sbin  sdk  srv  sys  tmp  usr  var

root:/# cd sdk

root:/sdk# ls
kernel  openkaos.boot  openkaos.fs  tools

root:/sdk# ls tools/
bld-cpio.sh  regen-initramfs

root:/sdk# ls kernel/
linode-config  linux

```

Here is a quick explanation of these directories and files:

 Location    |  Description
 ------------|-------------------------------------------------
 /sdk/openkaos.boot | This is where the completed cpio image is stored
 /sdk/openkaos.fs | This is the root filesystem that will be embedded in the kernel
 /sdk/kernel | Contains the Linux kernel source code
 /sdk/tools/ | Contains useful tools
 bld-cpio.sh | Script that is used to regenerate the entire example cpio
 regen-initramfs | If you make changes to the initramfs this will regenerate the cpio
 linode-config | This is an example Linode / Xen Guest Kernel Configuration
 
You can use the linode-config as the base .config file for the kernel or you can build
your own. We recommend starting with the linode-config and making changes. Additional
examples for other cloud services and platforms will be added in the near future. 

```
 root:/# cd /sdk/kernel/linux
 root:/sdk/kernel/linux# cp ../linode-config .config
 root:/sdk/kernel/linux# make oldconfig
 root:/sdk/kernel/linux# TERM=linux make menuconfig
 root:/sdk/kernel/linux# make
```
 

###Linode Example
====================================================================================

Here is a quick run through using the SDK to build a working Linode Kernel...

```
[pagan@build-server-01 myproject]$ ./openkaos-sdk.sh 

Open Kernel Attached Operating System (OpenKaOS)
Copyright (c) 2009-2015 Opaque Systems, LLC

  [.] Testing Architecture 
SDK version 4.0.0

 [.] Mounting Virtual File Systems
mount: /dev bound on /home/pagan/myproject/sdk/dev.
mount: devpts mounted on /home/pagan/myproject/sdk/dev/pts.
mount: shm mounted on /home/pagan/myproject/sdk/dev/shm.
mount: proc mounted on /home/pagan/myproject/sdk/proc.
mount: sysfs mounted on /home/pagan/myproject/sdk/sys.

 [.] Entering SDK
root:/# 
root:/# cd /sdk/
kernel/        openkaos.boot/ openkaos.fs/   tools/         
root:/# cd /sdk/kernel/
linode-config  linux/         pkg-config/    
root:/# cd /sdk/kernel/linux
root:/sdk/kernel/linux# cp ../linode-config .config
root:/sdk/kernel/linux# make oldconfig
  HOSTCC  scripts/basic/fixdep
  HOSTCC  scripts/kconfig/conf.o
  SHIPPED scripts/kconfig/zconf.tab.c
  SHIPPED scripts/kconfig/zconf.lex.c
  SHIPPED scripts/kconfig/zconf.hash.c
  HOSTCC  scripts/kconfig/zconf.tab.o
  HOSTLD  scripts/kconfig/conf
scripts/kconfig/conf --oldconfig Kconfig
#
# configuration written to .config
#
root:/sdk/kernel/linux# make
... (sometime will pass) ...
  CC      arch/x86/boot/video-bios.o
  LD      arch/x86/boot/setup.elf
  OBJCOPY arch/x86/boot/setup.bin
  OBJCOPY arch/x86/boot/vmlinux.bin
  HOSTCC  arch/x86/boot/tools/build
  BUILD   arch/x86/boot/bzImage
Setup is 15836 bytes (padded to 15872 bytes).
System is 11098 kB
CRC 2e6443bf
Kernel: arch/x86/boot/bzImage is ready  (#1)
kernel/Makefile:133: *** No X.509 certificates found ***
  Building modules, stage 2.
  MODPOST 2 modules
  CC      drivers/xen/tmem.mod.o
  LD [M]  drivers/xen/tmem.ko
  CC      fs/nfs/flexfilelayout/nfs_layout_flexfiles.mod.o
  LD [M]  fs/nfs/flexfilelayout/nfs_layout_flexfiles.ko

```

The OpenKaOS platform is stored in **/sdk/kernel/linux/arch/x86/boot/bzImage**

There are a number of ways you can deploy a custom kernel with Linode. The easiest
approach though is to do the following:

 1. Login / Create an account at Linode.com
 2. Add a new Linode
 3. Deploy Fedora Core on the Linode
 4. Power Up / Boot the Linode
 5. ssh into the Linode
 6. On the Linode : mkdir -p /boot/grub
 7. On the Linode : create /boot/grub/menu.lst
 8. scp /sdk/kernel/linux/arch/x86/boot/bzImage to the Linode-IP:/boot/OpenKaOS-4.0.0-1.boot
 9. In the Linode manager click on the Linode, edit the profile
 0. Change the kernel to pv-grub-x86_64 and reboot


Here is an example from a Fedora release 21 console on Linode system:

```
Fedora release 21 (Twenty One)
Kernel 4.0.4-x86_64-linode57 on an x86_64 (hvc0)

test login: root
Password: 
Last login: Tue Jun  9 00:04:30 on hvc0
[root@test ~]# cat /boot/grub/menu.lst 
timeout 3

title OpenKaOS
root (hd0)
kernel /boot/OpenKaOS-4.0.0-1.boot xencons=tty console=tty1 console=hvc0 earlyprintk=xen

[root@test ~]#
```

Use the remote access tab in the Linode manager to gain console access. Check the boot,
and you are presented with the shell prompt. Set the password for root.

```
systemd-shutdown[1]: Detaching loop devices.
systemd-shutdown[1]: All loop devices detached.
systemd-shutdown[1]: Detaching DM devices.
systemd-shutdown[1]: All DM devices detached.
systemd-shutdown[1]: Powering off.
reboot: System halted

[screen is terminating]
[linode767639@atlanta506 lish]# 
Job 24305576 - System Shutdown completed.
[linode767639@atlanta506 lish]# 

(you will see grub for a split second.. then a ton of kernel printks...)

...

console [netcon0] enabled
netconsole: network logging started
drivers/rtc/hctosys.c: unable to open rtc device (rtc0)
Freeing unused kernel memory: 7460K (ffffffff81e99000 - ffffffff825e2000)
Write protecting the kernel read-only data: 14336k
Freeing unused kernel memory: 1932K (ffff88000181d000 - ffff880001a00000)
Freeing unused kernel memory: 948K (ffff880001d13000 - ffff880001e00000)
haveged: haveged starting up
Available Entropy:  0
Internet Systems Consortium DHCP Client 4.3.2
Copyright 2004-2015 Internet Systems Consortium.
All rights reserved.
For info, please visit https://www.isc.org/software/dhcp/

Listening on LPF/eth0/xx:xx:xx:xx:xx:xx
Sending on   LPF/eth0/xx:xx:xx:xx:xx:xx
Sending on   Socket/fallback
DHCPDISCOVER on eth0 to 255.255.255.255 port 67 interval 7
DHCPREQUEST on eth0 to 255.255.255.255 port 67
DHCPOFFER from 192.168.192.59
DHCPACK from 192.168.166.251
bound to 192.168.166.125 -- renewal in 34506 seconds.
Available Entropy:  2496
random: ssh-keygen urandom read with 28 bits of entropy available
Generating public/private ed25519 key pair.
Your identification has been saved in /app/config/ssh/ssh_host_key.
Your public key has been saved in /app/config/ssh/ssh_host_key.pub.
The key fingerprint is:
SHA256:IRy2HMvpC2FwL33ga/epue95BJKJsQzhC75Rt/t4c2M root@openkaos
The key's randomart image is:
+--[ED25519 256]--+
|  . o.=          |
|   +.O.B         |
|  . *o&+oo       |
| . + *+=+..      |
|  o o = S. .     |
|   o o + . ..    |
|  .   o   o.     |
|       oooE..    |
|      ..=B+o     |
+----[SHA256]-----+

OpenKaOS version 4.0.0
Copyright (c) 2009-2015 Opaque Systems LLC

http://www.opaquesystems.com

ash: can't access tty; job control turned off
/ # 

```

Here you can see on the console that the system has booted, note the Available Entropy should be
around 2000 or higher before the ssh-keygen is executed. Now all you need to do is set the
root password and you can start poking around on the system...

```
/ # passwd root
Changing password for root
New password: 
Retype password: 
Password for root changed by root

/ # iptables -L -n
Chain INPUT (policy ACCEPT)
target     prot opt source               destination         
ACCEPT     all  --  0.0.0.0/0            0.0.0.0/0            state RELATED,ESTABLISHED
ACCEPT     icmp --  0.0.0.0/0            0.0.0.0/0           
ACCEPT     all  --  0.0.0.0/0            0.0.0.0/0           
ACCEPT     tcp  --  0.0.0.0/0            0.0.0.0/0            state NEW tcp dpt:2222
DROP       all  --  0.0.0.0/0            0.0.0.0/0           

Chain FORWARD (policy ACCEPT)
target     prot opt source               destination         
REJECT     all  --  0.0.0.0/0            0.0.0.0/0            reject-with icmp-host-prohibited

Chain OUTPUT (policy ACCEPT)
target     prot opt source               destination         

```

Note that OpenSSH is running on port 2222, and we have some basic iptables rules setup...

```
/ # netstat -nap
Active Internet connections (servers and established)
Proto Recv-Q Send-Q Local Address           Foreign Address         State       PID/Program name    
tcp        0      0 0.0.0.0:2222            0.0.0.0:*               LISTEN      1443/sshd
tcp        0      0 :::2222                 :::*                    LISTEN      1443/sshd
udp        0      0 0.0.0.0:64490           0.0.0.0:*                           1438/dhclient
udp        0      0 0.0.0.0:68              0.0.0.0:*                           1438/dhclient
udp        0      0 :::4542                 :::*                                1438/dhclient
Active UNIX domain sockets (servers and established)
Proto RefCnt Flags       Type       State         I-Node PID/Program name    Path
/ # 

```

Now you can use the ssh client inside the SDK to access the running system in Linode via SSH.
We recommend using the SDK because the default for the Linode example is to use the fast and secure
encryption with ED25519, this requires a very new version of OpenSSH.

```
root:/sdk/kernel/linux# ssh -x -l root 192.168.166.125 -p 2222
The authenticity of host '[192.168.166.125]:2222 ([192.168.166.125]:2222)' can't be established.
ED25519 key fingerprint is SHA256:IRy2HMvpC2FwL33ga/epue95BJKJsQzhC75Rt/t4c2M.
Are you sure you want to continue connecting (yes/no)? yes
Warning: Permanently added '[192.168.166.125]:2222' (ED25519) to the list of known hosts.
root@192.168.166.125's password: 

OpenKaOS version 4.0.0
Copyright (c) 2009-2015 Opaque Systems LLC

http://www.opaquesystems.com

~ # uname -a
Linux openkaos 4.0.5-OpenKaOS-4.0.0 #2 SMP Tue Jun 9 05:29:33 UTC 2015 x86_64 GNU/Linux
~ # uptime
 05:36:50 up 5 min,  0 users,  load average: 0.00, 0.00, 0.00
~ # 

```

This is just an example, but its a good starting point to base a new Linux platform,
distro or other project...

Let us know what you do with this!

###Release Model
====================================================================================

OpenKaOS uses a hybrid continuous delivery and calendar release system. There are
three types of builds that we maintain:


 build | description | release schedule | location
-------|-------------|------------------|------------
 GA    | Continous Delivery | June / December | /openkaos/build/
 Dev   | Development Release | September / March | /openkaos/devbuild/
 Patch | GA based Patch Releases | Between GA | /openkaos/archive/


####Example Release Schedule

 version | build | date
---------|-------|--------
 4.0.0   | GA / stable | June 15th 2015
 4.0.1   | GA - patch  | July 15th 2015
 4.0.2   | GA - patch  | August 15th 2015
 4.0.3   | GA - patch  | Sept 15th 2015
 4.1.0   | Development | Sept 15th 2015
 4.0.4   | GA - patch  | Oct 15th 2015
 4.1.1   | Development | Oct 30th 2015
 4.0.5   | GA - patch  | Nov 15th 2015
 4.1.2   | Development | Nov 30th 2015
 4.2.0   | GA / stable | December 15th 2015


###Feature Development
====================================================================================

Continuous Delivery and Patch release versions only contain bugfixes, security fixes,
minor release upgrades and minor feature enhancements (script improvements, 
new examples, small feature requests from users etc). So we would upgrade perl from
5.22.0 to another 5.x release, but we would not upgrade perl 5.x to 6.x for example.

Development releases contain major version upgrades, such as upgrading from gcc 4.x
to gcc 5.x, Linux 3.x to 4.x and so on. Development releases contain changes that
might alter the expected behavior of the system or add big new features.

The goal of the project is for continous delivery / patch releases to be relatively
stable and always working. No unexpected shocks for the users!

###Contributing
====================================================================================

OpenKaOS is intended to be a very lightweight framework for build Linux platforms.
Contributions that provide suites of software on top of OpenKaOS (eg. X-Windows)
should really be maintained as separate projects that use OpenKaOS as a base. If
you have such a project, we will gladly list in our [Wiki](https://github.com/opaquesystems/openkaos/wiki)

If you want to contribute bug fixes or other changes to our code, please follow
this procedure:

 1. Create a new [Issue](https://github.com/opaquesystems/openkaos/issues)
 2. Fork this project on GitHub
 3. Make changes to your fork
 4. Generate a Pull Request when you are ready

###License
======================================================================================

This entire project is released under the GNU General Public License (GPL), version 2.


###Why is it called OpenKaOS?
====================================================================================

OpenKaOS leverages a feature in the Linux 2.6+ kernels that enables an 
initramfs image to be embedded within the bootable Linux kernel. The OS is 
so small and modular that it can easily fit within the initramfs image.
The OS is essentially "attached" to the Kernel. This eliminates some points 
of failure, has some potential security benefits depending on your build, 
and allows for a switch/router style firmware image to be generated from 
the combination of kernel + OS.

====================================================================================

Need more information or help?

Visit our [Wiki](https://github.com/opaquesystems/openkaos/wiki) for further information.

You can also file bugs, contribute changes or ask questions using [GitHub](https://github.com/opaquesystems/openkaos/issues)

====================================================================================

Copyright (c) 2009-2015 Opaque Systems, LLC 
