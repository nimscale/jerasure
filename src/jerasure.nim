

#proc printf(formatstr: cstring) {.header: "<stdio.h>", importc: "printf", varargs.}

template talloc*(`type`, num: untyped): untyped =
  cast[ptr `type`](alloc(sizeof(`type`) * (num)))

proc printf(formatstr: cstring) {.header: "<stdio.h>", importc: "printf", varargs.}


{.link:"/usr/local/lib/libJerasure.so.2.0.0"}
proc jerasure_print_matrix*(m: pointer; rows: cint; cols: cint; w: cint)  {.importc.}

proc jerasure_print_bitmatrix*(m: pointer ; rows: cint; cols: cint; w: cint) {.importc.}


