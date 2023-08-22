## Description
Minimal process dump memory C code without using 'process_vm_readv' syscall and so ideal for old kernels


## Compilation
 - tested on docker ubuntu 20.04

```
docker run -it --rm -v /tmp/shared_docker_data:/dataZ ubuntu:20.04 
apt-get update -y


# download bootlin version mips32-uclibc here https://toolchains.bootlin.com/downloads/releases/toolchains/mips32/tarballs/mips32--uclibc--stable-2021.11-1.tar.bz2
# then extract it and adjust your PATH env variable

export PATH="<path_to_bin_bootlin>:$PATH"
mips-buildroot-linux-uclibc-gcc -no-pie -static procdump.min.c -o procdump.min
```


## Usage


```
./procdump.min <pid> <offset> <length> [--ptrace]

# e.g. ./main 908 4194304 65536 --ptrace

```


## TODO
 - inject code
 - modify data
