

proc printf(formatstr: cstring) {.header: "<stdio.h>", importc: "printf", varargs.}

{.link:"/usr/local/lib/libJerasure.so.2.0.0"}
proc jerasure_print_matrix*(m: pointer; rows: cint; cols: cint; w: cint)  {.importc.}

proc jerasure_print_bitmatrixs*(m: pointer ; rows: cint; cols: cint; w: cint) =
    var
      i: cint
      j: cint

    i = 0
    while i < rows:
      if i != 0 and i mod w == 0: printf("\x0A")
      j = 0
      while j < cols:
        if j != 0 and j mod w == 0:
            printf(" ")
            m[i * cols + j]
        inc(j)
      printf("\x0A")
      inc(i)

var r:cint = 12
var c:cint = 33
var w:cint = 10
var matrix: pointer = alloc(r * c)

jerasure_print_bitmatrixs(matrix, r, c, w);
