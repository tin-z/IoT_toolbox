
## analyzer_cross_compilation ##

 - e.g:
    * cross-compilation using host Linux machine
    * buildroot
    * llvm
    * crosstool-ng
    * toolchains bootlin 

 - static binaries [repo](https://github.com/andrew-d/static-binaries)

### Requirements ###

 - ubuntu 20.04 docker image
 - install packages:
```
apt-get install -y binutils-dev texinfo bison flex libgmp-dev git tar wget curl
```

 - install target packegs, e.g. arm-linux-gnueabihf:
```
# export TARGET=aarch64-linux-gnu
export TARGET=arm-linux-gnueabihf
apt-get install -y binutils-${TARGET} gcc-${TARGET}

```


### Examples ###

 - cross-compilation [link](https://gts3.org/2017/cross-kernel.html)

```

export TARGET=arm-linux-gnueabihf
export TARGET_CC=${TARGET}-gcc
export TARGET_CX=${TARGET}-g++

CC=${TARGET_CC} CX=${TARGET_CX} LD=${TARGET_CX} ./configure
make CC=${TARGET_CC} CX=${TARGET_CX} LD=${TARGET_CX}
```

 - GDB
    * [script_1.sh](./script_1.sh)

 - binutils
    * [script_2.sh](./script_2.sh)

 - ruby
    * [ruby_arm,sh](./ruby_arm.sh)

 - net-tools,netstat, `net-tools-2.10.tar.xz` [link](https://sourceforge.net/projects/net-tools/files/):
```
cd net-tools-2.10/
make config
make CC=${TARGET_CC} CX=${TARGET_CX} LD=${TARGET_CX}

## Compile netstat as static binary file
$CC -O2 -g -Wall -fno-strict-aliasing  -Llib -o netstat netstat.o statistics.o -lnet-tools -static
```

 - [ltrace](./ltrace_guide)

 - [MIPS64 N32](./MIPS64_n32)

 - lsof
    * [script_3.sh](./script_3.sh)
    * usage: [1](https://bash-prompt.net/guides/lsof/), [2](https://unix.stackexchange.com/questions/235979/how-do-i-find-out-more-about-socket-files-in-proc-fd)

 - strace #TODO
    * usage: [1](https://linux-audit.com/the-ultimate-strace-cheat-sheet/)

 - tcpdump #TODO
    * usage: [1](https://serverfault.com/questions/805006/tcpdump-on-multiple-interfaces#805008), [2](https://danielmiessler.com/study/tcpdump/)



### Buildroot examples ###
 - refer to https://wiki.aalto.fi/download/attachments/84751520/RootFilesystem_for_RPi.pdf?version=1&modificationDate=1386887561177&api=v2
 - https://buildroot.org/downloads/
 - https://bootlin.com/pub/conferences/2016/elce/petazzoni-toolchain-anatomy/petazzoni-toolchain-anatomy.pdf



### toolchains bootlin ###
 - [ref](https://toolchains.bootlin.com/)


### If toolchain different from GLIBC ###

 - In this case, we need to build the folder with the buildroot of the target we are interested in.
    * Alternatively, we can download the precompiled one from the bootlin website [ref](https://toolchains.bootlin.com/)

```
# if '--with-sysroot' option isn't available, then export PATH="path-to-bin-buildroot:${PATH}"
export TARGET=mips-buildroot-linux-uclibc
export TARGET_CC=${TARGET}-gcc
export TARGET_CX=${TARGET}-g++

./configure --target=arm-buildroot-linux-gnueabihf --with-sysroot=${PATH-to-buildroot-folder}
make
```

 - Build GNU grep example
    * download bootlin version mips32-uclibc [link](https://toolchains.bootlin.com/downloads/releases/toolchains/mips32/tarballs/mips32--uclibc--stable-2021.11-1.tar.bz2)
    * download grep [link](https://ftp.gnu.org/gnu/grep/grep-2.23.tar.xz)
    * declare `export PATH=${percorso_bootlin_estratto}/bin:${PATH}`
    * inside grep's source code run: 
```
./configure --host=mips-buildroot-linux-uclibc CFLAGS='-no-pie -static' CXXFLAGS='-no-pie -static'
make CFLAGS='-no-pie -static' CXXFLAGS='-no-pie -static'
```

 - GNU tar
    * download source code [link](https://ftp.gnu.org/gnu/tar/tar-1.29.tar.bz2)
    * apply the same step taken during the GNU grep compilation, that is:
```
./configure --host=mips-buildroot-linux-uclibc CFLAGS='-no-pie -static' CXXFLAGS='-no-pie -static'
make CFLAGS='-no-pie -static' CXXFLAGS='-no-pie -static'
```

 - strace uclibc
    * download [link](https://github.com/strace/strace/releases/download/v5.1/strace-5.1.tar.xz)
    * or [link](https://github.com/strace/strace/releases/download/v5.16/strace-5.16.tar.xz)
    * or [link](https://github.com/strace/strace/releases/download/v4.15/strace-4.15.tar.xz)

```
export PATH="path-to-bin-buildroot:${PATH}"

./configure --host=mips-buildroot-linux-uclibc --target=mips-buildroot-linux-uclibc CFLAGS='-no-pie -static' CXXFLAGS='-no-pie -static'  CONFIG_CROSS_MEMORY_ATTACH=y
make CFLAGS='-no-pie -static' CXXFLAGS='-no-pie -static' CONFIG_CROSS_MEMORY_ATTACH=y
```


 - old strace uclibc version (Useful for kernel below 3.x version which do not support 'process_vm_readv' syscall)
    * download [link](https://sourceforge.net/projects/strace/files/strace/4.6/)
    * Before doing compilation modify `signal.c`, inside function `sys_sigsetmask` modify `sigmask(` calls into `__sigmask(`

```
export PATH="path-to-bin-buildroot:${PATH}"

./configure --host=mips-buildroot-linux-uclibc --target=mips-buildroot-linux-uclibc CFLAGS='-no-pie -static' CXXFLAGS='-no-pie -static'  CONFIG_CROSS_MEMORY_ATTACH=y
make CFLAGS='-no-pie -static' CXXFLAGS='-no-pie -static' CONFIG_CROSS_MEMORY_ATTACH=y

```



 - GNU coreutils
    * download [link](https://ftp.gnu.org/gnu/coreutils/coreutils-8.31.tar.xz)

```
./configure --host=mips-buildroot-linux-uclibc CFLAGS='-no-pie -static' CXXFLAGS='-no-pie -static' TIME_T_32_BIT_OK=yes FORCE_UNSAFE_CONFIGURE=1

make CFLAGS='-no-pie -static' CXXFLAGS='-no-pie -static'
```

 - procps #TODO
    * download [link](https://gitlab.com/procps-ng/procps/-/archive/v3.3.15/procps-v3.3.15.tar)

```
./autogen.sh
./configure --host=mips-buildroot-linux-uclibc CFLAGS='-no-pie -static' CXXFLAGS='-no-pie -static' --without-ncurses
make CFLAGS='-no-pie -static' CXXFLAGS='-no-pie -static'

```


 - netcat
    * download [link](https://sourceforge.net/projects/netcat/files/netcat/0.7.1/netcat-0.7.1.tar.bz2/download)
```
export PATH="path-to-bin-buildroot:${PATH}"

export TARGET=mips-buildroot-linux-uclibc
export TARGET_CC=${TARGET}-gcc
export TARGET_CX=${TARGET}-g++

CC=${TARGET_CC} CX=${TARGET_CX} LD=${TARGET_CX} ./configure CFLAGS='-no-pie -static' CXXFLAGS='-no-pie -static'

make CC=${TARGET_CC} CX=${TARGET_CX} LD=${TARGET_CX} CFLAGS='-no-pie -static' CXXFLAGS='-no-pie -static'

```

 - iproute (tool 'ss' è utile) v4.8.0
    * download [link](https://github.com/shemminger/iproute2/releases/tag/v4.8.0)
```
export PATH="path-to-bin-buildroot:${PATH}"

export TARGET=mips-buildroot-linux-uclibc
export TARGET_CC=${TARGET}-gcc
export TARGET_CX=${TARGET}-g++


CC=${TARGET_CC} CX=${TARGET_CX} LD=${TARGET_CX} ./configure 

CFLAGS='-no-pie -static' CXXFLAGS='-no-pie -static'

make clean
make CC=${TARGET_CC} CX=${TARGET_CX} LD=${TARGET_CX} CFLAGS='-no-pie -static' CXXFLAGS='-no-pie -static'

```

 - gdb-server (mips64 n32)

```
export PATH="path-to-bin-buildroot:${PATH}"
cd ./gdb-7.8.50.20150112/gdb/gdbserver
./configure --with-python --enable-tui=no -enable-static=yes --host=mips64-linux
make

```


