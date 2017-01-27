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
import system

var gf_errno*: cint

const
  MAX_GF_INSTANCES* = 64
const
  ENOMEM* = 12
const
    EINVAL* = 22

type
  gf_val_32_t* = uint32
  gf_val_64_t* = uint64
  gf_val_128_t* = ptr uint64

type
  GFP* = object
    gf:int

type
  gf_region* = object
    w32*: proc (gf: GFP; src: pointer; dest: pointer; val: gf_val_32_t; bytes: cint;add: cint)
    w64*: proc (gf: GFP; src: pointer; dest: pointer; val: gf_val_64_t; bytes: cint;add: cint)
    w128*: proc (gf: GFP; src: pointer; dest: pointer; val: gf_val_128_t; bytes: cint;add: cint)

type
   gf_extract* = object
      w32*: proc (gf: GFP; start: pointer; bytes: cint; index: cint): gf_val_32_t
      w64*: proc (gf: GFP; start: pointer; bytes: cint; index: cint): gf_val_64_t
      w128*: proc (gf: GFP; start: pointer; bytes: cint; index: cint; rv: gf_val_128_t)

type
  gf_func_a* = object
    w32*: proc (gf: GFP; a: gf_val_32_t): gf_val_32_t
    w64*: proc (gf: GFP; a: gf_val_64_t): gf_val_64_t
    w128*: proc (gf: GFP; a: gf_val_128_t; b: gf_val_128_t)

type
  gf_func_a_b* = object
    w32*: proc (gf: GFP; a: gf_val_32_t; b: gf_val_32_t): gf_val_32_t
    w64*: proc (gf: GFP; a: gf_val_64_t; b: gf_val_64_t): gf_val_64_t
    w128*: proc (gf: GFP; a: gf_val_128_t; b: gf_val_128_t; c: gf_val_128_t)

type
  gf_t* = object
      multiply*: gf_func_a_b
      divide*: gf_func_a_b
      inverse*: gf_func_a
      multiply_region*: gf_region
      extract_word*: gf_extract
      scratch*: pointer

var gfp_array* : array[MAX_GF_INSTANCES, ptr gf_t]

proc galois_init_default_field*(w: cint): cint =
    if gfp_array[w] == nil:

      gfp_array[w] = cast[ptr gf_t](sizeof((gf_t)))
    if gfp_array[w] == nil:
      return ENOMEM

    if not gf_init_easy(gfp_array[w], w):
      return EINVAL

    return 0

proc galois_init*(w: cint) =
  if w <= 0 or w > 32:
    write(stderr, "ERROR -- cannot init default Galois field for w=%d\x0A", w)
    assert(false, "There was a problem!")
  case galois_init_default_field(w)
  of ENOMEM:
    write(stderr, "ERROR -- cannot allocate memory for Galois field w=%d\x0A", w)
    assert(0)
  of EINVAL:
    write(stderr, "ERROR -- cannot init default Galois field for w=%d\x0A", w)
    assert(0)


proc galois_uninit_field*(w: cint): cint =
    echo "Galois uninit field"

proc galois_change_technique*(gf: ptr gf_t; w: cint): cint =
    echo "Galious change technique"

proc galois_single_multiply*(x: cint; y: cint; w: cint): cint =
    if x == 0 or y == 0: return 0
    if gfp_array[w] == nil:
      galois_init(w)

    if w <= 32:
      return gfp_array[w].multiply.w32(gfp_array[w], x, y)
    else:
      fprintf(stderr, "ERROR -- Galois field not implemented for w=%d\x0A", w)
      return 0

proc galois_single_divide*(a: cint; b: cint; w: cint): cint =
    echo "Galious single divide"

proc galois_inverse*(x: cint; w: cint): cint =
   echo "Galois inverse"

proc galois_region_xor*(src: cstring; dest: cstring; nbytes: cint): cint =
   echo "Galois region"

  ##  Source Region
  ##  Dest Region (holds result)
##  Number of bytes in region
##  These multiply regions in w=8, w=16 and w=32.  They are much faster
##    than calling galois_single_multiply.  The regions must be long word aligned.

proc galois_w08_region_multiply*(region: cstring; multby: cint; nbytes: cint; r2: cstring; add: cint): cint =
  echo "Making this work"

  ##  Region to multiply
  ##  Number to multiply by
  ##  Number of bytes in region
  ##  If r2 != NULL, products go here.
  ##                                                        Otherwise region is overwritten
##  If (r2 != NULL && add) the produce is XOR'd with r2

proc galois_w16_region_multiply*(region: cstring; multby: cint; nbytes: cint; r2: cstring; add: cint): cint =
    echo "Galois w16 region multiply"
  ##  Region to multiply
  ##  Number to multiply by
  ##  Number of bytes in region
  ##  If r2 != NULL, products go here.
  ##                                                        Otherwise region is overwritten
##  If (r2 != NULL && add) the produce is XOR'd with r2

proc galois_w32_region_multiply*(region: cstring; multby: cint; nbytes: cint; r2: cstring; add: cint): cint =
   echo "galois_w32_region_multiply"

  ##  Region to multiply
  ##  Number to multiply by
  ##  Number of bytes in region
  ##  If r2 != NULL, products go here.
  ##                                                        Otherwise region is overwritten
##  If (r2 != NULL && add) the produce is XOR'd with r2

proc galois_init_field*(w: cint; mult_type: cint; region_type: cint; divide_type: cint; prim_poly: uint64; arg1: cint; arg2: cint): ptr gf_t =
    echo "Galois init field"

proc galois_init_composite_field*(w: cint; region_type: cint; divide_type: cint; degree: cint; base_gf: ptr gf_t): ptr gf_t =
    echo "Galois int composite field"

proc galois_get_field_ptr*(w: cint): ptr gf_t =
    echo "Galois get field ptr"

