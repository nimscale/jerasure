

#proc printf(formatstr: cstring) {.header: "<stdio.h>", importc: "printf", varargs.}

template talloc*(`type`, num: untyped): untyped =
  cast[ptr `type`](alloc(sizeof(`type`) * (num)))

proc printf(formatstr: cstring) {.header: "<stdio.h>", importc: "printf", varargs.}


{.link:"/usr/local/lib/libJerasure.so.2.0.0"}
proc jerasure_print_matrix*(m: pointer; rows: cint; cols: cint; w: cint)  {.importc.}
    # Corresponds to the C jerasure_print_matrix which is extracted from
    # the statically linked file libJerasure.so
    # @param: m pointer
    # @param: rows cint
    # @param: cols cint
    # @param: w cint
    # @return: void

proc jerasure_print_bitmatrix*(m: pointer ; rows: cint; cols: cint; w: cint) {.importc.}
    # Corresponds to the C jerasure_print_bitmatrix which is extracted from
    # the statically linked file libJerasure.so
    # @param: m pointer
    # @param: rows cint
    # @param: cols cint
    # @param: w cint
    # @return: void
