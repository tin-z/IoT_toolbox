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
