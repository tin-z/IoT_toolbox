
## 2021-NSEC workshop notes (part 1)

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


### CPG
 - More detail about Code property graph: https://github.com/ShiftLeftSecurity/codepropertygraph
    * the video uses an older version https://github.com/ShiftLeftSecurity/codepropertygraph/tree/v1.3.153

 - Here are some simple traversals to get all the base nodes. Running all of these without errors is a good test to ensure that your cpg is valid:
```
cpg.literal.toList
cpg.file.toList
cpg.namespace.toList
cpg.types.toList
cpg.methodReturn.toList
cpg.parameter.toList
cpg.member.toList
cpg.call.toList
cpg.local.toList
cpg.identifier.toList
cpg.argument.toList
cpg.typeDecl.toList
cpg.method.toList

```

 - The base schema provides the minimum requirements all valid CPGs must satisfy. The base specification is concerned with three aspects of the program:
    * Program structure
    * Type declarations
    * Method declarations

 - There are 19 node types across five categories:

| **Category** | **Names** |
| - | - |
| Program structure | FILE, NAMESPACE_BLOCK |
| Type declarations | TYPE_DECL, TYPE_PARAMETER, MEMBER, TYPE, TYPE_ARGUMENT |
| Method header | METHOD, METHOD_PARAMETER_IN, METHOD_RETURN, MODIFIER |
| Method body | LITERAL, IDENTIFIER, CALL, RETURN, METHOD_REF, LOCAL, BLOCK |
| Meta data | META_DATA |


 - There are eight edge types:

| **Name** | **Usage** |
| - | - |
| AST | Syntax tree edge - structure |
| CFG | Control flow edge - execution order and conditions |
| REF | Reference edge - references to type/method/identifier declarations |
| EVAL_TYPE | Type edge - attach known types to expressions |
| CALL | Method invocation edge - caller/callee relationship |
| VTABLE | Virtual method table edge - represents vtables |
| INHERITS_FROM | Type inheritance edge - models OOP inheritance |
| BINDS_TO | Binding edge - provides type parameters |


 - There are 17 node keys across three categories:

| **Category** | **Names** |
| - | - |
| Declarations | NAME, FULL_NAME, IS_EXTERNAL |
| Method header | SIGNATURE, MODIFIER_TYPE |
| Method body | PARSER_TYPE_NAME, ORDER, CODE, DISPATCH_TYPE, EVALUATION_STRATEGY,LINE_NUMBER, LINE_NUMBER_END, COLUMN_NUMBER,COLUMN_NUMBER_END, ARGUMENT_INDEX |
| Meta data | LANGUAGE, VERSION |


### Demo-time

 - after importing the project, we do basic data flow analysis using `run.ossdataflow`
    * after so do `save`
```
importCode("libjpeg-turbo-2.1.2")
run.ossdataflow
save
```

 - search for 'parse' methods
```
cpg.method.name(".*parse.*").name.l
```

 - If we want to dump al the methods
```
cpg.method.name(".*parse.*").dumpRaw |> "/tmp/lol123/foo.c"
```

 - Use the interactive command `browse(<joern cmd>)` to output the result in less-style command


#### More about methods' variables

```
// Find all local variables defined in a method
joern> cpg.method.name("parse_public_key_packet").local.name.l

// Find which file and line number they are in
joern> cpg.method.name("parse_public_key_packet").location.map( x=> (x.lineNumber.get, x.filename)).l

// Find the type of the first local variable defined in a method
joern> cpg.method.name("parse_public_key_packet").local.typ.name.l.head


// Find all outgoing calls (call-sites) in a method             <--- note, assignement, block structure, field access, are considered call to methods
joern> cpg.method.name("parse_public_key_packet").call.name.l
joern> cpg.method.name(".*parse.*").call.filterNot(_.name.contains("<operator>")).name.l
joern> cpg.method.name(".*parse.*").call.whereNot(_.name("<operator>.*")).name.l


// Find which methods calls a given method
joern> cpg.method.name("parse_public_key_packet").caller.name.l
joern> cpg.method.name("parse_public_key_packet").caller.caller.name.l
joern> cpg.method.name("parse_public_key_packet").caller.caller.caller.name.l

// and so on ...


// Repeating nodes
// Find the sequence of callers going UP from a given method
joern> cpg.method.name("parse_public_key_packet").repeat(_.caller)(_.emit).name.l

// Find the callees of a method going DOWN until you hit a given method, in this case "parse_public_key_packet"
// Note: CAN BE EXPENSIVE
joern> cpg.method.name("download_key").repeat(_.callee)(_.emit.until(_.isCallTo("parse_public_key_packet"))).name.l


```

#### Types, Variables and Filtering

```
// FInd all local variables of this type `vlc_.*`
joern> cpg.types.name("vlc_.*").localOfType.name.l

// Find member variables of a struct
joern> cpg.types.name("vlc_log_t").map( x=> (x.name, x.start.member.name.l)).l

// Find local variables and filter them by their type
joern> cpg.local.where(_.typ.name("vlc_log_t")).name.l

// Which method are they used in?
joern> cpg.local.where(_.typ.name("vlc_log_t")).method.dump

// Get the filenames where these methods are
joern> cpg.local.where(_.typ.name("vlc_log_t")).method.file.name.l

```


#### Code Complexity

```
// Identify functions with more than 4 parameters
joern> cpg.method.filter(_.parameter.size > 4).name.l

// Identify functions with >4 control structures (cyclomatic complexity)
joern> cpg.method.filter(_.controlStructure.size > 4).name.l

// Identify functions with more than 500 lines of code
joern> cpg.method.filter(_.numberOfLines >= 500).name.l

// Identify functions with multiple return statements
joern> cpg.method.filter(_.ast.isReturn.l.size > 1).name.l

// Identify functions with more than 4 loops
joern> cpg.method.filter(_.controlStructure.controlStructureType("FOR|DO|WHILE").size > 4).name.l

// Identify functions with nesting depth larger than 3
joern> cpg.method.filter(_.depth(_.isControlStructure) > 3).name.l

```


#### Calls into Libraries

```
// All names of external methods used by the program (uniq and sorted)
joern> cpg.method.external.name.l.distinct.sorted

// All calls to str-type functions
joern> cpg.call("str.*").code.l

// All methods that call str-type functions
joern> cpg.call("str.*").method.name.l

// Looking into parameters: second argument to sprintf is NOT a literal
joern> cpg.call("sprintf").argument(2).whereNot(_.isLiteral).code.l

// Quickly see this method above
joern> cpg.call("sprintf").argument(2).filterNot(_.isLiteral).dump

```


### Exercises


#### Ex.1
 - Create a query that finds recursive functions (e.g. Funcion A,  A -> A)
```
joern> cpg.method.filter( x => ! x.call.id(x.id).isEmpty ).name.l 
```



#### Ex.1 Extra

 - find method calling sprintf with the format string argument variable
```
cpg.call("sprintf").argument(2).filterNot(_.isLiteral).dump
// ...
```

 - Now we dumped the method name, we could do ast and traverse parent until we reach a function node, but for simplicity we only consider directly the name's func
    * that is 'format_message'
```
cpg.method("format_message").l
// select the right id and save it to idnow var
```
    * Print if and how it's reachable from the node main
```
var idnow = 3074457345618314260L
cpg.method.id(idnow).repeat(_.caller)(_.emit).name.l

// esce fuori la funzione stessa
// ciò fa vedere i limiti di Joern, informazione incompleta?

// guardando il sorgente si vede che la funzione non viene chiamata direttamente da nessuna funzione
// Ma viene inserita in una vtable di una struttura dati, bisognerebbe usare taint analysis
```




