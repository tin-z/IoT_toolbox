#!/bin/bash

if [ -z "$1" ]; then
  echo "Usage: $0 <file-string.log>"
  exit 255
fi

export OUTPUT_LOG="$1"
export OUTPUT_LOG_STR="${OUTPUT_LOG}.distrib"

cat $OUTPUT_LOG | 
  sed -r "s/\x1B\[([0-9]{1,3}(;[0-9]{1,2})?)?[mGK]//g" | 
  sed "s/:/@-MATCH-@/" |
  sed "s/\(.*\)@-MATCH-@\(.*\)/\2/" | 
  sed -e "s/\t/ /g" -e "s/^[ ][ ]*//" | 
  sort | 
  uniq -c |
  sed -e "s/\t/ /g" -e "s/^[ ][ ]*//" | 
  sort -h > "$OUTPUT_LOG_STR"

echo "# Done. Output saved in $OUTPUT_LOG_STR"

