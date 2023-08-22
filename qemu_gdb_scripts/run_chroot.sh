#after you set all the libnvram-faker.so then use chroot to the firmware folder

## Config chroot
cd rootfs && chroot . usr/bin/lighttpd -f mnt/ligthttpd/lighttpd.conf
cd rootfs && chroot . ./bin/sh


chroot . ./bin/sh [args]


LD_PRELOAD=./libnvram-faker.so ./usr/sbin/nvram get time_zone


LD_PRELOAD=./libnvram-faker.so ./sbin/rc restart
