import ../src/jerasure
# Demostrating cauchy.
# We could use the commandline options here

proc printf(formatstr: cstring) {.header: "<stdio.h>", importc: "printf", varargs.}
proc fprintf(formatstr: cstring) {.header: "<stdio.h>", importc: "fprintf", varargs.}

proc caunch_01(argc:cint, n_n:cint, w_w:cint):cint =
    # Proc caunch 01.
    # NOTE: This is where the commandline option would
    # work.
    var no:cint
    var i:cint
    var bitmatrix: ptr cint
    var w:cint = 24
    var n:cint = 12

    if ( w == 31):
        if cast[bool](n and 0x80000000):
            echo "Bad n/w combination (n not between 0 and 2^w-1)"
    elif ( w < 31):
        if n >= (1 shl w):
            echo "Bad n/w combination ( n not between 0 and 2^w-1)"

    # Let's call our jerasure_matrix_to_bitmatrix
    bitmatrix = jerasure_matrix_to_bitmatrix(1,1, w, addr(n))

    if(w == 32):
        printf("Converted the value 0x%x to the following bitmatrix:\x0A\x0A", n)
    else:
        printf("Converted the value %d (0x%x) to the following bitmatrix:\x0A\x0A", n, n)

    # Call our   jerasure_print_bitmatrix
    jerasure_print_bitmatrix(bitmatrix, w, w, w);

    no = 0;

    i = 0
    while i < w * w:
      inc(no, bitmatrix[i])
      inc(i)


    if no != cauchy_n_ones(n, w):
        fprintf(stderr, "Jerasure error: # ones in the bitmatrix (%d) doesn\'t match cauchy_n_ones() (%d).\x0A",
                no, cauchy_n_ones(n, w))
        exit(1)

    printf("# Ones: %d\x0A", cauchy_n_ones(n, w))

    return 0


var n_n:cint = 12
var w_w:cint = 24

discard caunch_01(0, n_n, w_w);
