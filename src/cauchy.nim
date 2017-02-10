# A jerasure A nim binding for C/C++ Library for a Variety of Reed-Solomon and RAID-6 Erasure
# Coding Techniques.
#------------------------------------------------------
#
# This contains binding for the caunch.c to caunch.nim, here
# We only track the proc, but link it to a statically linked
# files.
#
# Cauch.nim Implements procedures that are specific to Caunch Reed-Solomon Codeing.
# Here we simple create the coding matrices

# Linking to a statically compiled library
{.link:"/usr/local/lib/libJerasure.so.2.0.0"}
{.link:"/usr/local/lib/libgf_complete.so.1.0.0"}
proc cauchy_original_coding_matrix*(k: cint; m: cint; w: cint): ptr cint {.importc.}
     # This proc allocates and returns the originally defined Cauchy matrix.
     # Given k, m, w

proc cauchy_xy_coding_matrix*(k: cint; m: cint; w: cint; x: ptr cint; y: ptr cint): ptr cint {.importc.}
     # This allows the user to specify sets, X, Y to dfine the matrix.
     # This does not double check X and Y, it assumes they comfor to these
     # restrictions.

proc cauchy_improve_coding_matrix*(k: cint; m: cint; w: cint; matrix: ptr cint) {.importc.}
     # Here we improves a matrix using the heuristic above,
     # First dividing each column by it's element in row 0, then
     # improving the rest of the rows.

proc cauchy_good_general_coding_matrix*(k: cint; m: cint; w: cint): ptr cint {.importc.}
     # Proc allocates and returns a good matrix, mostly may return, optimal RAID-6 matrix
     # Otherwise it generates a good matrix, by calling @proc cauchy_original_coding_matrix
     # and then @proc cauchy_improve_coding_matrix

proc cauchy_n_ones*(n: cint; w: cint): cint {.importc.}
     # This returns the number of ones in the bit-matrix representation
     # of numbers. It is more efficient that generating
     # the bit-matrix.

     
