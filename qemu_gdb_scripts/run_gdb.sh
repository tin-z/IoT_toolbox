#GDBSERVER is a program that allows you to run GDB on a different machine than the one which is running the program being debugged. 

# GDB MIPSEL
## cmd on target machine
gdbserver.mipsle --wrapper env 'LD_PRELOAD=./libnvram-faker.so' -- localhost:12345 ./usr/sbin/upnpd eth0

## You need an unstripped copy of the target program on your host system, since GDB needs to examine it's symbol tables and such
## cmd on host machine
gdb-multiarch ./usr/sbin/upnpd

set arch mips
set endian little
target remote localhost:12345 #port depend on the qemu forwarding settings
set solib-search-path /tmp/lol123/rootfs/libnvram-faker
b main
c
info sharedlibrary

cat <( printf "set arch mips\nset endian little\ntarget remote localhost:12345\nset solib-search-path /tmp/lol123/rootfs/libnvram-faker\nb main\nc\ninfo sharedlibrary\n" ) - | gdb-multiarch ./usr/sbin/upnpd

## So slow but efficient
gdb-multiarch -q -nx -x upnpd_gdb.gdb ./usr/sbin/upnpd


# GDB ARMV5
## GDB directly from qemu..
cd rootfs
qemu-arm -L $( pwd ) -E LD_PRELOAD=./main_hook.so:./libnvram-faker.so -g 12345 ./usr/sbin/asusdiscovery

### take care of depend of main_hook ... 

## for httpd arm asus
qemu-arm -L $( pwd ) -E LD_PRELOAD=./main_hook.so:./libnvram-faker.so -g 12345 ./usr/sbin/httpd -p 12234
