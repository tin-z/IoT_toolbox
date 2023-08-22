#!/usr/bin/env bash

# Distributed under the MIT License (MIT)
# Copyright (c) 2023, Altin (tin-z)


VER=0.1

C_RED="\x1b[31m"
C_YLL="\x1b[33m"
C_RST="\x1b[0m" 
C_x="$C_RED[x]$C_RST"
C_y="$C_YLL[-]$C_RST"


title="BinAbsInspector"
outputfp="output_${title}.log"
index=0
timeout_origin=$(( 60 * 10 ))
project_folder="ghidra_tmp_prj"
tmp_mainaddress_file="bininsp_main.txt"




function _help(){
  echo "# Run $title on the binaries present, starting from the given working directory"
  echo "# Output saved on the file $outputfp"
  echo "#"
  echo "# Usage: ./$0 [--help|--version|--lib|--kernel|--main] <path_to_check>"
  echo "#"
  echo "# req: "
  echo "#   - https://github.com/fkie-cad/cwe_checker"
  echo "#"
  echo "# options:"
  echo "#  --help     this message"
  echo "#  --version  print version and quit"
  echo "#  --lib      Don't skip shared libraries (By default we ignore ELF libraries)"
  echo "#  --kernel   Don't skip kernel modules (By default we ignore .ko ELFs)"
  echo "#  --main     ${title} needs main address as the entry point, skip those binares which do not export main function"
  echo "#"
  echo "# Manual configuration (you can change these values by modifying the script"
  echo "#  - \$outputfp=$outputfp : File for saving output"
  echo "#  - \$timeout=$timeout_origin : Maximum time of execution for each binary"
  echo "#  - \$index=$index : Ignore the (\$index-1)-file before actually starting ${title} analysis"
  echo "#  - \$project_folder=$project_folder : folder where to save temporary projects (the folder is created under '/tmp')"
  echo "#"
}


### check routine
continueX=1
lib=0
kernel=0
main=0
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

--main)
  main=1
;;


*)
esac

if [ $continueX == 0 ]; then
  echo "Quit"
  echo ""
  exit 0
fi


if [ -z "`which file`" ]; then
  echo "Can't find 'file' command ...quit"
  exit 1
fi



## function declarations

function is_elf(){
  echo `file "$1" | egrep "ELF (32|64)\-bit"`
};

function log_tee(){
  echo "$1" | tee -a "$outputfp"
};

function get_main_address() {
  tmp123=`nm -D "$1" | grep -E "[a-Z0-9]+ [a-Z] main" | cut -d' ' -f1`
  if [ ! -z "$tmp123" ]; then
    echo "0x$tmp123"
  fi
}


echo "" >> $outputfp
echo "$title" >> $outputfp
log_tee "[-] Start `date`"



fileZ=( `find -type f` )
lenZ=${#fileZ[@]}
elf_parsed=0
elf_done=0
i=0
timeout=$timeout_origin
mkdir -p "/tmp/$project_folder"

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

      # Note: Before we got main addresses by using 'nm' command, which if PIC it does return offset without baseaddress
      #
      #main_addr=`get_main_address "$x"`
      #tail_arg="\"@@ -all -entry $main_addr\""
      #if [ -z $main_addr ] ; then
      #  log_tee "# Can't find entry point of $x  ...let's $title finding it"
      #  tail_arg="\"@@ -all\""
      #  if [ $main == 1 ]; then
      #    let i++
      #    continue
      #  fi
      #fi

      analyzeHeadless "/tmp/$project_folder" tmp -overwrite -deleteproject -import "$x" -postScript "`dirname $0`/print_main.py" "@@ --folder /tmp/${project_folder}" > /dev/null

      main_addr=`cat /tmp/${project_folder}/$tmp_mainaddress_file`
      if [ -z $main_addr ] ; then
        log_tee "# Can't find entry point of $x  ...quit"
        let i++
        continue
      fi
      tail_arg="\"@@ -all -entry $main_addr\""

      # for some reasons it's better to let ghidra re-analyzing target and so leave the params "-overwrite -deleteProject" there
      timeout $timeout bash -c "analyzeHeadless \"/tmp/${project_folder}\" tmp -overwrite -deleteProject -import \"$x\" -postScript BinAbsInspector ${tail_arg} >> $outputfp"

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


