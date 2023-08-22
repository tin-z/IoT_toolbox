#!/bin/bash

# Distributed under the MIT License (MIT)
# Copyright (c) 2023, Altin (tin-z)

# depends: 
# usage: ./find_dep_lib.sh <library>
# output: all binary that depends by <library>


arg_to_chk=$1
printf "\n## searching binary files dependent to:%s\n\n" $arg_to_chk
## accept call
finded_chk=0; for x in $( find -type f ); do tmp_z=`readelf -d  $x 2>/dev/null| grep 'Shared library: ' | grep $arg_to_chk `; if [ ! -z "$tmp_z" ]; then printf "%s :- %s\n" "$x" "$tmp_z";finded_chk=$((finded_chk+1)); fi; done; printf "\n## Total found: %d\n\n" $finded_chk;

