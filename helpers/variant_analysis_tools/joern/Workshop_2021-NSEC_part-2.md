
## 2021-NSEC workshop notes (part 2)

 - building your own security tools with Joern

 - before initializing, install the requirementes

 - Machine Requirements
    * OpenJDK 1.8+

 - Important Links
    * [Joern Docs](https://docs.joern.io)
    * [Joern Queries](https://queries.joern.io)
    * [Joern Community](https://discord.gg/AUzy45EHdf)

 - Instead of thttpd-2.29 package, apply the research to https://github.com/libjpeg-turbo/libjpeg-turbo/releases

 - Before launching joern allow the JVM to use 4 gigabytes of RAM
```
export _JAVA_OPTS="-Xmx4G"
```

 - [downloaded repo](workshops_repo/2021-NSEC)


### Hunting memory bugs

#### Example-1

 - Consider the example [workshops_repo/2021-NSEC/alloc_party/](workshops_repo/2021-NSEC/alloc_party/)

 - we initialize the cpg:
```
importCode("workshops_repo/2021-NSEC/alloc_party")

run.ossdataflow
save
```

 - So we start with the following analysis:
```
// The location where malloc has an arithmetic operation
cpg.call("malloc").where(_.argument(1).isCallTo(Operators.multiplication)).code.l

// Identify if there is a call from some method to any of these weird mallocs (define functions)
def source = cpg.method.name(".*alloc.*").parameter
def sink = cpg.call("malloc").where(_.argument(1).isCallTo(Operators.multiplication)).argument

sink.reachableByFlows(source).p

```


#### Exercise-2

 - Write a query to find a double free the sample code
    * (Hint: Dataflow from allocation to freedom)

```
def source = cpg.call("free").argument
def sink = cpg.call("free").argument
sink.reachableByFlows(source).p

```


### Finding Vulnerabilities in VLC

```
// check the workspace, if the project was already imported, then use `open` instead of importCode
open("vlc-3.0.12")
run.ossdataflow

// Find the memcpy() calls where return value of calls from malloc having addition operations reaches the first argument of the memcpy
def src = cpg.call("malloc").where(_.argument(1).isCallTo(Operators.addition)).l
cpg.call("memcpy").where(call => call.argument(1).reachableBy(src)).code.l


// Find dataflows from all these interesting sources and sinks
def source = cpg.call("malloc").where(_.argument(1).isCallTo(Operators.addition))
def sink = cpg.call("memcpy").argument
sink.reachableByFlows(source).p

// note: the difference between `reachableBy` e `reachableByFlows` is that the latter prints out a nice table to illustrate the results, 
// while the first one returns true or false

```

#### molt version

```
def source = cpg.call("malloc").where(_.argument(1).isCallTo(Operators.multiplication)).whereNot(_.code(".*malloc\\(sizeof.*")q).l
// non so perchè alcune sizeof le fa vedere anche se le filtro
// filtriamo sizeof, perché di solito non introducno vuln, se invece controlliamo entrambi i coeff allora magari si

def sink = cpg.call("memcpy").argument
sink.reachableByFlows(source).p

```



### Joern scripting

```
// Wrap possible buffer overflow query in a function and use it!
def buffer_overflows(cpg : io.shiftleft.codepropertygraph.Cpg) = {

  def src = cpg.call("malloc").where(_.argument(1).isCallTo(Operators.addition)).l
  cpg.call("memcpy").where( call => call.argument(1).reachableBy(src) )

}

buffer_overflows(cpg).code.l


// we find possible overflow, we need to compare the size etc.
// ci accontentiamo per l'esempio.
```

 - The workshop shows the vuln in VLS with the following characteristics
```
joern> buffer_overflows(cpg).where(_.method.name(".*ParseText.*")).l.dump

res57: List[String] = List(
"""static subpicture_t *ParseText( decoder_t *p_dec, block_t *p_block )
{

[...]

  psz_subtitle = malloc( p_block->i_buffer + 1 );
  if( psz_subtitle == NULL )
    return NULL;
  memcpy( psz_subtitle, p_block->p_buffer, p_block->i_buffer ); /* <=== here vuln, if p_block->i_buffer == max_uint64 or 32, then malloc(0) return less-size chunk */
[...]
```



 - How to reuse this query in future?
    * save the following text as mytools.sc in /home/$USER/bin/joern (or where's your installation files folder)
```
def buffer_overflows(cpg : io.shiftleft.codepropertygraph.Cpg) = {

  def src = cpg.call("malloc").where(_.argument(1).isCallTo(Operators.addition)).l
  cpg.call("memcpy").where( call => call.argument(1).reachableBy(src) ).code.l
}
```
    * then run
```
// import your script
import $file.mytools

mytools.buffer_overflows(cpg) // run the script from within Joern Shell!
```


#### Scripting - Creating External Standalone Tools
```
// save the following text as buffer_overflows.sc in /home/$USER/bin/joern
// You can replace the open(graph) with other commands like importCode() to work on
// fresh code. You could generate JSONs also, create reports etc..

@main def execute(graph: String) = {
  open(graph)
  println("Finding possible buffer overflows")
  def src = cpg.call("malloc").where(_.argument(1).isCallTo(Operators.addition)).l
  cpg.call("memcpy").where { call =>
    call.argument(1)
    .reachableBy(src)
  }.code.l
}
```

 - Run externally as your own tool
```
$ joern --script buffer_overflows.sc --params graph=vlc-3.0.12
```


### Building Custom Scanners

 - example of scanner code, https://github.com/Forescout/namewreck/blob/main/joern-queries/queries/DNSVulnCodeSmells.sc
    * The code property graph for the target is generated.
    * A set of queries are executed against the code property graph.
    * Results are printed to stdout.
```
$ joern-scan /file/to/scan
Result: 3.0 : Unchecked read/recv/malloc:/tarpit-c/tarpitc/double_free.c:10:main

// Result format:
// Result: $QUERY_SCORE : $QUERY_TITLE: $FILEPATH:$LINE_NUMBER:$FUNCTION_NAME
```

 
