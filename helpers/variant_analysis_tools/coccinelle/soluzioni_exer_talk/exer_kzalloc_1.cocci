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
