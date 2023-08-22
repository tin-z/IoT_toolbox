#define _GNU_SOURCE
#include <stdio.h>
#include <dlfcn.h>

//gcc main_hook.c -o main_hook.so -fPIC -shared -ldl

/* Trampoline for the real main() */
static int (*main_orig)(int, char **, char **);

/* Our fake main() that gets called by __libc_start_main() */
int main_hook(int argc, char **argv, char **envp)
{
    
    //<arg declarations here>
    char user_buf[512] = {"\x00"};
    //scanf("%512s", user_buf);
    read(0, user_buf, 512);
    int (*do_thing_ptr)(char *, int, int) = 0x401f30; //readelf -s asusdiscovery | grep PROCESS_UNPACK_GET_INFO
    int ret_val = (*do_thing_ptr)(user_buf, 0, 0);
    
    printf("Ret val %d\n",ret_val);
    
    return 0;
}

//uClibc_main
/*
 * Wrapper for __libc_start_main() that replaces the real main
 * function with our hooked version.
 */
int __uClibc_main(
    int (*main)(int, char **, char **),
    int argc,
    char **argv,
    int (*init)(int, char **, char **),
    void (*fini)(void),
    void (*rtld_fini)(void),
    void *stack_end)
{
    /* Save the real main function address */
    main_orig = main;
    
    /* Find the real __libc_start_main()... */
    typeof(&__uClibc_main) orig = dlsym(RTLD_NEXT, "__uClibc_main");
    
    /* ... and call it with our custom main function */
    return orig(main_hook, argc, argv, init, fini, rtld_fini, stack_end);
}
