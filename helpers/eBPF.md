

## Roadmap


0. [chompie1337 writeup](https://www.graplsecurity.com/post/kernel-pwning-with-ebpf-a-love-story)

1. [eBPF-guide](https://github.com/mikeroyal/eBPF-Guide), contents:
    * [what-is-ebpf](https://ebpf.io/what-is-ebpf/)
    * [Learn eBPF Tracing: Tutorial and Examples](https://www.brendangregg.com/blog/2019-01-01/learn-ebpf-tracing.html)

2. Usability stuff
    * [bcc install requirements](https://github.com/iovisor/bcc/blob/master/INSTALL.md)
    * [example usage bcc, bpftrace](https://www.brendangregg.com/blog/2019-01-01/learn-ebpf-tracing.html)

3. Write eBPF program in C
    * [Write eBPF program in pure C](https://terenceli.github.io/%E6%8A%80%E6%9C%AF/2020/01/18/ebpf-in-c)
    * [The art of writing eBPF programs: a primer.](https://sysdig.com/blog/the-art-of-writing-ebpf-programs-a-primer/)
    * [eBPF assembly with LLVM](https://qmonnet.github.io/whirl-offload/2020/04/12/llvm-ebpf-asm/)

    * Altra soluzione è provare a compilare questo tool bpftool, uso header kernel giusti, [usage examples](https://qmonnet.github.io/whirl-offload/2021/09/23/bpftool-features-thread/)



Other stuff


 - lizrice's materials
    * [A Beginner's Guide to eBPF Programming for Networking - Liz Rice, Isovalent](https://www.youtube.com/watch?v=0p987hCplbk)
    * [The Beginner's Guide to eBPF - lizrice repo](https://github.com/lizrice/ebpf-beginners)
    * [The Beginner's Guide to eBPF Programming for Networking](https://github.com/lizrice/ebpf-networking)

 - [eBPF & Cilium Community YT channel](https://www.youtube.com/c/eBPFCiliumCommunity/videos)




## Contents

### 0. Kernel Pwning with eBPF: a Love Story
 - [here](./ebpf_nutshell)



### 1. eBPF-guide ###

 - The Linux kernel contains the eBPF runtime required to run eBPF programs. 
 - It implements the bpf(2) system call for interacting with programs, maps, BTF and various attachment points where eBPF programs can be executed from. 
 - The kernel contains a eBPF verifier in order to check programs for safety and a JIT compiler to translate programs to native machine code. 
 - User space tooling such as bpftool and libbpf are also maintained as part of the upstream kernel

 - [what-is-ebpf](https://ebpf.io/what-is-ebpf/)

 - eBPF programs are event-driven and are run when the kernel or an application passes a certain hook point. 
 - Pre-defined hooks include 
    * system calls
    * function entry/exit
    * kernel tracepoints
    * network events
    * and several others.

 - Programming in eBPF directly is incredibly hard, the same as coding in v8 bytecode.

 - ...


### 2. Usability stuff ###

 - bcc and libbpf, and etc. requires a lot of libraries and other constraints (e.g. kernel compiled with CONFIG_BPF_SYSCALL=y flag


### 3. Write eBPF program in C ###



#### etc.

 - https://duckduckgo.com/?q=ebpf+bytecode&t=newext&atb=v260-1&ia=web
    * https://github.com/Abracax/ebpf_bytecode_loader
    * https://github.com/emilmasoumi/ebpf-assembler

 - https://duckduckgo.com/?q=eBPF+program+examples&t=newext&atb=v260-1&ia=web
 - https://duckduckgo.com/?q=compile+C+eBPF+programs&t=newext&atb=v260-1&ia=web
    * [Code coverage for eBPF programs](https://www.elastic.co/blog/code-coverage-for-ebpf-programs)
    * [eBPF-for-windows](https://github.com/microsoft/ebpf-for-windows/blob/master/docs/tutorial.md)
    * [bpf-docs](https://github.com/iovisor/bpf-docs) (skip BPF parts) 



