# Provides binding nim binding for the the C counterpart.
# Many of the procs of functions here are extracted or mimicked
# from a staticlly linked libJerasure.
# This saves us a from re-compiling.
# NOTE: Decided to maintain the developer comments on each proc or funtion
# bellow, this helps in maintaining the same status with the original binding.

import os, osproc, strutils, templates

# This printf was needed because there where some methods that
# needed them and there was no way I found for the nim's echo
# to go with it.
proc printf(formatstr: cstring) {.header: "<stdio.h>", importc: "printf", varargs.}

# We need to maintain a pull or shared library where the jerasure headers reside.
const
  SHARED_LIB_PATH="/usr/local/lib"
  HEADER_PATH="/usr/local/include"


# This is the sharedlibrary needed for the entire project.
# Perhaps here it should be dynamic not being so static like this.
{.link:"/usr/local/lib/libJerasure.so.2.0.0"}

proc jerasure_matrix_to_bitmatrix*(k: cint; m: cint; w: cint; matrix: ptr cint): ptr cint {.importc.}
    ##  - jerasure_matrix_to_bitmatrix turns a m X k matrix in GF(2^w) into a
    ##    wm X wk bitmatrix (in GF(2)).  This is
    ##    explained in the Cauchy Reed-Solomon coding
    ##    paper.


proc jerasure_dumb_bitmatrix_to_schedule*(k: cint; m: cint; w: cint; bitmatrix: ptr cint): ptr ptr cint {.importc.}


proc jerasure_smart_bitmatrix_to_schedule*(k: cint; m: cint; w: cint; bitmatrix: ptr cint): ptr ptr cint {.importc.}

proc jerasure_generate_schedule_cache*(k: cint; m: cint; w: cint; bitmatrix: ptr cint; smart: cint): ptr ptr ptr cint {.importc.}

proc jerasure_free_schedule*(schedule: ptr ptr cint) {.importc}

proc jerasure_free_schedule_cache*(k: cint; m: cint; cache: ptr ptr ptr cint) {.importc.}

##  ------------------------------------------------------------
##  Encoding - these are all straightforward.  jerasure_matrix_encode only
##    works with w = 8|16|32.

proc jerasure_do_parity*(k: cint; data_ptrs: cstringArray; parity_ptr: cstring; size: cint) {.importc.}

proc jerasure_matrix_encode*(k: cint; m: cint; w: cint; matrix: ptr cint; data_ptrs: cstringArray; coding_ptrs: cstringArray;
                            size: cint) {.importc.}

proc jerasure_bitmatrix_encode*(k: cint; m: cint; w: cint; bitmatrix: ptr cint; data_ptrs: cstringArray; coding_ptrs: cstringArray;
                               size: cint; packetsize: cint) {.importc.}

proc jerasure_schedule_encode*(k: cint; m: cint; w: cint; schedule: ptr ptr cint; data_ptrs: cstringArray; coding_ptrs: cstringArray;
                              size: cint; packetsize: cint) {.importc.}

##  ------------------------------------------------------------
##  Decoding. --------------------------------------------------
##  These return integers, because the matrix may not be invertible.
##
##    The parameter row_k_ones should be set to 1 if row k of the matrix
##    (or rows kw to (k+1)w+1) of th distribution matrix are all ones
##    (or all identity matrices).  Then you can improve the performance
##    of decoding when there is more than one failure, and the parity
##    device didn't fail.  You do it by decoding all but one of the data
##    devices, and then decoding the last data device from the data devices
##    and the parity device.
##    jerasure_schedule_decode_lazy generates the schedule on the fly.
##    jerasure_matrix_decode only works when w = 8|16|32.
##    jerasure_make_decoding_matrix/bitmatrix make the k*k decoding matrix
##          (or wk*wk bitmatrix) by taking the rows corresponding to k
##          non-erased devices of the distribution matrix, and then
##          inverting that matrix.
##          You should already have allocated the decoding matrix and
##          dm_ids, which is a vector of k integers.  These will be
##          filled in appropriately.  dm_ids[i] is the id of element
##          i of the survivors vector.  I.e. row i of the decoding matrix
##          times dm_ids equals data drive i.
##          Both of these routines take "erased" instead of "erasures".
##          Erased is a vector with k+m elements, which has 0 or 1 for
##          each device's id, according to whether the device is erased.
##
##    jerasure_erasures_to_erased allocates and returns erased from erasures.
##
##

proc jerasure_matrix_decode*(k: cint; m: cint; w: cint; matrix: ptr cint;
                            row_k_ones: cint; erasures: ptr cint;
                            data_ptrs: cstringArray; coding_ptrs: cstringArray;
                            size: cint): cint {.importc.}

proc jerasure_bitmatrix_decode*(k: cint; m: cint; w: cint; bitmatrix: ptr cint;
                               row_k_ones: cint; erasures: ptr cint;
                               data_ptrs: cstringArray; coding_ptrs: cstringArray;
                               size: cint; packetsize: cint): cint {.importc.}

proc jerasure_schedule_decode_lazy*(k: cint; m: cint; w: cint; bitmatrix: ptr cint;
                                   erasures: ptr cint; data_ptrs: cstringArray;
                                   coding_ptrs: cstringArray; size: cint;
                                   packetsize: cint; smart: cint): cint {.importc.}

proc jerasure_schedule_decode_cache*(k: cint; m: cint; w: cint;
                                    scache: ptr ptr ptr cint; erasures: ptr cint;
                                    data_ptrs: cstringArray;
                                    coding_ptrs: cstringArray; size: cint;
                                    packetsize: cint): cint {.importc.}

proc jerasure_make_decoding_matrix*(k: cint; m: cint; w: cint; matrix: ptr cint;
                                   erased: ptr cint; decoding_matrix: ptr cint;
                                   dm_ids: ptr cint): cint {.importc.}

proc jerasure_make_decoding_bitmatrix*(k: cint; m: cint; w: cint; matrix: ptr cint;
                                      erased: ptr cint; decoding_matrix: ptr cint;
                                      dm_ids: ptr cint): cint {.importc.}

proc jerasure_erasures_to_erased*(k: cint; m: cint; erasures: ptr cint): ptr cint {.importc.}

##  ------------------------------------------------------------
##  These perform dot products and schedules. -------------------
##
##    src_ids is a matrix of k id's (0 - k-1 for data devices, k - k+m-1
##    for coding devices) that identify the source devices.  Dest_id is
##    the id of the destination device.
##    jerasure_matrix_dotprod only works when w = 8|16|32.
##    jerasure_do_scheduled_operations executes the schedule on w*packetsize worth of
##    bytes from each device.  ptrs is an array of pointers which should have as many
##    elements as the highest referenced device in the schedule.
##

proc jerasure_matrix_dotprod*(k: cint; w: cint; matrix_row: ptr cint; src_ids: ptr cint;
                             dest_id: cint; data_ptrs: cstringArray;
                             coding_ptrs: cstringArray; size: cint) {.importc.}

proc jerasure_bitmatrix_dotprod*(k: cint; w: cint; bitmatrix_row: ptr cint;
                                src_ids: ptr cint; dest_id: cint;
                                data_ptrs: cstringArray;
                                coding_ptrs: cstringArray; size: cint;
                                packetsize: cint) {.importc.}

proc jerasure_do_scheduled_operations*(ptrs: cstringArray; schedule: ptr ptr cint;
                                      packetsize: cint) {.importc.}

##  ------------------------------------------------------------
##  Matrix Inversion -------------------------------------------
##
##    The two matrix inversion functions work on rows*rows matrices of
##    ints.  If a bitmatrix, then each int will just be zero or one.
##    Otherwise, they will be elements of gf(2^w).  Obviously, you can
##    do bit matrices with crs_invert_matrix() and set w = 1, but
##    crs_invert_bitmatrix will be more efficient.
##    The two invertible functions return whether a matrix is invertible.
##    They are more efficient than the inverstion functions.
##    Mat will be destroyed when the matrix inversion or invertible
##    testing is done.  Sorry.
##    Inv must be allocated by the caller.
##    The two invert_matrix functions return 0 on success, and -1 if the
##    matrix is uninvertible.
##    The two invertible function simply return whether the matrix is
##    invertible.  (0 or 1). Mat will be destroyed.
##

proc jerasure_invert_matrix*(mat: ptr cint; inv: ptr cint; rows: cint; w: cint): cint {.importc.}
proc jerasure_invert_bitmatrix*(mat: ptr cint; inv: ptr cint; rows: cint): cint {.importc.}
proc jerasure_invertible_matrix*(mat: ptr cint; rows: cint; w: cint): cint {.importc.}
proc jerasure_invertible_bitmatrix*(mat: ptr cint; rows: cint): cint {.importc.}

##  ------------------------------------------------------------
##  Basic matrix operations -------------------------------------
##
##    Each of the print_matrix routines require a w.  In jerasure_print_matrix,
##    this is to calculate the field width.  In jerasure_print_bitmatrix, it is
##    to put spaces between the bits.
##    jerasure_matrix_multiply is a simple matrix multiplier in GF(2^w).  It returns a r1*c2
##    matrix, which is the product of the two input matrices.  It allocates
##    the product.  Obviously, c1 should equal r2.  However, this is not
##    validated by the procedure.
##

proc jerasure_matrix_multiply*(m1: ptr cint; m2: ptr cint; r1: cint; c1: cint; r2: cint;
                              c2: cint; w: cint): ptr cint {.importc.}
##  ------------------------------------------------------------
##  Stats ------------------------------------------------------
##
##   jerasure_get_stats fills in a vector of three doubles:
##       fill_in[0] is the number of bytes that have been XOR'd
##       fill_in[1] is the number of bytes that have been copied
##       fill_in[2] is the number of bytes that have been multiplied
##                  by a constant in GF(2^w)
##   When jerasure_get_stats() is called, it resets its values.
##

proc jerasure_get_stats*(fill_in: ptr cdouble) {.importc.}
proc jerasure_autoconf_test*(): cint {.importc.}


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
