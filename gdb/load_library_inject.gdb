source ~/.gdbinit-gef.py

################################################
# init
target remote 127.0.0.1:12345
set solib-search-path <path-to-local-replica-of-remote-library-target>

b main
c

### task: load a library inside the debuggee process memory space
call (void *) dlopen("libpino.so", 0)
set $handle=$1
call (void *) dlsym($handle, "ciao_pino")

# save base address where library was loaded by the loader
set $offset_ciao_pino=0x111
set $base_addr_libpino=$2 - $offset_ciao_pino

call (int) ciao_pino(1)
set $return_value=$3

