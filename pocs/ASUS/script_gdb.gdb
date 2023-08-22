source .gdbinit-gef.py

set arch arm
set endian little
target remote localhost:12345
c

# break on do_blocking_request
#b *0x48DF4

# break on do_detwan_cgi
#b *0x49258

c

