##  *
##  Copyright (c) 2014, James S. Plank and Kevin Greenan
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
##  Jerasure's authors:
## 
##    Revision 2.x - 2014: James S. Plank and Kevin M. Greenan
##    Revision 1.2 - 2008: James S. Plank, Scott Simmerman and Catherine D. Schuman.
##    Revision 1.0 - 2007: James S. Plank
## 

import
  galois

const
  MAX_GF_INSTANCES* = 64

var gfp_array*: array[MAX_GF_INSTANCES, ptr gf_t] = [0]

var gfp_is_composite*: array[MAX_GF_INSTANCES, cint] = [0]

proc galois_get_field_ptr*(w: cint): ptr gf_t =
  if gfp_array[w] != nil:
    return gfp_array[w]
  return nil

proc galois_init_field*(w: cint; mult_type: cint; region_type: cint; divide_type: cint;
                       prim_poly: uint64_t; arg1: cint; arg2: cint): ptr gf_t =
  var scratch_size: cint
  var scratch_memory: pointer
  var gfp: ptr gf_t
  if w <= 0 or w > 32:
    fprintf(stderr, "ERROR -- cannot init default Galois field for w=%d\x0A", w)
    assert(0)
  gfp = cast[ptr gf_t](malloc(sizeof((gf_t))))
  if not gfp:
    fprintf(stderr, "ERROR -- cannot allocate memory for Galois field w=%d\x0A", w)
    assert(0)
  scratch_size = gf_scratch_size(w, mult_type, region_type, divide_type, arg1, arg2)
  if not scratch_size:
    fprintf(stderr, "ERROR -- cannot get scratch size for base field w=%d\x0A", w)
    assert(0)
  scratch_memory = malloc(scratch_size)
  if not scratch_memory:
    fprintf(stderr, "ERROR -- cannot get scratch memory for base field w=%d\x0A",
            w)
    assert(0)
  if not gf_init_hard(gfp, w, mult_type, region_type, divide_type, prim_poly, arg1, arg2,
                    nil, scratch_memory):
    fprintf(stderr, "ERROR -- cannot init default Galois field for w=%d\x0A", w)
    assert(0)
  gfp_is_composite[w] = 0
  return gfp

proc galois_init_composite_field*(w: cint; region_type: cint; divide_type: cint;
                                 degree: cint; base_gf: ptr gf_t): ptr gf_t =
  var scratch_size: cint
  var scratch_memory: pointer
  var gfp: ptr gf_t
  if w <= 0 or w > 32:
    fprintf(stderr, "ERROR -- cannot init composite field for w=%d\x0A", w)
    assert(0)
  gfp = cast[ptr gf_t](malloc(sizeof((gf_t))))
  if not gfp:
    fprintf(stderr, "ERROR -- cannot allocate memory for Galois field w=%d\x0A", w)
    assert(0)
  scratch_size = gf_scratch_size(w, GF_MULT_COMPOSITE, region_type, divide_type,
                               degree, 0)
  if not scratch_size:
    fprintf(stderr,
            "ERROR -- cannot get scratch size for composite field w=%d\x0A", w)
    assert(0)
  scratch_memory = malloc(scratch_size)
  if not scratch_memory:
    fprintf(stderr,
            "ERROR -- cannot get scratch memory for composite field w=%d\x0A", w)
    assert(0)
  if not gf_init_hard(gfp, w, GF_MULT_COMPOSITE, region_type, divide_type, 0, degree, 0,
                    base_gf, scratch_memory):
    fprintf(stderr, "ERROR -- cannot init default composite field for w=%d\x0A", w)
    assert(0)
  gfp_is_composite[w] = 1
  return gfp

proc galois_init_default_field*(w: cint): cint =
  if gfp_array[w] == nil:
    gfp_array[w] = cast[ptr gf_t](malloc(sizeof((gf_t))))
    if gfp_array[w] == nil: return ENOMEM
    if not gf_init_easy(gfp_array[w], w): return EINVAL
  return 0

proc galois_uninit_field*(w: cint): cint =
  var ret: cint = 0
  if gfp_array[w] != nil:
    var recursive: cint = 1
    ret = gf_free(gfp_array[w], recursive)
    free(gfp_array[w])
    gfp_array[w] = nil
  return ret

proc galois_init*(w: cint) =
  if w <= 0 or w > 32:
    fprintf(stderr, "ERROR -- cannot init default Galois field for w=%d\x0A", w)
    assert(0)
  case galois_init_default_field(w)
  of ENOMEM:
    fprintf(stderr, "ERROR -- cannot allocate memory for Galois field w=%d\x0A", w)
    assert(0)
  of EINVAL:
    fprintf(stderr, "ERROR -- cannot init default Galois field for w=%d\x0A", w)
    assert(0)

proc is_valid_gf*(gf: ptr gf_t; w: cint): cint =
  ##  TODO: I assume we may eventually
  ##  want to do w=64 and 128, so w
  ##  will be needed to perform this check
  cast[nil](w)
  if gf == nil:
    return 0
  if gf.multiply.w32 == nil:
    return 0
  if gf.multiply_region.w32 == nil:
    return 0
  if gf.divide.w32 == nil:
    return 0
  if gf.inverse.w32 == nil:
    return 0
  if gf.extract_word.w32 == nil:
    return 0
  return 1

proc galois_change_technique*(gf: ptr gf_t; w: cint) =
  if w <= 0 or w > 32:
    fprintf(stderr, "ERROR -- cannot support Galois field for w=%d\x0A", w)
    assert(0)
  if not is_valid_gf(gf, w):
    fprintf(stderr, "ERROR -- overriding with invalid Galois field for w=%d\x0A",
            w)
    assert(0)
  if gfp_array[w] != nil:
    gf_free(gfp_array[w], gfp_is_composite[w])
  gfp_array[w] = gf

proc galois_single_multiply*(x: cint; y: cint; w: cint): cint =
  if x == 0 or y == 0: return 0
  if gfp_array[w] == nil:
    galois_init(w)
  if w <= 32:
    return gfp_array[w].multiply.w32(gfp_array[w], x, y)
  else:
    fprintf(stderr, "ERROR -- Galois field not implemented for w=%d\x0A", w)
    return 0

proc galois_single_divide*(x: cint; y: cint; w: cint): cint =
  if x == 0: return 0
  if y == 0: return - 1
  if gfp_array[w] == nil:
    galois_init(w)
  if w <= 32:
    return gfp_array[w].divide.w32(gfp_array[w], x, y)
  else:
    fprintf(stderr, "ERROR -- Galois field not implemented for w=%d\x0A", w)
    return 0

proc galois_w08_region_multiply*(region: cstring; multby: cint; nbytes: cint;
                                r2: cstring; add: cint) =
  ##  Region to multiply
  ##  Number to multiply by
  ##  Number of bytes in region
  ##  If r2 != NULL, products go here
  if gfp_array[8] == nil:
    galois_init(8)
  gfp_array[8].multiply_region.w32(gfp_array[8], region, r2, multby, nbytes, add)

proc galois_w16_region_multiply*(region: cstring; multby: cint; nbytes: cint;
                                r2: cstring; add: cint) =
  ##  Region to multiply
  ##  Number to multiply by
  ##  Number of bytes in region
  ##  If r2 != NULL, products go here
  if gfp_array[16] == nil:
    galois_init(16)
  gfp_array[16].multiply_region.w32(gfp_array[16], region, r2, multby, nbytes, add)

proc galois_w32_region_multiply*(region: cstring; multby: cint; nbytes: cint;
                                r2: cstring; add: cint) =
  ##  Region to multiply
  ##  Number to multiply by
  ##  Number of bytes in region
  ##  If r2 != NULL, products go here
  if gfp_array[32] == nil:
    galois_init(32)
  gfp_array[32].multiply_region.w32(gfp_array[32], region, r2, multby, nbytes, add)

proc galois_w8_region_xor*(src: pointer; dest: pointer; nbytes: cint) =
  if gfp_array[8] == nil:
    galois_init(8)
  gfp_array[8].multiply_region.w32(gfp_array[32], src, dest, 1, nbytes, 1)

proc galois_w16_region_xor*(src: pointer; dest: pointer; nbytes: cint) =
  if gfp_array[16] == nil:
    galois_init(16)
  gfp_array[16].multiply_region.w32(gfp_array[16], src, dest, 1, nbytes, 1)

proc galois_w32_region_xor*(src: pointer; dest: pointer; nbytes: cint) =
  if gfp_array[32] == nil:
    galois_init(32)
  gfp_array[32].multiply_region.w32(gfp_array[32], src, dest, 1, nbytes, 1)

proc galois_region_xor*(src: cstring; dest: cstring; nbytes: cint) =
  if nbytes >= 16:
    galois_w32_region_xor(src, dest, nbytes)
  else:
    var i: cint = 0
    i = 0
    while i < nbytes:
      dest[] = dest[] xor src[]
      inc(dest)
      inc(src)
      inc(i)

proc galois_inverse*(y: cint; w: cint): cint =
  if y == 0: return - 1
  return galois_single_divide(1, y, w)
