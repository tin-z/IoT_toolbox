#!/bin/bash

## change from here--
export TARGET="arm-linux-gnueabihf"
export TARGET_CC="${TARGET}-gcc"
export TARGET_CX="${TARGET}-g++"
export TARGET_LD="${TARGET}-gcc"
export RUBY_VERSION=2.1
export RUBY_BUILD="ruby-2.1.1"


## lib required 
sudo apt-get install libssl-dev libreadline-dev libgdbm-dev
# rbenv is required during compilation
apt-get install ruby-dev



## till here--
# refer to :
#       * https://gist.github.com/Koronen/10550810
#       * https://github.com/rbenv/ruby-build
#       * https://bugs.ruby-lang.org/issues/11494
#


# Install ruby-build
[ -d ruby-build ] || git clone https://github.com/sstephenson/ruby-build.git

export RUBY_BUILD_BUILD_PATH=/tmp/ruby-build
export CC=arm-linux-gnueabihf-gcc
export CONFIGURE_OPTS="--host x86_64-linux-gnu --build ${TARGET} --disable-install-rdoc --disable-install-ri"
export RUBY_CONFIGURE_OPTS="--without-ripper"
ruby-build/bin/ruby-build --verbose --keep 2.1.0 ruby-2.1.0-armhf


echo "# Done!"

