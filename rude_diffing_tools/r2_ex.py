# Distributed under the MIT License (MIT)
# Copyright (c) 2023, Altin (tin-z)

import sys

sys.path.append(".")
import r2pipe

def list_imported_functions(r2):
    imported_functions = []
    counters = {}
    imports = r2.cmdj("iij")

    for imp in imports:
        imported_functions.append(imp["name"])
        if check_counter and imp["type"] == "FUNC" :
          cc = len(r2.cmdj(f"axtj @ sym.imp.{imp['name']}"))
          counters.update({imp["name"]:cc})

    return imported_functions, counters



def main(binary_file, binary_file_2):
    # Open the binary file using r2pipe.
    r2 = r2pipe.open(binary_file)
    if check_counter :
      r2.cmd("aa")

    imported_functions_1, counters_1 = list_imported_functions(r2)
    r2.quit()

    r2 = r2pipe.open(binary_file_2)
    if check_counter :
      r2.cmd("aa")

    imported_functions_2, counters_2 = list_imported_functions(r2)
    r2.quit()

    funzioni_tolte = sorted(list(set(imported_functions_1) - set(imported_functions_2)))
    funzioni_aggiunte = sorted(list(set(imported_functions_2) - set(imported_functions_1)))

    print(
      "Funzioni Tolte:\n  " +\
      "\n  ".join(funzioni_tolte) +\
      "\n\n" +\
      "Funzioni Aggiunte:\n  " +\
      "\n  ".join(funzioni_aggiunte) +\
      "\n\n"
    )

    if check_counter :
      counter_delta = {}
      for fname in sorted(list(set(imported_functions_1).intersection(set(imported_functions_2)))) :
        if fname not in counters_1 or fname not in counters_2 :
          continue
        cc1 = counters_1[fname]
        cc2 = counters_2[fname]
        if cc1 != cc2 :
          counter_delta.update({fname:cc1 - cc2})

      print(
        "Funzioni importate con delta:\n  " +\
        "\n  ".join([f"{x}: {y}" for x,y in counter_delta.items()]) +\
        "\n\n" 
      ) 


if __name__ == "__main__":
    if len(sys.argv) < 3 :
      print(f"usage: {sys.argv[0]} [--check_counter] <binary-path> <binary-path>")
      sys.exit(0)

    check_counter = "--check_counter" == sys.argv[1]
    if check_counter :
      sys.argv = sys.argv[1:]

    main(sys.argv[1], sys.argv[2])
    print("[+] Done")

