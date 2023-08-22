

## Refs ##

 - [official website](https://coccinelle.gitlabpages.inria.fr/website/)

 - [coccicheck scripts](https://coccinelle.gitlabpages.inria.fr/website/coccicheck.html)

 - [cuccinelle docs](https://coccinelle.gitlabpages.inria.fr/website/documentation.html)
    * [Coccinelle Usage docs](https://coccinelle.gitlabpages.inria.fr/website/docs/options.pdf)
    * [The SmPL Grammar docs](https://coccinelle.gitlabpages.inria.fr/website/docs/main_grammar.pdf)
    * [Coccinelle - Semantic Patch Examples](https://coccinelle.gitlabpages.inria.fr/website/rules/)

 - [sparse](https://lwn.net/Articles/689907/)
    * [sparse docs](https://sparse.docs.kernel.org/en/latest/)


## Roadmap ##


0. Introduction to cuccinelle, talk "SAN19-500K1 Keynote: Coccinelle: 10 Years of Automated Evolution in the Linux Kernel)"
    * [video](https://www.youtube.com/watch?v=LOsluYTzdMg)
    * [slide](https://events19.linuxfoundation.org/wp-content/uploads/2017/12/Coccinelle-10-Years-of-Automated-Evolution-and-Bug-Finding-in-the-Linux-Kernel-Julia-Lawall-Inria.pdf)

1. [Compilation](https://www.kernel.org/doc/html/latest/dev-tools/coccinelle.html)

2. [example usage](https://a13xp0p0v.github.io/2019/08/10/cfu.html#variant-analysis:-coccinelle)


 - Workshops

3. Watch "Getting Started with Coccinelle (KVM edition) by Julia Lawall" (Just follow the first 35 mins of the talk)
    * [video](https://www.youtube.com/watch?v=qtYuVXidv94)
    * [slide](https://events.static.linuxfound.org/sites/events/files/slides/tutorial_kvm.pdf)

4. Watch "Mentorship Session: Coccinelle: Automating Large-scale Evolution and Bug Finding in C Code"
    * [video](https://www.youtube.com/watch?v=16wUxqDf1GA)
    * [slide](https://events.linuxfoundation.org/wp-content/uploads/2021/02/coccinelle_tutorial.pdf)

5. Coccinelle: Finding bugs in the Linux Kernel - Vaishali Thakkar - FOSSASIA Summit 2017
    * [video](https://www.youtube.com/watch?v=2sfJ9HNlU5w)
    * The talk will highlight the capabilities and limitations of Coccinelle along with introducing various basic features of the SmPL.





 - Watch "Julia Lawall: An Introduction to Coccinelle Bug Finding and Code Evolution for the Linux Kernel" (start from min 
    * [video](https://www.youtube.com/watch?v=buZrNd6XkEw)
    * This talk describes coccinelle advanced stuff 





---


## Notes ##

### 0. Coccinelle in a nutshell ###

 - Coccinelle is a program matching and transformation tool which provides the language SmPL (Semantic Patch Language) for SPECIFYING DESIRED MATCHES and TRANSFORMATIONS in C code. 
    * It has been extensively used for finding bugs and performing source code evolutions in the Linux kernel. 

 - Coccinelle is designed around a language for expressing matching and transformation rules in terms of fragments of C code. 
    * It has been used in the development of almost 4000 patches found in the Linux kernel. 
    * More than 40 Coccinelle scripts are distributed with the Linux kernel source code.

 - Coccinelle's goals:
    * Automatically FIND code containing bugs
    * Automatically FIX bugs
    * Be accessible and suitable to and for software developers


### 1. Getting Started with Coccinelle (KVM edition) by Julia Lawall ###
 - Just follow the first 35 mins of the talk

 - Two parts for rule:
    * Metavariable declaration (@@)
    * Transformation specification (+, * and -)

 - The changes done by rules are incrementally done, we choose the order

 - The -, * and + operators are used for building semantic patches
    * @@ means start of the declaration, we need expression because we do not care names of the arguments' function
 - e.g.
```
@@
expression addr, plen, is_write;
@@

- cpu_physical_memory_map(addr, plen, is_write)
+ address_space_map(&address_space_memory, addr, plen, is_write)
```
 - after the patch applied we have 62 calls modifies

 - the tool (spatch) does not apply patch directly to those files matching a rule. Instead a patch file is generated

#### Syntax coccinelle rules ####
 - - in the leftmost column for something to remove
 - + in the leftmost column for something to add
 - * in the leftmost column for something of interest
    * Cannot be used with - and +

 - We use ... for abstracting over code sequences in a coccinelle rule

 - Spaces, newlines are ignored


#### Metavariable types ####
 - expression: variable placeholder
 - statement: e.g. IF statement
 - identifier: variable name, function name, etc... is the name of something, it doesn't have value
 - type: integer, struct, etc.
 - constant: constant expression, it's a expression's subset
 - local idexpression: idexpression is an expression that looks like an identifier, and then local we mean it's local expression



### 2. Mentorship Session: Coccinelle: Automating Large-scale Evolution and Bug Finding in C Code ###
 - In this talk we'll see how to search for code pattern


#### Common coccinelle uses ####

 - To check that your semantic patch is valid:
```
spatch --parse-cocci mysp.cocci
```

 - To run your semantic patch:
```
# apply to a single file
spatch --sp-file mysp.cocci file.c

# apply to files starting from <directory> folder
spatch --sp-file mysp.cocci --dir <directory>

# To understand why your semantic patch didn't work:
spatch --sp-file mysp.cocci file.c --debug

# Do not include header files:
spatch --sp-file mysp.cocci --dir <directory> --no-includes --include-headers

```

 - Spatch tool does not modify those files matching a cuccinelle rule. Instead a patch file is generated
```
spatch [...] > output.patch
```

 - Other stuff
```
# omit the uninteresting output
spatch --very-quiet [...]

# spawn <N> thread
spatch -j <N> [...]
```

 - Try exercises



#### Kzalloc example ####

 - Example: Inadequate error checking of kzalloc
    * kzalloc returns NULL on insufficient memory.

 - We want to find conditions similar to this one:
```
ddip = kzalloc(sizeof(struct detached_dev_io_private), GFP_NOIO);
ddip->d = d;
```

 - Example of coccinelle rule tracking those use cases:
    * note, identifier: variable name, function name, etc... is the name of something, it doesn't have value
```
@@
expression e; identifier f;
@@

e = kzalloc(...);
...
* e->f
```

 - The previous rule also matches:
```
check_state = kzalloc(sizeof(struct btree_check_state), GFP_KERNEL);
if (!check_state)
  return -ENOMEM;
```

 - To avoid that we change the code into:

```
@@
expression e; identifier f;
@@

e = kzalloc(...);
...
(
e == NULL
|
e != NULL
|
*e->f
)
```

 - Moreover we want to avoid kzalloc with `__GFP_NOFAIL` argument, e.g.  `kzalloc(sizeof(*ia), GFP_KERNEL | __GFP_NOFAIL);`.
```
@@ 
expression e, x; 
identifier f; 
@@

(
e = kzalloc(..., x | __GFP_NOFAIL);
|
e = kzalloc(..., __GFP_NOFAIL);
|
e = kzalloc(...);
...
(e == NULL
|e != NULL
|
*e->f
)
)

```



#### Exercise 4 ####
 - #TODO

 - With the same logic of the previous example, write down a coccinelle rule matching `dma_map_single` calls without the checking of return value
 - Code to not match
```
dma_addr = dma_map_single(&solo_dev->pdev->dev, sys_addr, size, wr ? DMA_TO_DEVICE : DMA_FROM_DEVICE);
if (dma_mapping_error(&solo_dev->pdev->dev, dma_addr))
  return -ENOMEM;
```

 - Test 1
```
@@
expression e; identifier f;
@@

e = dma_map_single(&solo_dev->pdev->dev, sys_addr, size, wr ? DMA_TO_DEVICE : DMA_FROM_DEVICE);
e = kzalloc(...);
...
* e->f

```



#### Advanced SmPL ####

 - This part wasn't covered in the talk
    * Here there's another talk discussing these functionalities [video](https://www.youtube.com/watch?v=buZrNd6XkEw)

 - Isomorphisms:
    * Coccinelle matches code exactly as it appears. e.g.  x == NULL does not match !x
    * We want x == NULL. to match !x also
    * Solution: An isomorphism relates code patterns that are considered to be similar

 - Typed metavariables:
    * Match function only if argument declared is the same struct/type described

 - Position metavariables:
    * Store the position of any "token", later we can print it by using python/ocaml script

 - Putting costraints
    * Using "when" operand between two code fragments


 - Rule names and rule ordering:
    * Later rules see the results of earlier rules.
    * By naming rules (in the same coccinelle file) we can refer to other variables declared in a rule
    * e.g.

```
# Goal: Find probe functions that call kmalloc (possible devm_kmalloc candidates)
#       1. Find a probe function (function stored in a probe field).
#       2. Check whether the function calls kmalloc.
#
# Problem: Need to match a structure and then a function definition,
#          but a SmPL rule matches only one thing at a time.
#

@r@ 
identifier i, j, fn; 
@@
struct i j = { .probe = fn, };


@s@ 
identifier r.fn; 
@@

fn(...) {
<...
* kmalloc(...)
...>
}

```


 - Python, OCaml interface:
    * Print warning messages.
    * Position metavariables give access to position information
    * e.g.

```
@r@ 
identifier i, j, fn; 
@@

struct i j = { .probe = fn, };


@s@ 
identifier r.fn; 
position p;
@@

fn(...) {
<...
* kmalloc@p(...)
...>
}


# we can also run python script during runtime
#
@script:python@
fn << r.fn;
p << s.p;
@@

file = p[0].file
line = p[0].line
print("%s:%s: kmalloc in probe function %s" % (file,line,fn))


```



#### Extra stuff

 - Follow this [link](https://coccinelle.gitlabpages.inria.fr/website/docs/main_grammar.pdf)
   and debug the coccinelle script [here](https://a13xp0p0v.github.io/2019/08/10/cfu.html#variant-analysis:-coccinelle)

 - `<id> << rulename_id.id;` stands for metavariables for scripts 

 - "<... ...>" indicates that matching the pattern in between the ellipses is to be matched 0 or more times, e.g.
```
<...
* kmalloc(...)
...>
}
```

 - it is optional, and another "<+... ...+>" indicates that the pattern in between the ellipses must be matched at least once, on some control-flow path. 

 - Di solito si consiglia di dividere le regole in più rules name, così per il debugging è più easy
    * Una soluzione migliore è fare la seconda rule in python, così possiamo mettere cose più specifiche da matchare
    * e.g.

```
@r0@
identifier i, j, fn; 
@@

<matcha funzione, blah blah>


@r1@
identifier r.fn; 
@@

<se la funzione è chiamata da.. blah>
```




