

## Refs
 - more about LGTM and QL: https://web.archive.org/web/20190918215933/https://blog.semmle.com/tags/

 - Intro to QL: https://web.archive.org/web/20190918215957/https://blog.semmle.com/interning-at-semmle/

 - Introduction to variant analysis with QL and LGTM (Part 1)
    * ref: https://web.archive.org/web/20190918220017mp_/https://blog.semmle.com/intro_to_variant_analysis_part_1/



## RoadMap learning QL and LGTM


 - [codeQL tutorials part1](./LGTM_codeQL.md)

 - [CodeQL Live Episode 1 (brief example in C/C++ vulns)](https://www.youtube.com/watch?v=AMzGorD28Ks)

 - [h@cktivitycon 2020: Discover vulnerabilities with CodeQL](https://www.youtube.com/watch?v=NygVkQKmGwI)

 - [Security: Workshop 2 - Finding security vulnerabilities in C/C++ with CodeQL](https://www.youtube.com/watch?v=eAjecQrfv3o)
    * [workshop's repo](https://github.com/githubuniverseworkshops/codeql/tree/main/workshop-2020)
    * [workshop.md](https://github.com/githubuniverseworkshops/codeql/blob/main/workshop-2020/workshop.md)


 - [CodeQL as an Audit Oracle (workshop) by Alvaro Muñoz during HacktivityCon 2021](https://www.youtube.com/watch?v=-bJ2Ioi7Icg)
    * [workshop's repository](https://github.com/github/codeql-dubbo-workshop)


 - [Resources related to GitHub Security Lab](https://github.com/github/securitylab)
    * [Famous codeql queries](https://github.com/github/securitylab/tree/main/CodeQL_Queries/cpp)
    * [Github exploits](https://github.com/github/securitylab/tree/main/SecurityExploits)

 - [Apple's XNU Kernel codeQL CVE-2017-13782](https://securitylab.github.com/research/apple-xnu-dtrace-CVE-2017-13782/)
    * [video of xnu kernel vuln found using codeql](https://www.twitch.tv/videos/831625367)


 - [The CodeQL Bug Bounty program](https://securitylab.github.com/bounties/)
    * [Contributing to CodeQL](https://github.com/github/codeql/blob/main/CONTRIBUTING.md)

 - More..
    * [Actions for Learning Lab CodeQL Courses](https://github.com/github/codeql-learninglab-actions)
    * [CodeQL Action](https://github.com/github/codeql-action)
    * [extension for Visual Studio Code that adds rich language support for CodeQL](https://github.com/github/vscode-codeql)
    * [github profile](https://github.com/adityasharad)
    * [Testing custom queries](https://codeql.github.com/docs/codeql-cli/testing-custom-queries/#testing-custom-queries)



 - other workshops
    * [Finding security vulnerabilities in Java with CodeQL - GitHub Satellite 2020](https://www.youtube.com/watch?v=nvCd0Ee4FgE)
    * [Finding security vulnerabilities in JavaScript with CodeQL - GitHub Satellite 2020](https://www.youtube.com/watch?v=pYzfGaLTqC0)

---
---



### CodeQL Live Episode 1

 - ref, https://www.youtube.com/watch?v=AMzGorD28Ks

 - esempio 1
```
import cpp

class StringCopyCall extends FunctionCall {
    StringCopyCall() {
        this.getTarget().getName().regexpMatch(".*str(lcpy|lcat|cat|cpy)")
    }

    Expr getSizeArgument(){
        this.getArgument(2) = result
    }
}

from StringCopyCall call
select call

```

 - esempio 2
    * in questo caso usiamo path queries

```
import cpp
import semmle.code.cpp.dataflow.TaintTracking
import DataFlow::PathGraph

class StringCopyCall extends FunctionCall {
    StringCopyCall() {
        this.getTarget().getName().regexpMatch(".*str(lcpy|lcat|cat|cpy)")
    }

    Expr getSizeArgument(){
        this.getArgument(2) = result
    }
}

class Config extends TaintTracking::Configuration {
    Config() { this = "hello" }
    override predicate isSink(DataFlow::Node sink) {
        sink.asExpr() = any(StringCopyCall c).getSizeArgument()
        // or equivalent to
        /*
        exists( StringCopyCall c |
            sink.asExpr() = c.getSizeArgument())
        */
    }

    override predicate isSource(DataFlow::Node source) {
        source.asExpr() instanceof StringCopyCall
    }
}
    
from DataFlow::PathNode source, DataFlow::PathNode sink, Config config
where config.hasFlowPath(source, sink)
select sink, source, "Return value of string copying call reachable"
```


### h@cktivitycon 2020: Discover vulnerabilities with CodeQL

 - ref, https://www.youtube.com/watch?v=NygVkQKmGwI

 - find password related variables
    * VariableAccess: An access to a variable. Either an access to a local scope variable (LocalScopeVariableAccess) or an access to a field (FieldAccess).
    * .getTarget(): Gets the target of this access. Variable object returns
    * Variable: A variable. Either a variable with local scope (LocalScopeVariable) or a field (Field).
    * .getName(): Gets the name of this element.

```
from VariableAccess va
where va.getTarget().getName().regexpMatch(".*pass(wd|word|code).*")
select va.getTarget()
```


#### CodeQL's tricks

1. Replicate CVEs to find you CVEs
2. More powerful pattern finder
3. Regression tests


#### 1. Replicate CVEs to find you CVEs
 - we can find the same vuln in the same project, or into another one aka "variant analysis"
    * with variant analyses we found vulnerabilities to different projects using the same codeQL query

 - ...


#### 3. Regression tests
 - SSDLC adoption
    * SSDLC stands for Secure Software Development Life Cycle
    * That means adding security activities to the system development lifecycle in each phase/cycle of the SDLC

 - ...


#### Conclusion

 - in long term github objectives
 - github codeql wants to apply variant analysis, and not only find vuln in public repositories,
   but also apply patch with less manual effort or in a automatically-way 



### Security: Workshop 2 - Finding security vulnerabilities in C/C++ with CodeQL



#### Exer 1

```
























