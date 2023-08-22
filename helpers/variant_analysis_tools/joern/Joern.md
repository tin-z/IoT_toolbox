
### Req

 - Machine Requirements
    * OpenJDK 1.8+

 - Important Links
    * [Joern Docs](https://docs.joern.io)
    * [Joern Queries](https://queries.joern.io)
    * [Joern Community](https://discord.gg/AUzy45EHdf)


 - Note, if you have issue with the java version, e.g.
```
    Class has been compiled by a more recent version of the Java Environment
    (class file version 53.0), this version of the Java Runtime only recognizes
    class file versions up to 52.0.
```
 - Then change the version's java on your computer, refer to
```
49 = Java 5
50 = Java 6
51 = Java 7
52 = Java 8
53 = Java 9
54 = Java 10
55 = Java 11
56 = Java 12
57 = Java 13
58 = Java 14
```

 - Before launching joern allow the JVM to use 4 gigabytes of RAM
```
export _JAVA_OPTS="-Xmx4G"
```


### Joern: Intro
 - The core features of Joern are:

    * Robust parsing. Joern allows importing code even if a working build environment cannot be supplied or parts of the code are missing. TOOOP!

    * Code Property Graphs. Joern creates semantic code property graphs from the fuzzy parser output and stores them in an in-memory graph database. 
       > SCPGs are a language-agnostic intermediate representation of code designed for query-based code analysis.

    * Taint Analysis. Joern provides a taint-analysis engine that allows the propagation of attacker-controlled data in the code to be analyzed statically.

    * Search Queries. Joern offers a stronly-typed Scala-based extensible query language for code analysis based on Gremlin-Scala. 
       > This language can be used to manually formulate search queries for vulnerabilities as well as automatically infer them using machine learning techniques.

    * Extendable via CPG passes. 
       > Code property graphs are multi-layered, offering information about code on different levels of abstraction. 
       > Joern comes with many default passes, but also allows users to add passes to include additional information in the graph, 
         and extend the query language accordingly.

### Quickstart
 - Example
```
// X42.c
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
int main(int argc, char *argv[]) {
  if (argc > 1 && strcmp(argv[1], "42") == 0) {
    fprintf(stderr, "It depends!\n");
    exit(42);
  }
  printf("What is the meaning of life?\n");
  exit(0);
}
```

 - Open joern, then execute `importCode(inputPath="./X42.c", projectName="x42-c")`


#### Querying the Code Property Graph
 - You are ready to analyze your first program using Joern and the Code Property Graph. 
 - Code analysis in Joern is done using the CPG query language, a domain-specific language (DSL) designed specifically to work with the Code Property Graph. 
    * It contains practical representations of the various nodes found in the Code Property Graph, and useful functions for querying their properties 
      and relationships between each other. 
    * The top-level entry point into a Code Property Graph loaded in memory, and the root object of the query Language is cpg
```
joern> cpg 
res2: io.shiftleft.codepropertygraph.Cpg = io.shiftleft.codepropertygraph.Cpg@5852605c

joern> cpg.<TAB>  //it takes 2s
all                call               doBlock            graph              jumpTarget         method             parameter          throws             whileBlock
argument           close              elseBlock          help               literal            methodRef          ret                tryBlock
arithmetic         comment            file               id                 local              methodReturn       runScript          typ
assignment         continue           forBlock           identifier         member             namespace          switchBlock        typeDecl
break              controlStructure   goto               ifBlock            metaData           namespaceBlock     tag                typeRef
```


 - For more descriptive assistance, use the help command, like `> help.cpg`

 - Problem, the problem statement is "Show that an input exists for which the X42 program always writes a string to STDERR"
 - There are two parts in the problem statement: 
    1. does the program write anything to STDERR?
    2. if there is a call writing to STDERR, is it conditional on a value passed in as argument to the X42 program?

 - The point 1 is solved like
    * First, search for nodes of type CALL in the graph
    * Second, use the argument step to only select those calls which have connections to nodes of type ARGUMENT (they have at least an argument)
    * Third, use property filter on CODE property to select only those nodes that have the string stderr as the value of their CODE property
```
cpg.call.argument.code("stderr").toList
// This query shows that stderr is used somewhere in the program, but doesn't give us any more information.
```

 - Then
    * Using the query from the previous step, we can use the `astParent` construct to find out more about the surroundings of the stderr usage 
      by moving up the hierarchy of the abstract syntax tree that is part of the Code Property Graph. 
    * Moving up one level in the AST hierarchy gives us an fprintf call
```
cpg.call.argument.code("stderr").astParent.toList
...
code -> "fprintf(stderr, \"It depends!\\n\")",
...
```

 - The point 2 is solved like
    * First, As before, we can use the astParent, that in this case returns a block, not very helpful here
    * We go another layer up again, and this time we found the if condition aka ControlStructure object
```
cpg.call.argument.code("stderr").astParent.astParent.astParent.toList
// cpg.call.argument.code("stderr").astParent.astParent.astParent.toList.head.code
```

 - Close the project
    * unloads the Code Property Graph from memory. 
    * saves data on disk in the x42-c project you created earlier with importCode
```
close
```


### Code Property Graph
 - In summary:
    * code property graphs are directed, edge-labeled, attributed multigraphs, and we insist that each node carries at least one attribute that indicates its type.

 - The code property graph is a data structure designed to mine large codebases for instances of programming patterns. 
    * These patterns are formulated in a domain-specific language (DSL) based on Scala. It
    * Property graphs are a generic abstraction supported by many contemporary graph databases such as Neo4j, OrientDB, and JanusGraph.
    * Code property graphs are graphs, and more specifically property graphs. 

 -  A property graph is composed of the following building blocks:

    * Nodes and their types. Nodes represent program constructs. This includes low-level language constructs such as methods, variables, and control structures, 
      but also higher level constructs such as HTTP endpoints or findings. 
        > Each node has a type. 
        > The type indicates the type of program construct represented by the node
        > e.g., a node with the type METHOD represents a method while a node with type LOCAL represents the declaration of a local variable.

    * Labeled directed edges. Relations between program constructs are represented via edges between their corresponding nodes. 
        > For example, to express that a method contains a local variable, we can create an edge with the label CONTAINS from the method's node to the local's node. 
        > By using labeled edges, we can represent multiple types of relations in the same graph. Moreover, edges are directed to express, 

    * Key-Value Pairs. Nodes carry key-value pairs (attributes), where the valid keys depend on the node type. 
        > For example, a method has at least a name and a signature while a local declaration has at least the name and the type of the declared variable.


#### Query & Traversal Basics
 - Joern helps you discover security vulnerabilities by executing graph traversals on the Code Property Graph. 
 - A traversal is formulated as an Joern Query, or query for short. In this article, you will learn about the different components that make up queries.

 - A query consists of the following components:
    1. A Root Object, which is the reference to the Code Property Graph being queried
    2. Zero or more Node-Type Steps, which are atomic traversals to all nodes of a given type
    3. Zero or more Filter Steps, Map Steps or Repeat Steps
    4. Zero or more Property Directives, which reference the properties of nodes in a traversal
    5. Zero or more Execution Directives, which execute a traversal and return results in a specific format
    6. Zero or more Augmentation Directives, which extend a Code Property Graph with new nodes, properties, or edges

 - As an example, the query `cpg.method.name.toList`
    * returns all names of methods present in a Code Property Graph
    * `cpg` is the root object
    * `method` is a node-type step which references all METHOD nodes
    * `name` is a property directive which references the NAME property of those METHOD nodes

 - Example, perform traversal to all nodes of type METADA (there's only one): `cpg.metadata`
    * Note that the result is not the content of the METADATA node, but a traversal that visits the METADATA node. 
    * Traversals are more suitable than list/array because they are lazily evaluated (you can compose them and at some later point execute them)
    * To execute them we use the directive `toList`
    * Moreover, we could select a property directivies, such as the metdata node's language: `cpg.metaData.language.toList`



#### Node-Type Steps#

 - Node-Type Steps are atomic traversals that represent traversals to nodes of a given type. 
    * Each node-type step comes with distinct Property Directives to access the properties of the nodes they represent. 
    * A commonly used node-type step is method, which represents a traversal to all nodes of type METHOD
    * and one of their properties is NAME. All names of all method nodes can thus be determined as follows: `cpg.method.name.toList`
    * An abbreviation for .toList method is .l

 - In particular we're interested in node-type steps:
    * method
    * call
    * argument
    * parameter
    * metaData
    * local
    * literal
    * types
    * returns
    * identifier
    * namespace
    * namespaceBlock
    * methodReturn
    * typeDecl
    * member
    * methodRef
    * file
    * comment
    * tag
    * all (generic node)


##### Filter Steps

 - Filter Steps are atomic traversals that filter nodes according to given criteria. 

 1. (Filter) The most common filter step is aptly-named `filter` which continues the traversal in the step it suffixes for all nodes which pass its criterion. 
    * Its criterion is represented by a lambda function which has access to the node of the previous step and returns a boolean. 

 - Example, return all METHOD nodes, but only if their IS_EXTERNAL property is set to false: 
```
cpg.method.filter(_.isExternal == false).name.l
```
    * Oppure con lambda estesa  `cpg.method.filter((x:Method) => x.isExternal == false).name.l`


 2. (Property-Filter) There also exists `Property-Filter Step` which are Filter Steps and so behave the same way
    * Example, isExternal(false) is a property-filter step so we could do
```
cpg.method.isExternal(false).name.toList
```

 - other example, find all function name starting with 'print_'
    * We can use regex (not sure which type)
```
cpg.method.name("print_.*").name.l
```


 3. (Traversal to Traversal) A final Filter Step we will look at is named `where`.
    * Unlike filter, this doesn't take a simple predicate `A => Boolean`, but instead takes a `Traversal[A] => Traversal[_]`
    * I.e. you supply a traversal which will be executed at the current position. 
    * The resulting Traversal will preserves elements if the provided traversal has at least one result. 
    * The previous query that used a Property Filter Step can be re-written using where like so: 
```
cpg.method.where(_.isExternal(false)).name.toList
```


 4. (Map) Map Steps are traversals that map a set of nodes into a different form given a function. 
    * Example, map tuple (Boolean,name): 
```
cpg.method.map(node => (node.isExternal, node.name)).toList
```


 5. (Complex steps) Complex Steps combine many simpler steps into one in order to make your queries more concise. 
    * There are a number of them available, all with different behaviours
    * For example `isConstructor`

 - Two useful Complex Steps are `astParent` and `astChildren`, which allow you to steer your traversals through the abstract syntax tree of the program under analysis
    * Example, query that returns the CODE property for all nodes of type LITERAL which are AST child nodes of CALL nodes that have printf in their NAME property:
```
cpg.call.name("printf").astChildren.filter(_.isLiteral).code.l
```
      OR
```
cpg.call.name("printf").astChildren.isLiteral.code.l
```
      OR (in this case search for caller from literall
```
cpg.literal.filter(_.code.contains("the meaning of life?")).astParent.isCall.name.l
```
 
 6. Repeat Steps
    * There are cases in which queries have repetitions in them and become too long. In order to make them more readable, you can use Repeat Steps
    * Repeat Steps are traversals that repeat other traversals a number of times
    * Example, say you'd like to find nodes of type LITERAL in Code Property Graph that are directly reachable from the node which represents the main method
```
cpg.method.name("main").astChildren.astChildren.astChildren.astChildren.astChildren.isLiteral.code("42").toList
```
    * The query might do the job, but it is hard to read and change. repeat-times makes the query clearer
```
cpg.method.name("main").repeat(_.astChildren)(_.times(5)).isLiteral.code("42").l
```


### Syntax-Tree Queries

 - syntax-tree queries, how they can be used for identifying code that handles attacker-controlled input or follows known bad practices.

 - Consider the code snippet (insert in joern)
```
val code = """
void foo () {
  int x = source();
  if(x < MAX) {
    int y = 2*x;
    sink(y);
  }
}
"""

```

 - We can import this code snippet directly on the Joern shell.
```
importCode.c.fromString(code)
```

 - Once imported, we can plot the abstract syntax tree of foo to get a first idea of what an abstract syntax tree is.
    * the output is a svg file, abstract syntax tree is a tree-like structure that makes the decomposition of code into its language constructs explicit. 
    * The tree consists of nodes and edges visualized in the plot as ellipses and arrows respectively.
    * at the very top of the tree, we see a node representing the entire function foo
    * The edges between the function and the two other nodes (child) indicates that the function can be decomposed into a return type and a block of code
    * outgoing edges from BLOCK show that this block of code can be further decomposed.
```
cpg.method.name("foo").plotDotAst
```


#### Basic AST Traversals

 - The most basic traversal that you can execute on any AST node is ast, which traverses to all nodes of the AST rooted in the node. For example,
```
cpg.method("foo").ast.l
```

 - As each AST node is also the root of a subtree, you can also think of this operation as an enumeration of all subtrees. These can be filtered by type.
    * Example
```
cpg.method("foo").ast.isCall.code.l
```

 - It is also possible to walk the tree upwards using inAst or inAstMinusLeaf where the latter excludes the start node
    * consider for example the situation where it is known that calls to source return values that an attacker can influence.
```
cpg.call.name("source").inAstMinusLeaf.isCall.name(".*assignment.*").argument(1).l
```
    * inAstMinusLeaf: we walk edges backwards until we reach the method node
    * isCall: we determine only those which are calls 
    * name(".*assignment.*"): filter assignment target
    * argument(1): take first argument, that is the variable assigned on the left

 - The previous example shows a freuent use-case, so that via AST-queries is common, and team created a decorator language to simplify these queries. 
    * Example, In practice, we would write the following query that is equivalent to the former query.
```
cpg.call("source").inAssignment.target.l
```

#### Control Structures
 - Abstract syntax trees include control structures such as if-, while or for-statements.
    * Example
```
cpg.method("foo").controlStructure.condition.code.l
```
    * In the previous example we extract the condition, if we want to extract the block of the if-statement we select `whenTrue` instead of `condition`
    * Note, For if-else constructs, `whenFalse` returns the else block
    * Also, we can identify nested structures by chaining basic operations. yields all calls nested inside if blocks
```
cpg.method("foo").controlStructure.whenTrue.ast.isCall.code.l
```


##### Interesting example
 - One example scenario where control structure access comes in handy is 
    * when you wish to determine all methods that call a specific function but do not include a necessary check/guard
    * e.g. we want to identify functions that call source but they do not include a check against MAX
```
cpg.method.filter(_.controlStructure(".*MAX.*").isEmpty).filter(_.callee.name(".*source.*").nonEmpty).l
```


### Other stuff

 - Exporting Results with Pipe Operators and toJson
```
cpg.method.toJson |> "/tmp/foo.json"
```

 - read code associated with query results directly on the shell
```
cpg.method.name("memcpy").callIn.code.l
```

 - You can also pipe the result list into a pager as follows:
```
browse(cpg.method.name("memcpy").callIn.code.l)
```

 - you can use the .dump method, which will dump the enclosing function’s code for each finding, and point you to the finding via an arrow:
```
cpg.method.name("memcpy").callIn.dump
```

 - Running a main file 'test.sc'
```
@main def exec(cpgFile: String, outFile: String) = {
   loadCpg(cpgFile)
   cpg.method.name.l |> outFile
}
```

 * then run 
```
./joern --script test.sc --params cpgFile=/src.path.zip,outFile=output.log
```



### Joern SCAN

 - Joern Scan helps you detect security issues inside programs and can help guide your vulnerability discovery and variant analysis processes.
    * Joern Scan, a code scanner built on top of Joern.

 - Example file
```
// simple.c
#include <stdio.h>

int main () {
   char str[50];
   printf("Enter a string : ");
   gets(str);
   printf("You entered: %s", str);
   return(0);
}
```

 - You can run Joern Scan by providing the filepath as input:
```
$ joern-scan simple.c
```

 - Behind the scenes of this invocation, three things happen:
    1. The Code Property Graph for simple.c is generated
    2. A set of pre-defined queries are executed against the Code Property Graph representation of simple.c
    3. Finally, the results are printed to stdout

 - Joern Scan ships with a default set of queries, the Joern Query Database. 
    * This set of queries is constantly updated, and contributions are highly encouraged https://github.com/joernio/query-database.

 - You can fetch the latest version of the Joern Query Database using the --updatedb flag:
```
$ joern-scan --updatedb
```

 - database queries have tag, default tag is choosed, if `--tags <tag>` paramter is omitted
    * `--tags badfn` specify set of tags
    * `--tags all` specify all as tag to choose all queries
    * Alternatively, you can choose queries using their names: `$ joern-scan simple.c --names call-to-gets,multiple-returns`


### Example Joern data flow

 - Let's start we have the following example
```
// foo.c
int source(void);
void sink(int);
void foo() {
  int x = source();
  sink(x);
}
```

 - We want to find if source 'x' is used in sink 'sink(x)'
```
importCode(inputPath="./foo.c", projectName="foo-c")`

run.ossdataflow
def source = cpg.call("source")
def sink = cpg.call("sink").argument

sink.reachableByFlows(source).p
```


---


## Extra

### Exporting Graphs

 - Joern is used in academic research as a source for intermediate graph representations of code, 
    * particularly in machine learning and vulnerability discovery applications 

 - Joern provides both plotting capabilities in the interactive console as well as the joern-export command line utility.
   In summary, Joern can create the following graph representations for C/C++ code:

    * Abstract Syntax Trees (AST)
    * Control Flow Graphs (CFG)
    * Control Dependence Graphs (CDG)
    * Data Dependence Graphs (DDG)
    * Program Dependence graphs (PDG)
    * Code Property Graphs (CPG14)

 - Example, parse some code and then export program dependence graphs (PDG)
```
joern-parse /src/directory
joern-export --repr pdg --out outdir
```

 - We could export the graph mentioned from console also, e.g.
```
cpg.method($name).dotAst.l // output AST in dot format
cpg.method($name).dotCfg.l // output CFG in dot format
...
cpg.method($name).dotCpg14.l // output CPG'14 in dot format

// or plot to GUI
cpg.method($name).plotDotAst // plot AST
cpg.method($name).ploDotCfg // plot CFG
...
cpg.method($name).plotDotCpg14 // plot CPG'14
```

### Joern API Server

 - Cool
 - The interpreter can also be accessed via an HTTP API. 
 - Its primary jobs are to:
    1. provide an interface to allow querying Code Property Graphs from non-JVM-based programming languages
    2. enabling clients with limited computational resources to outsource CPG construction and querying to a server machine.

 - A sample client is available for Python at: https://github.com/joernio/cpgqls-client-python#example-usage

 - The HTTP API allows posting queries and obtaining responses. 
    * Additionally, a Websocket is offered that clients can subscribe to in order to be notified by the server when query responses are available.

 - more can be found [here](https://docs.joern.io/server)


### Joern Extensions

 - More [here](https://docs.joern.io/extensions)

 - Plugins are distributed as zip files containing Java archives. 
 - They can be written in any JVM-based language, e.g., in Java, Scala, or Kotlin.

 - Joern comes with a few plugins pre-installed. You can list installed plugins using
```
joern --plugins
New plugins can be added:

joern --add-plugin <zipfile>
and removed:

joern --rm-plugin <name>
```

#### Developing your own plugin
 - sample plugin written in Scala that you can use as a template. 
```
git clone https://github.com/joernio/sample-plugin.git
cd sample-plugin
./install.sh
```


### Knowledge class
 - https://docs.joern.io/cpgql/reference-card



