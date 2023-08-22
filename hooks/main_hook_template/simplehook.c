#include <stdio.h>
#include <unistd.h>
#include <dlfcn.h>

//gcc libexample.c -o libexample.so -fPIC -shared -ldl -D_GNU_SOURCE
// gcc simplehook.c -o libsimplehook.so -fPIC -shared -ldl -D_GNU_SOURCE
// LD_PRELOAD="./libsimplehook.so"  ./ex1

int memcmp(const void *s1, const void *s2, size_t n){

  int (*new_memcmp)(const void *s1, const void *s2, size_t n);
  int result;
  size_t i;
  new_memcmp = dlsym(RTLD_NEXT, "memcmp");

  FILE *logfile = fopen("logfile", "a+");
  printf("Comparing %p with %p\n",s1, s2);
  for(i = 0; i < n; i++ ){
    fprintf(logfile, "\nProcess %d\n", getpid());
    fprintf(logfile, "\t(%d) %x == %x\n", i, (char *)(s1 + i), (char *)(s2 + i));
  }
  fclose(logfile);
  result = new_memcmp(s1, s2, n);
  return result;
}

