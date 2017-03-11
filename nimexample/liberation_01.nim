# Example demostrating liberation coding techniques
#This demonstrates: liberation_coding_bitmatrix()
#                   jerasure_smart_bitmatrix_to_schedule()
#                   jerasure_dumb_bitmatrix_to_schedule()
#                   jerasure_schedule_encode()
#                   jerasure_schedule_decode_lazy()
#                   jerasure_print_bitmatrix()
#                   jerasure_get_stats()
#Wrong number of arguments

# Let's import our Jerasure which contains
# our statically linked library, when compiling
# it even other proc that depend on that library
# Will have access to the defintions.
import jerasure
import galois
import cauchy
import liberation
import reed_sol
import sharedlib # Not part of the standard binding
import templates # Not part of the standard binding
import gf_typedef # Not part of the standard binding
#import jerasure.src.timing


#Needed for pointer arithmetics
var a: ptr int16
var t = @[1.int16, 2.int16, 3.int16]

proc `+`[T](a: ptr T, b: int): ptr T =
    if b >= 0:
        cast[ptr T](cast[uint](a) + cast[uint](b * a[].sizeof))
    else:
        cast[ptr T](cast[uint](a) - cast[uint](-1 * b * a[].sizeof))

template `-`[T](a: ptr T, b: int): ptr T = `+`(a, -b)



proc main()=
    # All this variables are needed
    # We are demostrating a lot of
    # other coding techniques from jerasure

    var
      k: cint = 7
      w: cint = 7
      i: cint
      m: cint

    var bitmatrix: ptr cint

    var
      data: cstringArray
      coding: cstringArray

    var dumb: ptr ptr cint

    var
      erasures: ptr cint
      erased: ptr cint

    var stats: array[3, cdouble]
    var seed: uint32


    # Invoked our @proc liberation_coding_bitmatrix
    bitmatrix = liberation_coding_bitmatrix(k, w)

    if(bitmatrix == nil):
        echo "Couldn't make coding matrix"


    # Print the bitmatrix
    jerasure_print_bitmatrix(bitmatrix, w*m, w*k, w);

    dumb = jerasure_dumb_bitmatrix_to_schedule(k, m, w, bitmatrix);

    #MOA_Seed(seed);

when isMainModule:
    main()
