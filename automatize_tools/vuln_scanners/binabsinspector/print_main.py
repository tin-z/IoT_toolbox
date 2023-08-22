# ref https://github.com/HackOvert/GhidraSnippets#get-a-function-address-by-name
import sys

default_folder="/tmp/ghidra_tmp_prj"
default_output="bininsp_main.txt"

if "--folder" in sys.argv :
    default_folder=sys.argv[-1]

with open("{}/{}".format(default_folder, default_output), "w") as fp :
    fp.write("")

name = "main"
funcs = getGlobalFunctions(name)
for func in funcs :
    addr = func.getEntryPoint().getOffset()
    if addr != 0 :
        with open("{}/{}".format(default_folder, default_output), "w") as fp :
            fp.write("0x{:x}".format(addr))
        break

