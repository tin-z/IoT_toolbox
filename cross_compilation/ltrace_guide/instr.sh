#!/bin/bash


# Distributed under the MIT License (MIT)
# Copyright (c) 2023, Altin (tin-z)


VER=0.1
LTRACE_V=0.7.3
HOST_T=arm-linux-gnueabi

function _help(){
  echo "# Compile ltrace statically for arm-v7 and more litle-endian"
  echo "#"
  echo "# Usage: ./$0 [--help|--version|--host]"
  echo "#"
  echo "# Req:"
  echo "#    - docker ubuntu 20.04"
  echo "#    - gcc-arm-linux-gnueabi         // mettici cross-compile che vuoi quì, basta che modifichi poi scripts"
  echo "#    - binutils-arm-linux-gnueabi    // anche quì adatta al tuo --host e --target"
  echo "#    - libtool"
  echo "#"
  echo "# options:"
  echo "#  --help     this message"
  echo "#  --version  print version and quit"
  echo "#  --host     cross-compile host (e.g. router's binary files as 'ELF 32-bit LSB executable, ARM, EABI5'"
  echo "#             [default value: arm-linux-gnueabi]"
  echo "#"
}


### check routine
continue=0
case $1 in

--help)
  _help
;;

--version)
  echo "# $0:$VER"
;;

clean)
  rm -rf libelf
  rm -rf ltrace-${LTRACE_V}
  rm -rf ltrace_${LTRACE_V}.orig.tar.bz2*
;;

--host)
  if [ ! -z $2 ]; then
    HOST_T=$2
  else
    echo "Empty host value.. default value is ${HOST_T}"
  fi
  continue=1
;;

*)
  continue=1
esac

if [ $continue == 0 ]; then
  echo "Quit"
  echo ""
  exit 0
fi


if [ -z "`which ${HOST_T}-gcc`" ]; then
  echo "Missing building env: ${HOST_T}-gcc"
  echo ""
  exit 0
fi


if [ ! -d libelf ]; then
  git clone https://github.com/WolfgangSt/libelf
  cd libelf
  autoreconf -fvi
  CC="${HOST_T}-gcc" ./configure --host=${HOST_T} --disable-shared
  make
  cd ../
fi

if [ ! -d ltrace-${LTRACE_V} ]; then
  wget https://www.ltrace.org/ltrace_${LTRACE_V}.orig.tar.bz2
  tar xvjf ltrace_${LTRACE_V}.orig.tar.bz2
  cd ltrace-${LTRACE_V}
  autoreconf -fvi
  CFLAGS="-Wno-error -Wl,-static -static-libgcc -static" CPPFLAGS="-I${PWD}/../libelf/lib -D__LIBELF_INTERNAL__" LDFLAGS="-L${PWD}/../libelf/lib" ./configure --host=${HOST_T} --disable-shared
  make
fi

echo "# Done"

