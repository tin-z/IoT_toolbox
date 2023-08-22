#!/bin/bash

# Distributed under the MIT License (MIT)
# Copyright (c) 2023, Altin (tin-z)


# depends: 
# usage: ./find_symbold.sh symbols
# output: all binary that import/export symbols
# option: if need more output use '-s' instead-of '--dyn-sym'

arg_to_chk=$1
printf "\n## searching dyn-symbol: %s\n\n" $arg_to_chk
## accept call
#finded_chk=0; for x in $( find -type f ); do tmp_z=`readelf --dyn-sym  $x 2>/dev/null| grep -E -e ' '$arg_to_chk'$' -e ' '$arg_to_chk'@'`; if [ ! -z "$tmp_z" ]; then printf "%s :- %s\n" "$x" "$tmp_z";finded_chk=$((finded_chk+1)); fi; done; printf "\n## Total finded: %d\n\n" $finded_chk;
#finded_chk=0; for x in $( find -type f ); do tmp_z=`readelf -s  $x 2>/dev/null| grep -E -e ' '$arg_to_chk'$' -e ' '$arg_to_chk'@'`; if [ ! -z "$tmp_z" ]; then printf "%s :- %s\n" "$x" "$tmp_z";finded_chk=$((finded_chk+1)); fi; done; printf "\n## Total finded: %d\n\n" $finded_chk;

finded_chk=0; for x in $( find -type f ); do tmp_z=`readelf -s  $x 2>/dev/null| grep -E -e ' '$arg_to_chk'$' -e ' '$arg_to_chk`; if [ ! -z "$tmp_z" ]; then printf "%s :- %s\n" "$x" "$tmp_z";finded_chk=$((finded_chk+1)); fi; done; printf "\n## Total found: %d\n\n" $finded_chk;
