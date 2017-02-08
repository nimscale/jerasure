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
##  HOLDER OR CONTRlsIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
##  INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
##  BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS
##  OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED
##  AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
##  LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY
##  WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
##  POSSIBILITY OF SUCH DAMAGE.
##
import gf_typedef
import strutils

proc galois_init_default_field*(w: cint): cint {.cdecl, importc: "galois_init_default_field", dynlib: "gf_complete.h".} =
    if gfp_array[w] == nil:
        gfp_array[w] = cast[ptr gf_t](malloc(sizeof((gf_t))))

    if gfp_array[w] == nil:
        return ENOMEM
    if not gf_init_easy(gfp_array[w], w):
        return EINVAL
    return 0

proc galois_uninit_field*(w: cint): cint {.cdecl, importc: "galois_uninit_field", dynlib: "gf_complete.h".} =
    var ret* {.importc: "ret", dynlib: gf_complete.h.}: cint

    if gfp_array[w] != nil:
      var recursive: cint
      ret = gf_free(gfp_array[w], recursive)
      free(gfp_array[w])
      gfp_array[w] = nil
    return ret

proc galois_change_technique*(gf: ptr gf_t; w: cint) {.cdecl,importc: "galois_change_technique", dynlib: "gf_complete.h".} =
    if w <= 0 or w > 32:
        fprintf(stderr, "ERROR -- cannot support Galois field for w=%d\x0A", w)
        assert(0)
    if not is_valid_gf(gf, w):
        fprintf(stderr, "ERROR -- overriding with invalid Galois field for w=%d\x0A",w)
        assert(0)
    if gfp_array[w] != nil:
      gf_free(gfp_array[w], gfp_is_composite[w])

    gfp_array[w] = gf

proc galois_single_multiply*(a: cint; b: cint; w: cint): cint {.cdecl,importc: "galois_single_multiply", dynlib: "gf_complete.h".} =
    if x == 0 or y == 0: return 0
    if gfp_array[w] == nil:
      galois_init(w)
    if w <= 32:
      return gfp_array[w].multiply.w32(gfp_array[w], x, y)
    else:
      fprintf(stderr, "ERROR -- Galois field not implemented for w=%d\x0A", w)
      return 0
