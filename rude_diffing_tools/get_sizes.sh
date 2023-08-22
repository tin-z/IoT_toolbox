#!/bin/bash

# Distributed under the MIT License (MIT)
# Copyright (c) 2023, Altin (tin-z)


# depends by script find_symbols.sh
# usage: ./get_sizes.sh symbol
# output: name and size of all binary that import/export that symbol
# option:


awk '{print($2,"\t",$1)}' <( for x in $( ./find_symbols.sh $1 | grep -E -ve "^#" -ve "^ " | sed -e "s/\(\..*\) :-.*/\1/g" ); do du -h $x; done ) | sort | sed -e "s/\t//g"
