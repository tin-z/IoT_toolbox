

 - ref, https://www.youtube.com/watch?v=hfxCDx9BTLo

### Ghidra2cpg

 - extends Joern, imports ghidra disassemblies into joern
    * the purpose was to give a computational time of a polynomial order for the data flow analysis for binary

 - still under (open) development



### Marking attack surface

 - in the cheaper router, http-related operations were managed by using the library mongoose
    * those functions were starting with `mg_<function>`

 - we can mark the attack surface by tagging nodes
```
cpg.call("mg_.*").method
  .repeat(_.callee.internal)(_.emit.times(10))   // after we found method calling mg_.*, we want all the called methods (no-external) do this 10-times
  .newTagNode("attacksurface").store

run.commit // or save, not sure

```

 - Now we search for buffer overflow on strncpy/memcpy that are part of the attack surface (reachable by us in this sense)

```
cpg.call("strncpy|memcpy")
  .whereNot(_.argument(3).isLiteral)            // ignore constants
  .where(_.argument(1).code(".*Stack.*")        // only stack data
  .where(_.method.tag.name("attack_surface"))

```


### Quick and dirty rop using Joern

 - usally IoT firmwars have no-canary and base image at a fixed address
 - the following joern/scala script dumpo gadgets up to length 5 to a file

```
// gadget.sc
def instrBefore(x : CfgNode, n: Int) {
  x.cfgPrev(n).l.reverse.map(y => y.address.get + ": " + y.code)
}

cpg.reg.map(x => instrBefore(x, 5).mkString("|\r") + "\n").l ¦> "/tmp/lol123/gadgets.txt"

```

 - then we exec
```
script("gadget.sc")
```


### Interprocedural data-flow tracking

```
cpg.call("fopen")
  .argument(1).whereNot(_.isLiteral)
  .reachableByFlows(cpg.call("strcat"))
  .where(_.method.tag.name("attack_surface"))

```


### strcmp/strncmp

 - dump all strcmp/strncmp, maybe there are hardcoded creds

```
cpg.call("strcmp|strncmp")
  .whereNot(_.argument(1).isLiteral && _.argument(2).isLiteral)            // ignore constants
  .where(_.method.tag.name("attack_surface"))
  .dumpRaw ¦> "/tmp/lol123/strcmpss.c"

```


### Analyze the getenv calls

 - analyze the getenv and check if sprintf uses "%s" on the return value

``` 
cpg.call("getenv").method
  .repeat(_.callee.internal)(_.emit.times(10)) 
  .newTagNode("attacksurface").store

run.commit // or save, not sure

cpg.call("sprintf")
  .where(_.argument(2).isLiteral.code(".*%s.*"))
  .where(_.argument(1).code(".*Stack.*")        // only stack data
  .where(_.method.tag.name("attack_surface"))

```


### Come sapere se i parametri passati in una funzione sono anche usati nel metodo

```
cpg.call("sprintf").where { sprintfCall =>
  def m = sprintfCall.method
  if(m.parameter.where(sprintfCall.argument(1).reachableBy(_)).size >= 1 &&
     m.parameter.where(sprintfCall.argument(3).reachableBy(_)).size >= 1) {     // note: if the format string arg is a literal
    m                                                                           // then we should interpret it, and understand how many arguments it will take so we adapt
  } else {                                                                      // the check, otherwise we could miss info
    None
  }
}




