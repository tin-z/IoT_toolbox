 
import idc
import ida_idaapi

# Distributed under the MIT License (MIT)
# Copyright (c) 2023, Altin (tin-z)


# cat n32.h  | sed -e "s/\t/ /g" | sed -e "s/[ ][ ]*/ /g" | sed -e "s/#define __NR_\(.*\) (__NR_Linux + \(.*\))/\"\1\":\2, /g" | xargs

define_n32 = 6000
sys_tab_n32 = { (v+define_n32):k for k,v in {
"read":0, "write":1, "open":2, "close":3, "stat":4, "fstat":5, "lstat":6, "poll":7, "lseek":8, "mmap":9, "mprotect":10, "munmap":11, "brk":12, "rt_sigaction":13, "rt_sigprocmask":14, "ioctl":15, "pread64":16, "pwrite64":17, "readv":18, "writev":19, "access":20, "pipe":21, "_newselect":22, "sched_yield":23, "mremap":24, "msync":25, "mincore":26, "madvise":27, "shmget":28, "shmat":29, "shmctl":30, "dup":31, "dup2":32, "pause":33, "nanosleep":34, "getitimer":35, "setitimer":36, "alarm":37, "getpid":38, "sendfile":39, "socket":40, "connect":41, "accept":42, "sendto":43, "recvfrom":44, "sendmsg":45, "recvmsg":46, "shutdown":47, "bind":48, "listen":49, "getsockname":50, "getpeername":51, "socketpair":52, "setsockopt":53, "getsockopt":54, "clone":55, "fork":56, "execve":57, "exit":58, "wait4":59, "kill":60, "uname":61, "semget":62, "semop":63, "semctl":64, "shmdt":65, "msgget":66, "msgsnd":67, "msgrcv":68, "msgctl":69, "fcntl":70, "flock":71, "fsync":72, "fdatasync":73, "truncate":74, "ftruncate":75, "getdents":76, "getcwd":77, "chdir":78, "fchdir":79, "rename":80, "mkdir":81, "rmdir":82, "creat":83, "link":84, "unlink":85, "symlink":86, "readlink":87, "chmod":88, "fchmod":89, "chown":90, "fchown":91, "lchown":92, "umask":93, "gettimeofday":94, "getrlimit":95, "getrusage":96, "sysinfo":97, "times":98, "ptrace":99, "getuid":100, "syslog":101, "getgid":102, "setuid":103, "setgid":104, "geteuid":105, "getegid":106, "setpgid":107, "getppid":108, "getpgrp":109, "setsid":110, "setreuid":111, "setregid":112, "getgroups":113, "setgroups":114, "setresuid":115, "getresuid":116, "setresgid":117, "getresgid":118, "getpgid":119, "setfsuid":120, "setfsgid":121, "getsid":122, "capget":123, "capset":124, "rt_sigpending":125, "rt_sigtimedwait":126, "rt_sigqueueinfo":127, "rt_sigsuspend":128, "sigaltstack":129, "utime":130, "mknod":131, "personality":132, "ustat":133, "statfs":134, "fstatfs":135, "sysfs":136, "getpriority":137, "setpriority":138, "sched_setparam":139, "sched_getparam":140, "sched_setscheduler":141, "sched_getscheduler":142, "sched_get_priority_max":143, "sched_get_priority_min":144, "sched_rr_get_interval":145, "mlock":146, "munlock":147, "mlockall":148, "munlockall":149, "vhangup":150, "pivot_root":151, "_sysctl":152, "prctl":153, "adjtimex":154, "setrlimit":155, "chroot":156, "sync":157, "acct":158, "settimeofday":159, "mount":160, "umount2":161, "swapon":162, "swapoff":163, "reboot":164, "sethostname":165, "setdomainname":166, "create_module":167, "init_module":168, "delete_module":169, "get_kernel_syms":170, "query_module":171, "quotactl":172, "nfsservctl":173, "getpmsg":174, "putpmsg":175, "afs_syscall":176, "reserved177":177, "gettid":178, "readahead":179, "setxattr":180, "lsetxattr":181, "fsetxattr":182, "getxattr":183, "lgetxattr":184, "fgetxattr":185, "listxattr":186, "llistxattr":187, "flistxattr":188, "removexattr":189, "lremovexattr":190, "fremovexattr":191, "tkill":192, "reserved193":193, "futex":194, "sched_setaffinity":195, "sched_getaffinity":196, "cacheflush":197, "cachectl":198, "sysmips":199, "io_setup":200, "io_destroy":201, "io_getevents":202, "io_submit":203, "io_cancel":204, "exit_group":205, "lookup_dcookie":206, "epoll_create":207, "epoll_ctl":208, "epoll_wait":209, "remap_file_pages":210, "rt_sigreturn":211, "fcntl64":212, "set_tid_address":213, "restart_syscall":214, "semtimedop":215, "fadvise64":216, "statfs64":217, "fstatfs64":218, "sendfile64":219, "timer_create":220, "timer_settime":221, "timer_gettime":222, "timer_getoverrun":223, "timer_delete":224, "clock_settime":225, "clock_gettime":226, "clock_getres":227, "clock_nanosleep":228, "tgkill":229, "utimes":230, "mbind":231, "get_mempolicy":232, "set_mempolicy":233, "mq_open":234, "mq_unlink":235, "mq_timedsend":236, "mq_timedreceive":237, "mq_notify":238, "mq_getsetattr":239, "vserver":240, "waitid":241, "sys_setaltroot":242, "add_key":243, "request_key":244, "keyctl":245, "set_thread_area":246, "inotify_init":247, "inotify_add_watch":248, "inotify_rm_watch":249, "migrate_pages":250, "openat":251, "mkdirat":252, "mknodat":253, "fchownat":254, "futimesat":255, "newfstatat":256, "unlinkat":257, "renameat":258, "linkat":259, "symlinkat":260, "readlinkat":261, "fchmodat":262, "faccessat":263, "pselect6":264, "ppoll":265, "unshare":266, "splice":267, "sync_file_range":268, "tee":269, "vmsplice":270, "move_pages":271, "set_robust_list":272, "get_robust_list":273, "kexec_load":274, "getcpu":275, "epoll_pwait":276, "ioprio_set":277, "ioprio_get":278, "utimensat":279, "signalfd":280, "timerfd":281, "eventfd":282, "fallocate":283, "timerfd_create":284, "timerfd_gettime":285, "timerfd_settime":286, "signalfd4":287, "eventfd2":288, "epoll_create1":289, "dup3":290, "pipe2":291, "inotify_init1":292, "preadv":293, "pwritev":294, "rt_tgsigqueueinfo":295, "perf_event_open":296, "accept4":297, "recvmmsg":298, "getdents64":299, "fanotify_init":300, "fanotify_mark":301, "prlimit64":302, "name_to_handle_at":303, "open_by_handle_at":304, "clock_adjtime":305, "syncfs":306, "sendmmsg":307, "setns":308, "process_vm_readv":309, "process_vm_writev":310, "kcmp":311, "finit_module":312, "sched_setattr":313, "sched_getattr":314, "renameat2":315, "seccomp":316, "getrandom":317, "memfd_create":318, "bpf":319, "execveat":320, "userfaultfd":321, "membarrier":322, "mlock2":323, "copy_file_range":324, "preadv2":325, "pwritev2":326, "pkey_mprotect":327, "pkey_alloc":328, "pkey_free":329, "statx":330, "rseq":331, "io_pgetevents":332
}.items() }


sys_tab = {"linux-n32":(sys_tab_n32,"24 02 ? ? 0 0 0 0C")}



def find_opcode(search_opcode):
    """
        Search for opcode "search_opcode" 
    """
    output = []
    addr = idc.find_binary(0, SEARCH_DOWN, search_opcode)

    while addr != ida_idaapi.BADADDR :
      output.append(addr)
      addr += 1
      addr = idc.find_binary(addr, SEARCH_DOWN, search_opcode)
    return output


def do_pattern_matching_syscall(sys_tab_select=None):
  """
    re-arrange syscall numbers to syscall symbols on a static compiled binary 
  """
  assert(sys_tab_select != None)
  assert(sys_tab_select in sys_tab)
  sys_tab_now, search_opcode = sys_tab[sys_tab_select]
  syscall_point = find_opcode(search_opcode)
  output = {}
  for addr in syscall_point :
    rets = idc.get_wide_dword(addr) & 0xffff
    if rets in sys_tab_now :
        output.update({addr:sys_tab_now[rets]})
  return output

# e.g. search_opcode = "55 8B ? ? ? A1 ?"
# print(find_opcode(search_opcode))

# e.g. do_pattern_matching_syscall(sys_tab_select="linux-n32")

