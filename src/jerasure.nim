

{.link:"/usr/local/lib/libJerasure.so.2.0.0"}
proc jerasure_print_matrix*(m: pointer; rows: cint; cols: cint; w: cint)  {.importc.}

var r:cint = 12
var c:cint = 33
var w:cint = 10
var matrix: pointer = alloc(r * c)

#jerasure_print_matrix(matrix, r, c, w);
