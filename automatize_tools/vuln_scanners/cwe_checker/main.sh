#!/usr/bin/env bash

# Distributed under the MIT License (MIT)
# Copyright (c) 2023, Altin (tin-z)

VER=0.1

C_RED="\x1b[31m"
C_YLL="\x1b[33m"
C_RST="\x1b[0m" 
C_x="$C_RED[x]$C_RST"
C_y="$C_YLL[-]$C_RST"


title="cwe_checker"
outputfp="output_${title}.log"
index=0
timeout_origin=$(( 6 * 60 ))


function _help(){
  echo "# Run $title on the binaries present, starting from the given working directory"
  echo "# Output saved on the file $outputfp"
  echo "#"
  echo "# Usage: ./$0 [--help|--version|--lib|--kernel] <path_to_check>"
  echo "#"
  echo "# req: "
  echo "#   - https://github.com/fkie-cad/cwe_checker"
  echo "#"
  echo "# options:"
  echo "#  --help     this message"
  echo "#  --version  print version and quit"
  echo "#  --lib      Don't skip shared libraries (By default we ignore ELF libraries)"
  echo "#  --kernel   Don't skip kernel modules (By default we ignore .ko ELFs)"
  echo "#"
  echo "# Manual configuration (you can change these values by modifying the script"
  echo "#  - \$outputfp=$outputfp : File for saving output"
  echo "#  - \$timeout=$timeout_origin : Maximum time of execution for each binary"
  echo "#  - \$index=$index : Ignore the (\$index-1)-file before actually starting cwe_checker analysis"
  echo "#"
}


### check routine
continueX=1
lib=0
kernel=0
case $1 in

--help)
  _help
  continueX=0
;;

--version)
  echo "# $0:$VER"
  continueX=0
;;

--lib)
  lib=1
;;

--kernel)
  kernel=1
;;


*)
esac

if [ $continueX == 0 ]; then
  echo "Quit"
  echo ""
  exit 0
fi


## function declarations

function is_elf(){
  echo `file "$1" | egrep "ELF (32|64)\-bit"`
};

function log_tee(){
  echo "$1" | tee -a "$outputfp"
};


echo "" >> $outputfp
echo "$title" >> $outputfp
log_tee "[-] Start `date`"



fileZ=( `find -type f` )
lenZ=${#fileZ[@]}
elf_parsed=0
elf_done=0
i=0
timeout=$timeout_origin

while [ $i -lt $lenZ ]; do

  x="${fileZ[$i]}"

  if [ ! -z "`is_elf $x`" ]; then
   
    (( elf_parsed += 1 ));

    if [ $lib == 0 ] && [ "`basename \"$x\" | grep -E '^lib'`" ] ; then
      let i++
      continue
    fi
    
    if [ $kernel == 0 ] && [ "`basename \"$x\" | grep -E '.*\.ko$'`" ] ; then
      let i++
      continue
    fi
    
    if [ $elf_parsed -ge $index ]; then

      log_tee "# $elf_parsed-File: $x"

      if [ ! -z `echo "$x" | grep -E "\.cgi$"` ]; then
        timeout=$(( 30 * 60 ))
      fi

    	timeout $timeout bash -c "cwe_checker $x >> $outputfp"

      timeout=$timeout_origin

     	if [ $? -eq 0 ]; then
        (( elf_done += 1 ));
        log_tee "# [`date`] Done file: $x"

      else
        log_tee "# [`date`] Fail file: $x"
      fi

      echo ""  >> $outputfp
    fi
  fi

  let i++

done

log_tee "# RESULT: Elf parsed:$elf_parsed (done:$elf_done)"
log_tee "[+] Done `time`"


