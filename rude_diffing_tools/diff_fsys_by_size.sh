#!/bin/bash

# Distributed under the MIT License (MIT)
# Copyright (c) 2023, Altin (tin-z)


echo "Diff folderA to folderB"
echo ""
echo "Requirements:"
echo " - du"
echo " - vimdiff"
echo ""
echo "Usage: $0 <folderA> <folderB> [grep-on-line]"
echo ""


if [ -z "$1" ]; then
  echo "Missing <folderA>"
  exit -1
fi

if [ -z "$2" ]; then
  echo "Missing <folderB>"
  exit -1
fi

export GRPMatch=0
if [ ! -z "$3" ]; then
  export GRPMatch=1
fi



if [ $GRPMatch -eq 1 ]; then
  vimdiff <( cd "$1" && find -type f | egrep "$3" | sort | while read x; do echo "$x" `du "$x" | sed -E "s/\t+/ /g" | cut -d ' ' -f 1`; done ) <(cd "$2" && find -type f | egrep "$3" | sort | while read x; do echo "$x" `du "$x" | sed -E "s/\t+/ /g" | cut -d ' ' -f 1`; done)
else
  vimdiff <( cd "$1" && find -type f | sort | while read x; do echo "$x" `du "$x" | sed -E "s/\t+/ /g" | cut -d ' ' -f 1`; done ) <(cd "$2" && find -type f | sort | while read x; do echo "$x" `du "$x" | sed -E "s/\t+/ /g" | cut -d ' ' -f 1`; done)
fi


