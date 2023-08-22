#!/usr/bin/env python
# -*- coding: UTF-8 -*-

# Distributed under the MIT License (MIT)
# Copyright (c) 2023, Altin (tin-z)


import re, sys
import argparse


desc = """ DESC #TODO """

regex_1 = "[rwxst-]"
regex_exec = r"[^dls]([r-][w-][xs][r-][w-][xs][r-][w-][xs-])"

def match(lst, regex):
  output = []
  for x in lst :
    if re.search(regex, x) :
      output.append(x)
  return output

def match_suid(lst):
  return match(lst, "([r-][w-][s]"+regex_1+"{6}) ")

def match_writable(lst, who="other"):
  regex = {"user":   "([r-][w]"+regex_1+"{7}) " ,\
   "group":  "("+regex_1+"{3}[r-][w]"+regex_1+"{4}) " ,\
   "other":  "("+regex_1+"{6}[r-][w]"+regex_1+") "
  }[who]
  return match(lst, "[^dls]"+regex)


def match_executable(lst):
  return match(lst, regex_exec)


def match_gtfo(lst, gtfo_filename):
  output = []
  with open(gtfo_filename, "r") as fp :
    rets = [ x.strip() for x in fp.read().split("\n") if not x.startswith("#") and x != '' ]

    for x in rets :
      rets2 = [ l for l in lst if " {}".format(x) in l ]
      if len(rets2) > 0 :
        output.append((x, rets2))
  return output


def match_debugtool(lst, debugtool_filename):
  output = []
  with open(debugtool_filename, "r") as fp :
    rets = [ x.strip() for x in fp.read().split("\n") if not x.startswith("#") and x != '' ]

    # TODO: add some regex and optimize strategy
    
    lst = [ x for x in lst if " lib" not in x ]
    # if len is < 3, then find the exact string
    rets_min = [ x for x in rets if len(x) < 3 ]
    rets = [ x for x in rets if len(x) >= 3 ]

    for x in rets :
      rets2 = [ l for l in lst if x in l ]
      if len(rets2) > 0 :
        output.append((x, rets2))
    for x in rets_min :
      rets2 = [ l for l in lst if " {}".format(x) in l ]
      if len(rets2) > 0 :
        output.append((x, rets2))

  return output





if __name__ == "__main__" :
  parser = argparse.ArgumentParser(formatter_class=argparse.RawDescriptionHelpFormatter, description=desc)
  parser.add_argument('-i', '--input', required=True, help="File containing the output gained by executing the command `ls -l -R /` OR `file list recursive /` in case of JunOS CLI")
  parser.add_argument('-g', '--gtfo', required=True, help="""This file does contain the escapeable binary files as reported by https://gtfobins.github.io, example:
  $ cat gtfo.txt
  # comment
  # https://gtfobins.github.io/
  apt-get
  apt
  ar
  aria2c
  arp
  ash""")
  parser.add_argument('-d', '--debugtool', required=True, help="""This file does contain the names of several debugging tool that should not be available on a production software image, example:
  $ cat debugtool.txt
  # comment
  gdb
  gdbserver
  tcpdump""")

  args = parser.parse_args()

  try :
    lst_pre_debug_match = [x.strip() for x in open(args.input, "r").read().split("\n")] 
    lst = [ x for x in lst_pre_debug_match if "root" in x or "wheel" in x ]
  except :
    print("Usage: {} <output-find-command-on-root>".format(sys.argv[0]))
    sys.exit(-1)

  who = "other"
  print("\n## 1. Check file with root owner and that are writable by {} user".format(who))
  lst_2 = match_writable(lst, who)
  for x in lst_2 :
    print(x)

  lst = match_executable(lst)
  print("")
  print("\n## 2.1 Check suid routine")
  lst_2_2 = match_suid(lst)
  lst_2 = match_gtfo(lst_2_2,args.gtfo)
  for gtfo_i, candidates in lst_2 :
    print("#># {}".format(gtfo_i))
    print("\n".join(candidates))
    print("https://gtfobins.github.io/gtfobins/{}/\n".format(gtfo_i))

  print("")
  print("\n## 2.2 Check other suid files that maybe contains vuln")
  print("\n".join(lst_2_2))

  print("")
  print("\n## 3. Check if debugging tools are present")
  lst_2 = match_debugtool(lst_pre_debug_match, args.debugtool)
  for debug_i, candidates in lst_2 :
    print("\n#># {}".format(debug_i))
    print("\n".join(candidates))



