### find_dep_libs.sh: ###

Find binaries that depend on libraries specified from the command line, starting from the current directory.


### find_symbols.sh: ###

Find binaries that import or export a function specified from the command line, starting from the current directory.


### get_sizes.sh: ###

This script is ""useful"" when you want to understand where the modification has been made by a firmware patch.

For example:
 - I run the script on two different sysroots of the same router but with slightly different versions, and I find that only the sbin folder has an increased size.
 - I enter the sbin folder of both sysroots and run the script again.
 - I repeat this process until I find the binary with a different size, as the vulnerability probably resides there. Then, I can use diaphora to understand where the code has been modified (don't trust it).


### r2_ex.py ###

Use r2pipe to compare exported functions between unpatched and patched version of a binary

