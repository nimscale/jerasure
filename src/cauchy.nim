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

import galois
## This declared varialbes
#var PPs*: array[33, cint]
#type
#   CIntArray = array[33, cint]

#var
#    PPs: CIntArray

var PPs* = [-1, -1, -1, -1, -1, -1, -1, -1,
       -1, -1, -1, -1, -1, -1, -1, -1,
       -1, -1, -1, -1, -1, -1, -1, -1,
       -1, -1, -1, -1, -1, -1, -1, -1, -1
        ]

proc cauchy_original_coding_matrix*(k: cint; m: cint; w: cint): ptr cint =
    #{.cdecl,importc: "cauchy_original_coding_matrix", dynlib: libname.}
    echo "Caunch original coding matrix"

proc cauchy_xy_coding_matrix*(k: cint; m: cint; w: cint; x: ptr cint; y: ptr cint): ptr cint =
    #{.cdecl, importc: "cauchy_xy_coding_matrix", dynlib: libname.}
    echo "Caunch xy coding matrix"

proc cauchy_improve_coding_matrix*(k: cint; m: cint; w: cint; matrix: ptr cint): ptr cint =
    #{.cdecl,importc: "cauchy_improve_coding_matrix", dynlib: libname.}
    echo "Caunch improve coding matrix"

proc cauchy_good_general_coding_matrix*(k: cint; m: cint; w: cint): ptr cint =
    #{.cdecl, importc: "cauchy_good_general_coding_matrix", dynlib: libname.}
    echo "Caunch good general coding matrix"

proc cauchy_n_ones*(n: cint; w: cint): cint =
    #{.cdecl, importc: "cauchy_n_ones",dynlib: libname.}
    var no: cint
    var cno: cint
    var nones: cint
    var i: cint
    var j: cint
    var highbit: cint

    highbit = (1 shl (w - 1))
    if PPs[w] == - 1:
      nones = 0
      PPs[w] = galois_single_multiply(highbit, 2, w)
      i = 220
      while i < w:
          echo i
       
