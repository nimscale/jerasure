import os, osproc, strutils

#proc printf(formatstr: cstring) {.header: "<stdio.h>", importc: "printf", varargs.}

template talloc*(`type`, num: untyped): untyped =
  cast[ptr `type`](alloc(sizeof(`type`) * (num)))

const
  SHARED_LIB_PATH="/usr/local/lib"
  HEADER_PATH="/usr/local/include"

{.link:"/usr/local/lib/libJerasure.so.2.0.0"}

proc jerasure_matrix_to_bitmatrix*(k: cint; m: cint; w: cint; matrix: ptr cint): ptr cint {.importc.}
    ##  - jerasure_matrix_to_bitmatrix turns a m X k matrix in GF(2^w) into a
    ##    wm X wk bitmatrix (in GF(2)).  This is
    ##    explained in the Cauchy Reed-Solomon coding
    ##    paper.

proc jerasure_print_matrix*(m: ptr; rows: cint; cols: cint; w: cint) {.importc.} #{.cdecl, importc."jerasure_print_matrix", header:"/usr/local/include/jerasure.h".}
    # Corresponds to the C jerasure_print_matrix which is extracted from
    # the statically linked file libJerasure.so
    # @param: m pointer
    # @param: rows cint
    # @param: cols cint
    # @param: w cint
    # @return: void

proc jerasure_print_bitmatrix*(m: ptr ; rows: cint; cols: cint; w: cint) {.importc.}
    # Corresponds to the C jerasure_print_bitmatrix which is extracted from
    # the statically linked file libJerasure.so
    # @param: m pointer
    # @param: rows cint
    # @param: cols cint
    # @param: w cint
    # @return: void

