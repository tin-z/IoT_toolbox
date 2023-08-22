#!/bin/bash

## Qemu Mipsel
### Kernel 2,6
#### Example of mipsel router config
sudo qemu-system-mipsel -m 1024 -M malta -kernel vmlinux-2.6.32-5-4kc-malta -hda debian_squeeze_mipsel_standard.qcow2 -append "root=/dev/sda1 console=tty0" -net nic -net user,net=192.168.101.0/24,hostfwd=tcp::8022-:22,hostfwd=tcp::8080-:80,hostfwd=tcp::12345-:12345

### Kernel 3.2 (more suittable for gdb, so use this instead)
sudo qemu-system-mipsel  -m 2048 -M malta -kernel vmlinux-3.2.0-4-4kc-malta -hda debian_wheezy_mipsel_standard.qcow2 -append "root=/dev/sda1 console=tty0" -net nic -net user,net=192.168.101.0/24,hostfwd=tcp::8022-:22,hostfwd=tcp::8080-:80,hostfwd=tcp::12345-:12345

#### two network 
qemu-system-mipsel  -m 2048 -M malta -kernel vmlinux-3.2.0-4-4kc-malta -hda debian_wheezy_mipsel_standard.qcow2 -append "root=/dev/sda1 console=tty0" -netdev user,id=network0 -device e1000,netdev=network0,mac=56:54:00:12:34:56 -net nic -net user,net=192.168.101.0/24,hostfwd=tcp::8022-:22,hostfwd=tcp::8080-:80,hostfwd=tcp::12345-:12345


## Config IP addr
### Request IP
dhclient -v <interface>
### Release IP
dhclient -v -r <interface>

## Note
### 1 -check settings nvram.ini ip address

### 2 -root password has been changed to:elA1_PoC 

### 3
### ```Although you are not fully emulating the WR740N because most of the
### hardware is missing and it is a different kernel. Emulating a router in qemu is
### always going to be a partial process because of that. ```


## Qemu Armel
qemu-system-arm -M versatilepb -kernel vmlinuz-3.2.0-4-versatile -initrd initrd.img-3.2.0-4-versatile -hda debian_wheezy_armel_standard.qcow2 -append "root=/dev/sda1"
qemu-system-arm -M versatilepb -kernel vmlinuz-3.2.0-4-versatile -initrd initrd.img-3.2.0-4-versatile -hda debian_wheezy_armel_standard.qcow2 -append "root=/dev/sda1" -net nic -net user,net=192.168.101.0/24,hostfwd=tcp::8022-:22,hostfwd=tcp::8080-:80,hostfwd=tcp::12345-:12345


