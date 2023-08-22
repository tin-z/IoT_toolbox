#!/bin/bash

## change from here--
export TARGET="arm-linux-gnueabihf"
export TARGET_CC="arm-linux-gnueabihf-gcc"
export TARGET_CX="arm-linux-gnueabihf-g++"
export TARGET_LD="arm-linux-gnueabihf-gcc"
export GDB_BUILD=binutils-gdb
export GDB_TAG=gdb-7.8-release
## till here--

if [ ! -d binutils-gdb ]; then 
  git clone git://sourceware.org/git/binutils-gdb.git
fi

cd $GDB_BUILD && git checkout $GDB_TAG && ./configure --target=$TARGET --with-python --enable-tui=yes -enable-static=yes && make LDFLAGS=-static



echo "# Done!"

