# IoT_toolbox

Here i'll publish some rudimentary tools i made for vulnerability research and reverse engineering tasks for IoT routers. 

:warning: :warning: :warning: **PLEASE NOTE**. None of the tools released are targeting router models that I have worked on during my previous jobs. :warning: :warning: :warning:


----

## Dir

[pocs](./pocs) :
 - [ASUS](./pocs/ASUS) 


[automatize_tools](automatize_tools) :
 - [audit/py_permission_checker](./automatize_tools/audit/py_permission_checker) : Script parsing `ls -lR` output and returning interesting security info, for example the list of files owned by root with write or read permissions to others
 - [vuln_scanners](./automatize_tools/vuln_scanners) : script automazing bulk-mode binary vulnerability scanners, for example binabsinspector


[cross_compilation](cross_compilation) :
 - Cross compilation notes
 - [ltrace_guide](cross_compilation/ltrace_guide) : Compile ltrace statically for arm-v7


[dump_memory](dump_memory) :
 - [procdump.min](dump_memory/procdump.min) : Minimal process dump memory C code without using 'process_vm_readv' syscall and so ideal for old kernels

[grep](grep):
 - [distrib_grep.sh](grep/distrib_grep.sh) : do poor string distribution

[gdb](./gdb) :
 - [load_library_inject.gdb](gdb/load_library_inject.gdb) : example on how to load a library inside the debeguee process memory address


[helpers](helpers) :
 - various notes and helpers

[hooks](./hooks) :
 - hook templates


[ida](./ida) :
 - [make_data_from_to.py](ida/make_data_from_to.py) : Define an array of some type
 - [search_opcode_and_syscall](ida/search_opcode_and_syscall) : Reconstruct the association of names to syscall numbers n32 ABI, usefull for static binary compiled with different ABI syscall


[ida IDC scripts](https://github.com/tin-z/IDC_OSED_scripts) :
 - IDC plugins to support OSED exam preparation, some of the scripts are simplified port of devttyS0 IDAPython plugins 


[qemu_gdb_scripts](qemu_gdb_scripts) :
 - Various scripts related to qemu user-mode emulation and gdb-multiarch debugging


[rude_diffing_tools](rude_diffing_tools) :
 - Rudimentary scripts to do stuff related to filesystem diff and binary diff
 - Create filesystem graph and return a list of non-shared object ELF calling an external function which in turn calls a function that you're interested


