#!/bin/bash


## Preconfig. [important]
### Use RAMdisks for input since, we don't want to destroy harddrives !!!
#### Make a 1GB ramdisk file from which AFL can read input
mkdir -p inputFiles
mount -t tmpfs -o size=1024M tmpfs inputFiles/

cp testCases/* inputFiles && ls inputFiles 
#  test_case1  test_case2  test_case3  test_case4  test_case5

###Stop coredumps from being sent to an external utility
sudo -i
echo core > /proc/sys/kernel/core_pattern
exit
 

## Run slow
export QEMU_SET_ENV="LD_PRELOAD=/tmp/lol123/asus_ac86u/pre/main_hook.so"
export QEMU_LD_PREFIX="/tml/lol123/asus_ac86u/pre"
export AFL_INST_LIBS=1
###if need more calc time set it
#export AFL_NO_FORKSRV=1

BINARY="/tmp/lol123/asus_ac86u/pre/usr/sbin/asusdiscovery"
BINARY_INPUT="/tmp/lol123/asus_ac86u/inputFiles"
BINARY_OUTPUT="/tmp/lol123/asus_ac86u/outputFiles"
QEMU_LD_PREFIX="~/afl/qemu_mode"
AFL_PATH="~/afl"
### run
~/afl/afl-fuzz -i $BINARY_INPUT -o $BINARY_OUTPUT -m none -Q $BINARY


## Run fast [Use this instead]
QEMU_SET_ENV="LD_PRELOAD=/tmp/lol123/asus_ac86u/pre/main_hook.so"  AFL_INST_LIBS=1 QEMU_LD_PREFIX=$(pwd) AFL_PATH=~/afl afl-fuzz -i ../inputFiles/ -o ../outputFiles/ -m none -Q -- ./usr/sbin/asusdiscovery

## NOTE
### Issue 1:
 if you want to pause, use gdb trick.
   $ gdb afl-fuzz
   attach pid
 then 
   $ gdb afl-qemu-trace
   attach pid

 remember to quit first the qemu-trace and then afl-fuzz

### Issue 2:
```
[-] Whoops, your system uses on-demand CPU frequency scaling, adjusted
    between 1171 and 3222 MHz. Unfortunately, the scaling algorithm in the
    kernel is imperfect and can miss the short-lived processes spawned by
    afl-fuzz. To keep things moving, run these commands as root:

    cd /sys/devices/system/cpu
    echo performance | tee cpu*/cpufreq/scaling_governor

    You can later go back to the original state by replacing 'performance' with
    'ondemand'. If you don't want to change the settings, set AFL_SKIP_CPUFREQ
    to make afl-fuzz skip this check - but expect some performance drop.

[-] PROGRAM ABORT : Suboptimal CPU scaling governor
         Location : check_cpu_governor(), afl-fuzz.c:7337
```


