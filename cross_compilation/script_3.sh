#!/bin/bash

## change from here--
export TARGET="arm-linux-gnueabihf"
export TARGET_CC="arm-linux-gnueabihf-gcc"
export TARGET_CX="arm-linux-gnueabihf-g++"
export TARGET_LD="arm-linux-gnueabihf-gcc"

## till here--


if [ ! -d lsof ]; then
  git clone https://github.com/lsof-org/lsof lsof
fi

echo "## Let the default options"
cd lsof/ && CC=${TARGET_CC} CX=${TARGET_CX} LD=${TARGET_CX} ./Configure linux
make CC=${TARGET_CC} CX=${TARGET_CX} LD=${TARGET_CX}




echo "# Done!"
