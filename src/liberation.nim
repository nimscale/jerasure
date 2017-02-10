
# Jerasure nim binding from the original C/C++ LIbrary for a Variety of Reed-Solomon and
# RAID-6 Erasure Coding Techniques.

# This contains header definition which will entirely
# rely from the compiled static C library libJerarasure.so

proc liberation_coding_bitmatrix*(k: cint; w: cint): ptr cint {.importc.}
     # Allocates and returns the bit-matrix for liberation coding.
     # @param w must be prime greater than 2, though not enforced.

proc liber8tion_coding_bitmatrix*(k: cint): ptr cint {.importc.}

proc blaum_roth_coding_bitmatrix*(k: cint; w: cint): ptr cint {.importc.}
