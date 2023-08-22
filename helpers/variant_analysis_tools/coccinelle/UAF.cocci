
@r@ 
identifier fn, fk;
expression m;
position p1, p2;
@@

fn(...) {
...
* kfree@p1(m)
...
* fk@p2(... , m, ...)
...
}


@script:python@
fn << r.fn;
fk << r.fk;
p1 << r.p1;
p2 << r.p2;
@@

file = p1[0].file
line1 = p1[0].line
line2 = p2[0].line
if fn == "kfree" and fk != "kfree" :
  print("%s:%s: UAF on function %s - called by %s %s" % (file, line1, fn, fk, line2))


