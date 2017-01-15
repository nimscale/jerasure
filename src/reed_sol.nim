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

proc reed_sol_vandermonde_coding_matrix*(k: cint; m: cint; w: cint): ptr cint =
    echo "Reed_sol vandaermonde coding matrix"

proc reed_sol_extended_vandermonde_matrix*(rows: cint; cols: cint; w: cint): ptr cint =
  #{.cdecl, importc: "reed_sol_extended_vandermonde_matrix", dynlib: libname.}
  echo "Reed sol extended vandermonde matrix"

proc reed_sol_big_vandermonde_distribution_matrix*(rows: cint; cols: cint; w: cint): ptr cint =
  #{.cdecl, importc: "reed_sol_big_vandermonde_distribution_matrix", dynlib: libname.}
  echo "Reed sol big vandermonde distribution matrix"

proc reed_sol_r6_encode*(k: cint; w: cint; data_ptrs: cstringArray; coding_ptrs: cstringArray; size: cint): cint =
  #{.cdecl,importc: "reed_sol_r6_encode", dynlib: libname.}
  echo "Reed sol r6 encode"

proc reed_sol_r6_coding_matrix*(k: cint; w: cint): ptr cint =
  #{.cdecl,importc: "reed_sol_r6_coding_matrix", dynlib: libname.}
  echo "Reed sol r6 coding matrix"

proc reed_sol_galois_w08_region_multby_2*(region: cstring; nbytes: cint): cint =
  #{.cdecl,importc: "reed_sol_galois_w08_region_multby_2", dynlib: libname.}
  echo "Reed sol galois w08 region multby_2"

proc reed_sol_galois_w16_region_multby_2*(region: cstring; nbytes: cint): cint =
  #{.cdecl,importc: "reed_sol_galois_w16_region_multby_2", dynlib: libname.}
  echo "Reed sol galois w16 region multiby 2"

proc reed_sol_galois_w32_region_multby_2*(region: cstring; nbytes: cint): cint =
  #{.cdecl,importc: "reed_sol_galois_w32_region_multby_2", dynlib: libname.}
  echo "Reed sol galois w32 region multby 2"
  
