#!/bin/bash

# author: Altin (tin-z)


function find_missing_lib() {
  if [ -z "$1" ]; then
    echo "Usage: find_missing_lib <binary>"
    exit 0
  fi

  cd rootfs_ubifs

  readelf -d "$1" | grep "Shared library: " | sed -E "s/.*Shared library: \[(.*)\]/\1/" | while read x; do
    tmp123=`find -name "$x"`
    if [ -z "$tmp123" ]; then
      tmp1=$( find -type f -name "$( echo $x | sed -E 's/(.*)\.so.*/\1/g').*" )
      echo -e "\x1b[31mNOT found:\x1b[0m $x (\x1b[33mhint:\x1b[0m $tmp1)\n";
    fi
  done

  cd ..
};


function check_tools() {
  if [ ! -f nvram.ini ] || [ ! -f libnvram-faker.so ] || [ ! -f script_gdb.gdb ]; then
    echo "Missing one of the local tools/resources ..quit"
    exit -1
  fi

  if [ -z "`which qemu-arm-static`" ] ; then
    echo "Can't find qemu-arm-static ..quit"
    exit -1
  fi
};


function set_rootdir() {
  port_httpd=12234
  echo "## Adjusting directory"

  # fix executables
  cd rootfs_ubifs
  find -type f | while read x; do tmp123=`file "$x" | grep -E -e "ELF (32|64)-bit" -e " shell script" `; if [ ! -z "$tmp123" ]; then chmod +x "$x"; fi; done
  chmod +x  www/*.asp

  # fix folders
  rm -rf etc home media mnt opt root var
  mkdir -p tmp/var/run && touch tmp/var/run/httpd-${port_httpd}.pid
  mkdir -p tmp/home/root tmp/{media,mnt,opt,etc}
  ln -s tmp/var var && ln -s tmp/etc etc
  ln -s tmp/home home && ln -s tmp/home/root root && ln -s tmp/media media && ln -s tmp/mnt mnt && ln -s tmp/opt opt
  echo "## Creating fake cert.pem inside tmp/etc. Press [enter]"

  # fix library links
  # ln -s lib/libjson-c.so.2.0.2 lib/libjson-c.so.2
  # ln -s lib/libc.so.6 lib/libc.so.0

  # create self-signed cert
  cd etc 
  openssl genrsa 2048 > host.key
  openssl req -new -x509 -nodes -sha256 -days 365 -key host.key -out host.cert
  openssl x509 -in host.cert -out cert.pem -outform PEM
  cat host.cert host.key > key.pem
  cd ..

  ## copy stuff
  cp ../nvram.ini .
  cp ../libnvram-faker.so .
  cp ../script_gdb.gdb .
  cp "`which qemu-arm-static`" .
  wget -O .gdbinit-gef.py -q https://gef.blah.cat/py


  ## other
  mv www/* .

  printf "## Done!\n\n"
  echo "run: sudo chroot ${PWD} ./qemu-arm-static -E LD_PRELOAD=./libnvram-faker.so -g 12345 ./usr/sbin/httpd -p $port_httpd"
  echo "from another terminal run: sudo gdb-multiarch ./usr/sbin/httpd -q --nx -ex 'source ./.gdbinit-gef.py' -ex 'target remote 127.0.0.1:12345'"
  echo "##"

};




check_tools
set_rootdir



