##  *
##  Copyright (c) 2013, James S. Plank and Kevin Greenan
##  All rights reserved.
## 
##  Jerasure - A C/C++ Library for a Variety of Reed-Solomon and RAID-6 Erasure
##  Coding Techniques
## 
##  Revision 2.0: Galois Field backend now links to GF-Complete
## 
##  Redistribution and use in source and binary forms, with or without
##  modification, are permitted provided that the following conditions
##  are met:
## 
##   - Redistributions of source code must retain the above copyright
##     notice, this list of conditions and the following disclaimer.
## 
##   - Redistributions in binary form must reproduce the above copyright
##     notice, this list of conditions and the following disclaimer in
##     the documentation and/or other materials provided with the
##     distribution.
## 
##   - Neither the name of the University of Tennessee nor the names of its
##     contributors may be used to endorse or promote products derived
##     from this software without specific prior written permission.
## 
##  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
##  "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
##  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
##  A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
##  HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
##  INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
##  BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS
##  OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED
##  AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
##  LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY
##  WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
##  POSSIBILITY OF SUCH DAMAGE.
## 

##  This uses procedures from the Galois Field arithmetic library

import
  galois

##  ------------------------------------------------------------
##  In all of the routines below:
## 
##    k = Number of data devices
##    m = Number of coding devices
##    w = Word size
## 
##    data_ptrs = An array of k pointers to data which is size bytes.  
##                Size must be a multiple of sizeof(long).
##                Pointers must also be longword aligned.
##  
##    coding_ptrs = An array of m pointers to coding data which is size bytes.
## 
##    packetsize = The size of a coding block with bitmatrix coding. 
##                 When you code with a bitmatrix, you will use w packets
##                 of size packetsize.
## 
##    matrix = an array of k*m integers.  
##             It represents an m by k matrix.
##             Element i,j is in matrix[i*k+j];
## 
##    bitmatrix = an array of k*m*w*w integers.
##             It represents an mw by kw matrix.
##             Element i,j is in matrix[i*k*w+j];
## 
##    erasures = an array of id's of erased devices. 
##               Id's are integers between 0 and k+m-1.
##               Id's 0 to k-1 are id's of data devices.
##               Id's k to k+m-1 are id's of coding devices: 
##                   Coding device id = id-k.
##               If there are e erasures, erasures[e] = -1.
## 
##    schedule = an array of schedule operations.  
## 
##               If there are m operations, then schedule[m][0] = -1.
## 
##    operation = an array of 5 integers:
## 
##           0 = operation: 0 for copy, 1 for xor (-1 for end)
##           1 = source device (0 - k+m-1)
##           2 = source packet (0 - w-1)
##           3 = destination device (0 - k+m-1)
##           4 = destination packet (0 - w-1)
## 
##  ---------------------------------------------------------------
##  Bitmatrices / schedules ----------------------------------------
## 
##  - jerasure_matrix_to_bitmatrix turns a m X k matrix in GF(2^w) into a
##                               wm X wk bitmatrix (in GF(2)).  This is
##                               explained in the Cauchy Reed-Solomon coding
##                               paper.
## 
##  - jerasure_dumb_bitmatrix_to_schedule turns a bitmatrix into a schedule 
##                               using the straightforward algorithm -- just
##                               schedule the dot products defined by each
##                               row of the matrix.
## 
##  - jerasure_smart_bitmatrix_to_schedule turns a bitmatrix into a schedule,
##                               but tries to use previous dot products to
##                               calculate new ones.  This is the optimization
##                               explained in the original Liberation code paper.
## 
##  - jerasure_generate_schedule_cache precalcalculate all the schedule for the
##                               given distribution bitmatrix.  M must equal 2.
##  
##  - jerasure_free_schedule frees a schedule that was allocated with 
##                               jerasure_XXX_bitmatrix_to_schedule.
##  
##  - jerasure_free_schedule_cache frees a schedule cache that was created with 
##                               jerasure_generate_schedule_cache.
## 

proc jerasure_matrix_to_bitmatrix*(k: cint; m: cint; w: cint; matrix: ptr cint): ptr cint {.
    cdecl, importc: "jerasure_matrix_to_bitmatrix", dynlib: libname.}
proc jerasure_dumb_bitmatrix_to_schedule*(k: cint; m: cint; w: cint;
    bitmatrix: ptr cint): ptr ptr cint {.cdecl, importc: "jerasure_dumb_bitmatrix_to_schedule",
                                   dynlib: libname.}
proc jerasure_smart_bitmatrix_to_schedule*(k: cint; m: cint; w: cint;
    bitmatrix: ptr cint): ptr ptr cint {.cdecl, importc: "jerasure_smart_bitmatrix_to_schedule",
                                   dynlib: libname.}
proc jerasure_generate_schedule_cache*(k: cint; m: cint; w: cint; bitmatrix: ptr cint;
                                      smart: cint): ptr ptr ptr cint {.cdecl,
    importc: "jerasure_generate_schedule_cache", dynlib: libname.}
proc jerasure_free_schedule*(schedule: ptr ptr cint) {.cdecl,
    importc: "jerasure_free_schedule", dynlib: libname.}
proc jerasure_free_schedule_cache*(k: cint; m: cint; cache: ptr ptr ptr cint) {.cdecl,
    importc: "jerasure_free_schedule_cache", dynlib: libname.}
##  ------------------------------------------------------------
##  Encoding - these are all straightforward.  jerasure_matrix_encode only 
##    works with w = 8|16|32.

proc jerasure_do_parity*(k: cint; data_ptrs: cstringArray; parity_ptr: cstring;
                        size: cint) {.cdecl, importc: "jerasure_do_parity",
                                    dynlib: libname.}
proc jerasure_matrix_encode*(k: cint; m: cint; w: cint; matrix: ptr cint;
                            data_ptrs: cstringArray; coding_ptrs: cstringArray;
                            size: cint) {.cdecl, importc: "jerasure_matrix_encode",
                                        dynlib: libname.}
proc jerasure_bitmatrix_encode*(k: cint; m: cint; w: cint; bitmatrix: ptr cint;
                               data_ptrs: cstringArray; coding_ptrs: cstringArray;
                               size: cint; packetsize: cint) {.cdecl,
    importc: "jerasure_bitmatrix_encode", dynlib: libname.}
proc jerasure_schedule_encode*(k: cint; m: cint; w: cint; schedule: ptr ptr cint;
                              data_ptrs: cstringArray; coding_ptrs: cstringArray;
                              size: cint; packetsize: cint) {.cdecl,
    importc: "jerasure_schedule_encode", dynlib: libname.}
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
## 
##    jerasure_schedule_decode_lazy generates the schedule on the fly.
## 
##    jerasure_matrix_decode only works when w = 8|16|32.
## 
##    jerasure_make_decoding_matrix/bitmatrix make the k*k decoding matrix
##          (or wk*wk bitmatrix) by taking the rows corresponding to k
##          non-erased devices of the distribution matrix, and then
##          inverting that matrix.
## 
##          You should already have allocated the decoding matrix and
##          dm_ids, which is a vector of k integers.  These will be
##          filled in appropriately.  dm_ids[i] is the id of element
##          i of the survivors vector.  I.e. row i of the decoding matrix
##          times dm_ids equals data drive i.
## 
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
                            size: cint): cint {.cdecl,
    importc: "jerasure_matrix_decode", dynlib: libname.}
proc jerasure_bitmatrix_decode*(k: cint; m: cint; w: cint; bitmatrix: ptr cint;
                               row_k_ones: cint; erasures: ptr cint;
                               data_ptrs: cstringArray; coding_ptrs: cstringArray;
                               size: cint; packetsize: cint): cint {.cdecl,
    importc: "jerasure_bitmatrix_decode", dynlib: libname.}
proc jerasure_schedule_decode_lazy*(k: cint; m: cint; w: cint; bitmatrix: ptr cint;
                                   erasures: ptr cint; data_ptrs: cstringArray;
                                   coding_ptrs: cstringArray; size: cint;
                                   packetsize: cint; smart: cint): cint {.cdecl,
    importc: "jerasure_schedule_decode_lazy", dynlib: libname.}
proc jerasure_schedule_decode_cache*(k: cint; m: cint; w: cint;
                                    scache: ptr ptr ptr cint; erasures: ptr cint;
                                    data_ptrs: cstringArray;
                                    coding_ptrs: cstringArray; size: cint;
                                    packetsize: cint): cint {.cdecl,
    importc: "jerasure_schedule_decode_cache", dynlib: libname.}
proc jerasure_make_decoding_matrix*(k: cint; m: cint; w: cint; matrix: ptr cint;
                                   erased: ptr cint; decoding_matrix: ptr cint;
                                   dm_ids: ptr cint): cint {.cdecl,
    importc: "jerasure_make_decoding_matrix", dynlib: libname.}
proc jerasure_make_decoding_bitmatrix*(k: cint; m: cint; w: cint; matrix: ptr cint;
                                      erased: ptr cint; decoding_matrix: ptr cint;
                                      dm_ids: ptr cint): cint {.cdecl,
    importc: "jerasure_make_decoding_bitmatrix", dynlib: libname.}
proc jerasure_erasures_to_erased*(k: cint; m: cint; erasures: ptr cint): ptr cint {.cdecl,
    importc: "jerasure_erasures_to_erased", dynlib: libname.}
##  ------------------------------------------------------------
##  These perform dot products and schedules. -------------------
## 
##    src_ids is a matrix of k id's (0 - k-1 for data devices, k - k+m-1
##    for coding devices) that identify the source devices.  Dest_id is
##    the id of the destination device.
## 
##    jerasure_matrix_dotprod only works when w = 8|16|32.
## 
##    jerasure_do_scheduled_operations executes the schedule on w*packetsize worth of
##    bytes from each device.  ptrs is an array of pointers which should have as many
##    elements as the highest referenced device in the schedule.
## 
## 

proc jerasure_matrix_dotprod*(k: cint; w: cint; matrix_row: ptr cint; src_ids: ptr cint;
                             dest_id: cint; data_ptrs: cstringArray;
                             coding_ptrs: cstringArray; size: cint) {.cdecl,
    importc: "jerasure_matrix_dotprod", dynlib: libname.}
proc jerasure_bitmatrix_dotprod*(k: cint; w: cint; bitmatrix_row: ptr cint;
                                src_ids: ptr cint; dest_id: cint;
                                data_ptrs: cstringArray;
                                coding_ptrs: cstringArray; size: cint;
                                packetsize: cint) {.cdecl,
    importc: "jerasure_bitmatrix_dotprod", dynlib: libname.}
proc jerasure_do_scheduled_operations*(ptrs: cstringArray; schedule: ptr ptr cint;
                                      packetsize: cint) {.cdecl,
    importc: "jerasure_do_scheduled_operations", dynlib: libname.}
##  ------------------------------------------------------------
##  Matrix Inversion -------------------------------------------
## 
##    The two matrix inversion functions work on rows*rows matrices of
##    ints.  If a bitmatrix, then each int will just be zero or one.
##    Otherwise, they will be elements of gf(2^w).  Obviously, you can
##    do bit matrices with crs_invert_matrix() and set w = 1, but
##    crs_invert_bitmatrix will be more efficient.
## 
##    The two invertible functions return whether a matrix is invertible.
##    They are more efficient than the inverstion functions.
## 
##    Mat will be destroyed when the matrix inversion or invertible
##    testing is done.  Sorry.
## 
##    Inv must be allocated by the caller.
## 
##    The two invert_matrix functions return 0 on success, and -1 if the
##    matrix is uninvertible.
## 
##    The two invertible function simply return whether the matrix is
##    invertible.  (0 or 1). Mat will be destroyed.
## 

proc jerasure_invert_matrix*(mat: ptr cint; inv: ptr cint; rows: cint; w: cint): cint {.
    cdecl, importc: "jerasure_invert_matrix", dynlib: libname.}
proc jerasure_invert_bitmatrix*(mat: ptr cint; inv: ptr cint; rows: cint): cint {.cdecl,
    importc: "jerasure_invert_bitmatrix", dynlib: libname.}
proc jerasure_invertible_matrix*(mat: ptr cint; rows: cint; w: cint): cint {.cdecl,
    importc: "jerasure_invertible_matrix", dynlib: libname.}
proc jerasure_invertible_bitmatrix*(mat: ptr cint; rows: cint): cint {.cdecl,
    importc: "jerasure_invertible_bitmatrix", dynlib: libname.}
##  ------------------------------------------------------------
##  Basic matrix operations -------------------------------------
## 
##    Each of the print_matrix routines require a w.  In jerasure_print_matrix,
##    this is to calculate the field width.  In jerasure_print_bitmatrix, it is
##    to put spaces between the bits.
## 
##    jerasure_matrix_multiply is a simple matrix multiplier in GF(2^w).  It returns a r1*c2
##    matrix, which is the product of the two input matrices.  It allocates
##    the product.  Obviously, c1 should equal r2.  However, this is not
##    validated by the procedure.  
## 

proc jerasure_print_matrix*(matrix: ptr cint; rows: cint; cols: cint; w: cint) {.cdecl,
    importc: "jerasure_print_matrix", dynlib: libname.}
proc jerasure_print_bitmatrix*(matrix: ptr cint; rows: cint; cols: cint; w: cint) {.cdecl,
    importc: "jerasure_print_bitmatrix", dynlib: libname.}
proc jerasure_matrix_multiply*(m1: ptr cint; m2: ptr cint; r1: cint; c1: cint; r2: cint;
                              c2: cint; w: cint): ptr cint {.cdecl,
    importc: "jerasure_matrix_multiply", dynlib: libname.}
##  ------------------------------------------------------------
##  Stats ------------------------------------------------------
## 
##   jerasure_get_stats fills in a vector of three doubles:
## 
##       fill_in[0] is the number of bytes that have been XOR'd
##       fill_in[1] is the number of bytes that have been copied
##       fill_in[2] is the number of bytes that have been multiplied
##                  by a constant in GF(2^w)
## 
##   When jerasure_get_stats() is called, it resets its values.
## 

proc jerasure_get_stats*(fill_in: ptr cdouble) {.cdecl,
    importc: "jerasure_get_stats", dynlib: libname.}
proc jerasure_autoconf_test*(): cint {.cdecl, importc: "jerasure_autoconf_test",
                                    dynlib: libname.}