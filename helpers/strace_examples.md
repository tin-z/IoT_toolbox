

 - strace cheatsheet https://linux-audit.com/the-ultimate-strace-cheat-sheet/

 - strace filter
```
strace -fi -e trace=execve -vvv -s 4096 -p 3340 
```


 - trace multiple processes
```
export binname="<binary>"
strace -fi " -p `pidof ${binname} | sed 's/ / -p /g'`" -e signal,execve -q

```
