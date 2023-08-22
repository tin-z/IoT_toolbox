
## tutorial

 - install (tested on ubuntu 20.04 docker version)
```
apt-get install binutils llvm llvm-dev clang clang-tools 
apt-get install lld-6.0
```

 - print supported targets, [example](https://stackoverflow.com/questions/15036909/clang-how-to-list-supported-target-architectures)
```
$ llc --version
```

 - example of use case: compile static binary for mips32 little endian with n32 syscall ([file](add_user.s))
```
clang --target=mips64-linux-gnu -nostdlib -static -fuse-ld=lld -o add_user add_user.s
```


## ref

 - [Guide to writing, compiling, and running MIPS binaries on Linux](https://dev.to/omaremaradev/guide-to-writing-compiling-and-running-mips-binaries-on-linux-55n1)

 - [Cross compilation with Clang and LLVM tools](https://static.linaro.org/connect/bkk19/presentations/bkk19-210.pdf)





