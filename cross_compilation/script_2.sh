#!/bin/bash

## change from here--
export TARGET="arm-linux-gnueabihf"
export TARGET_CC="arm-linux-gnueabihf-gcc"
export TARGET_CX="arm-linux-gnueabihf-g++"
export TARGET_LD="arm-linux-gnueabihf-gcc"
export BINUTILS_VERSION=2.29.1
export BINUTILS_BUILD="binutils-$BINUTILS_VERSION"
## till here--


if [ ! -f binutils-$BINUTILS_VERSION.tar.xz ]; then
  wget ftp://ftp.gnu.org/gnu/binutils/binutils-$BINUTILS_VERSION.tar.xz
  tar -xJf binutils-${BINUTILS_VERSION}.tar.xz
fi


cd $BINUTILS_BUILD && ./configure --target=$TARGET --disable-nls --disable-werror && make CC=${TARGET}-gcc LDFLAGS=-static


echo "# Done!"
