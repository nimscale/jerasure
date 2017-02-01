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
import errors, typedefinitions, galiosproc

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
# Template definistions follows
template SET_FUNCTION*(gf, `method`, size, `func`: untyped): void =
  nil

#gf.`method`.size = (`func`)
#(cast[ptr gf_internal_t]((gf).scratch)).`method` = `func`
#template SET_FUNCTION*(gf, `method`, size, `func`: untyped): void =
#  nil

#(gf).`method`.size = (`func`)

type
  gf_t* = object
      multiply*: gf_func_a_b
      divide*: gf_func_a_b
      inverse*: gf_func_a
      multiply_region*: gf_region
      extract_word*: gf_extract
      scratch*: pointer

var gfp_array* : array[MAX_GF_INSTANCES, ptr gf_t]

type
  gf_internal_t* = object
    mult_type*: cint
    region_type*: cint
    divide_type*: cint
    w*: cint
    prim_poly*: uint64
    free_me*: cint
    arg1*: cint
    arg2*: cint
    base_gf*: ptr gf_t
    private*: pointer
    log_g_table*: ptr gf_logtable_data

## The following were got from gf_complete.h
const
  GF_REGION_DEFAULT* = (0x00000000)
  GF_REGION_DOUBLE_TABLE* = (0x00000001)
  GF_REGION_QUAD_TABLE* = (0x00000002)
  GF_REGION_LAZY* = (0x00000004)
  GF_REGION_SIMD* = (0x00000008)
  GF_REGION_SSE* = (0x00000008)
  GF_REGION_NOSIMD* = (0x00000010)
  GF_REGION_NOSSE* = (0x00000010)
  GF_REGION_ALTMAP* = (0x00000020)
  GF_REGION_CAUCHY* = (0x00000040)

var mult_type, divide_type, region_type, gf_divide_matrix, gf_divide_euclid: int

type
  gf_division_type_t* {.size: sizeof(cint).} = enum
    GF_DIVIDE_DEFAULT, GF_DIVIDE_MATRIX, GF_DIVIDE_EUCLID

#var GF_DIVIDE_DEFAULT, GF_DIVIDE_MATRIX, GF_DIVIDE_EUCLID: cint

proc gf_composite_get_default_poly*(base: ptr gf_t): uint64 {.cdecl.} =
  var h: ptr gf_internal_t
  var rv: uint64
  h = cast[ptr gf_internal_t](base.scratch)
  if h.w == 4:
    if h.mult_type == cint(GF_MULT_COMPOSITE): return 0
    if h.prim_poly == 0x00000013: return 2
    return 0
  if h.w == 8:
    if h.mult_type == cint(GF_MULT_COMPOSITE): return 0
    if h.prim_poly == 0x0000011D: return 3
    return 0
  if h.w == 16:
    if h.mult_type == cint(GF_MULT_COMPOSITE):
      rv = gf_composite_get_default_poly(h.base_gf)
      if rv != h.prim_poly: return 0
      if rv == 3: return 0x00000105
      return 0
    else:
      if h.prim_poly == 0x0001100B: return 2
      if h.prim_poly == 0x0001002D: return 7
      return 0
  if h.w == 32:
    if h.mult_type == cint(GF_MULT_COMPOSITE):
      rv = gf_composite_get_default_poly(h.base_gf)
      if rv != h.prim_poly: return 0
      if rv == 2: return 0x00010005
      if rv == 7: return 0x00010008
      if rv == 0x00000105: return 0x00010002
      return 0
    else:
      if h.prim_poly == 0x00400007: return 2
      if h.prim_poly == 0x000000C5: return 3
      return 0
  if h.w == 64:
    if h.mult_type == cint(GF_MULT_COMPOSITE):
      rv = gf_composite_get_default_poly(h.base_gf)
      if rv != h.prim_poly: return 0
      if rv == 3:
        return uint64(0x0000000100000009'i64)
      if rv == 2:
        return uint64(0x0000000100000004'i64)
      if rv == 0x00010005:
        return uint64(0x0000000100000003'i64)
      if rv == 0x00010002:
        return uint64(0x0000000100000005'i64)
      if rv == 0x00010008:
        return uint64(0x0000000100000006'i64)
      return 0
    else:
      if h.prim_poly == 0x0000001B: return 2
      return 0
  return 0

proc gf_error_check*(w: cint; mult_type: cint; region_type: var cint; divide_type: var cint;
                    arg1: var cint; arg2: var cint; poly: uint64; base: ptr gf_t): cint {.cdecl.} =
  var sse3: cint
  var sse2: cint
  var pclmul: cint
  var
    rdouble: cint
    rquad: cint
    rlazy: cint
    rsimd: cint
    rnosimd: cint
    raltmap: cint
    rcauchy: cint
    tmp: cint
  var sub: ptr gf_internal_t

  ## Call the function to assign values to
  ## our defined error varialbes
  gf_error_assignment()

  rdouble = (region_type and GF_REGION_DOUBLE_TABLE)
  rquad = (region_type and GF_REGION_QUAD_TABLE)
  rlazy = (region_type and GF_REGION_LAZY)
  rsimd = (region_type and GF_REGION_SIMD)
  rnosimd = (region_type and GF_REGION_NOSIMD)
  raltmap = (region_type and GF_REGION_ALTMAP)
  rcauchy = (region_type and GF_REGION_CAUCHY)
  if divide_type != ord(GF_DIVIDE_DEFAULT) and divide_type != ord(GF_DIVIDE_MATRIX) and
      divide_type != ord(GF_DIVIDE_EUCLID):
    gf_errno = ord(GF_E_UNK_DIV)
    return 0

  tmp = (GF_REGION_DOUBLE_TABLE or GF_REGION_QUAD_TABLE or GF_REGION_LAZY or
      GF_REGION_SIMD or GF_REGION_NOSIMD or GF_REGION_ALTMAP or GF_REGION_CAUCHY)

  if bool(region_type and (not tmp)):
    gf_errno = ord(GF_E_UNK_REG)
    return 0
  when defined(INTEL_SSE2):
    if gf_cpu_supports_intel_sse2:
      sse2 = 1
  when defined(INTEL_SSSE3):
    if gf_cpu_supports_intel_ssse3:
      sse3 = 1
  when defined(INTEL_SSE4_PCLMUL):
    if gf_cpu_supports_intel_pclmul:
      pclmul = 1
  when defined(ARM_NEON):
    if gf_cpu_supports_arm_neon:
      pclmul = (w == 4 or w == 8)
      sse3 = 1
  if w < 1 or (w > 32 and w != 64 and w != 128):
    gf_errno = ord(GF_E_BAD_W)
    return 0
  if mult_type != ord(GF_MULT_COMPOSITE) and w < 64:
    if (poly shr uint64((w + 1)) ) != 0:
      gf_errno = ord(GF_E_BADPOLY)
      return 0
  if mult_type == ord(GF_MULT_DEFAULT):
    if divide_type != ord(GF_DIVIDE_DEFAULT):
      gf_errno = ord(GF_E_MDEFDIV)
      return 0
    if region_type != GF_REGION_DEFAULT:
      gf_errno = int32(GF_E_MDEFREG)
      return 0
    if arg1 != 0 or arg2 != 0:
      gf_errno = int32(GF_E_MDEFARG)
      return 0
    return 1
  if bool(rsimd and rnosimd):
    gf_errno = int32(GF_E_SIMD_NO)
    return 0
  if rcauchy + w > 32:
    gf_errno = int32(GF_E_CAUGT32)
    return 0
  if rcauchy + region_type != GF_REGION_CAUCHY:
    gf_errno = int32(GF_E_CAUCHYB)
    return 0
  if rcauchy + mult_type == int32(GF_MULT_COMPOSITE):
    gf_errno = int32(GF_E_CAUCOMP)
    return 0
  if arg1 != 0 and mult_type != cint(GF_MULT_COMPOSITE) and
      mult_type != cint(GF_MULT_SPLIT_TABLE) and mult_type != cint(GF_MULT_GROUP):
    gf_errno = int32(GF_E_ARG1SET)
    return 0
  if arg2 != 0 and mult_type != cint(GF_MULT_SPLIT_TABLE) and mult_type != cint(GF_MULT_GROUP):
    gf_errno = int32(GF_E_ARG2SET)
    return 0
  if divide_type == cint(GF_DIVIDE_MATRIX) and w > 32:
    gf_errno = cint(GF_E_MATRIXW)
    return 0
  if bool(rdouble):
    if bool(rquad):
      gf_errno = cint(GF_E_DOUQUAD)
      return 0
    if mult_type != cint(GF_MULT_TABLE):
      gf_errno = cint(GF_E_DOUBLET)
      return 0
    if w != 4 and w != 8:
      gf_errno = cint(GF_E_DOUBLEW)
      return 0
    if bool(rsimd or rnosimd or raltmap):
      gf_errno = cint(GF_E_DOUBLEJ)
      return 0
    if int32(rlazy and w) == 4:
      gf_errno = cint(GF_E_DOUBLEL)
      return 0
    return 1
  if bool(rquad):
    if mult_type != int32(GF_MULT_TABLE):
      gf_errno = int32(GF_E_QUAD_T)
      return 0
    if w != 4:
      gf_errno = cint(GF_E_QUAD_W)
      return 0
    if bool(rsimd or rnosimd or raltmap):
      gf_errno = cint(GF_E_QUAD_J)
      return 0
    return 1
  if bool(rlazy):
    gf_errno = cint(GF_E_LAZY_X)
    return 0
  if mult_type == cint(GF_MULT_SHIFT):
    if bool(raltmap):
      gf_errno = cint(GF_E_ALTSHIF)
      return 0
    if bool(rsimd or rnosimd):
      gf_errno = cint(GF_E_SSESHIF)
      return 0
    return 1
  if mult_type == cint(GF_MULT_CARRY_FREE):
    if w != 4 and w != 8 and w != 16 and w != 32 and w != 64 and w != 128:
      gf_errno = cint(GF_E_CFM_W)
      return 0
    if w == 4 and (poly == 0x0000000C):
      gf_errno = cint(GF_E_CFM4POL)
      return 0
    if w == 8 and (poly == 0x00000080):
      gf_errno = cint(GF_E_CFM8POL)
      return 0
    if w == 16 and (poly == 0x0000E000):
      gf_errno = cint(GF_E_CF16POL)
      return 0
    if w == 32 and (int64(poly) == 0xFE000000):
      gf_errno = cint(GF_E_CF32POL)
      return 0
    if w == 64 and (int64(poly) == 0xFFFE000000000000'i64):
      gf_errno = cint(GF_E_CF64POL)
      return 0
    if bool(raltmap):
      gf_errno = cint(GF_E_ALT_CFM)
      return 0
    if bool(rsimd or rnosimd):
      gf_errno = cint(GF_E_SSE_CFM)
      return 0
    if bool(not pclmul):
      gf_errno = cint(GF_E_PCLMULX)
      return 0
    return 1
  if mult_type == cint(GF_MULT_CARRY_FREE_GK):
    if w != 4 and w != 8 and w != 16 and w != 32 and w != 64 and w != 128:
      gf_errno = cint(GF_E_CFM_W)
      return 0
    if bool(raltmap):
      gf_errno = cint(GF_E_ALT_CFM)
      return 0
    if bool(rsimd or rnosimd):
      gf_errno = cint(GF_E_SSE_CFM)
      return 0
    if bool(not pclmul):
      gf_errno = cint(GF_E_PCLMULX)
      return 0
    return 1
  if mult_type == int64(GF_MULT_BYTWO_p) or mult_type == int64(GF_MULT_BYTWO_b):
    if bool(raltmap):
      gf_errno = cint(GF_E_ALT_BY2)
      return 0
    if bool(rsimd and not sse2):
      gf_errno = cint(GF_E_BY2_SSE)
      return 0
    return 1
  if mult_type == int64(GF_MULT_LOG_TABLE) or mult_type == int64(GF_MULT_LOG_ZERO) or
      mult_type == int64(GF_MULT_LOG_ZERO_EXT):
    if w > 27:
      gf_errno = cint(GF_E_LOGBADW)
      return 0
    if bool(raltmap or rsimd or rnosimd):
      gf_errno = cint(GF_E_LOG_J)
      return 0
    if mult_type == int64(GF_MULT_LOG_TABLE):
      return 1
    if w != 8 and w != 16:
      gf_errno = cint(GF_E_ZERBADW)
      return 0
    if mult_type == int64(GF_MULT_LOG_ZERO):
      return 1
    if w != 8:
      gf_errno = cint(GF_E_ZEXBADW)
      return 0
    return 1
  if mult_type == int64(GF_MULT_GROUP):
    if arg1 <= 0 or arg2 <= 0:
      gf_errno = cint(GF_E_GR_ARGX)
      return 0
    if w == 4 or w == 8:
      gf_errno = cint(GF_E_GR_W_48)
      return 0
    if w == 16 and (arg1 != 4 or arg2 != 4):
      gf_errno = cint(GF_E_GR_W_16)
      return 0
    if w == 128 and (arg1 != 4 or (arg2 != 4 and arg2 != 8 and arg2 != 16)):
      gf_errno = cint(GF_E_GR_128A)
      return 0
    if arg1 > 27 or arg2 > 27:
      gf_errno = cint(GF_E_GR_A_27)
      return 0
    if arg1 > w or arg2 > w:
      gf_errno = cint(GF_E_GR_AR_W)
      return 0
    if bool(raltmap or rsimd or rnosimd):
      gf_errno = cint(GF_E_GR_J)
      return 0
    return 1
  if mult_type == int64(GF_MULT_TABLE):
    if w != 16 and w >= 15:
      gf_errno = cint(GF_E_TABLE_W)
      return 0
    if w != 4:
        if bool(rsimd or rnosimd):
          gf_errno = cint(GF_E_TAB_SSE)
          return 0
        return 1

    if bool(rsimd and not sse3):
      gf_errno =cint(GF_E_TABSSE3)
      return 0
    if bool(raltmap):
      gf_errno = cint(GF_E_TAB_ALT)
      return 0
    return 1
  if mult_type == int64(GF_MULT_SPLIT_TABLE):
    if arg1 > arg2:
      tmp = arg1
      arg1 = arg2
      arg2 = tmp

    if w == 8:
      if arg1 != 4 or arg2 != 8:
        gf_errno = cint(GF_E_SP_8_AR)
        return 0
      if bool(rsimd and not sse3):
        gf_errno = cint(GF_E_SP_SSE3)
        return 0
      if bool(raltmap):
        gf_errno = cint(GF_E_SP_8_A)
        return 0
    elif w == 16:
      if (arg1 == 8 and arg2 == 8) or (arg1 == 8 and arg2 == 16):
        if bool(rsimd or rnosimd):
          gf_errno = cint(GF_E_SP_16_S)
          return 0
        if bool(raltmap):
          gf_errno = cint(GF_E_SP_16_A)
          return 0
      elif arg1 == 4 and arg2 == 16:
        if bool(rsimd and not sse3):
          gf_errno = cint(GF_E_SP_SSE3)
          return 0
      else:
        gf_errno = cint(GF_E_SP_16AR)
        return 0
    elif w == 32:
      if (arg1 == 8 and arg2 == 8) or (arg1 == 8 and arg2 == 32) or
          (arg1 == 16 and arg2 == 32):
        if bool(rsimd or rnosimd):
          gf_errno = cint(GF_E_SP_32_S)
          return 0
        if bool(raltmap):
          gf_errno = cint(GF_E_SP_32_A)
          return 0
      elif arg1 == 4 and arg2 == 32:
        if bool(rsimd and not sse3):
          gf_errno = cint(GF_E_SP_SSE3)
          return 0
        if bool(raltmap and not sse3):
          gf_errno = cint(GF_E_SP_32AS)
          return 0
        if bool(raltmap and rnosimd):
          gf_errno = cint(GF_E_SP_32AS)
          return 0
      else:
        gf_errno = cint(GF_E_SP_32AR)
        return 0
    elif w == 64:
      if (arg1 == 8 and arg2 == 8) or (arg1 == 8 and arg2 == 64) or
          (arg1 == 16 and arg2 == 64):
        if bool(rsimd or rnosimd):
          gf_errno = cint(GF_E_SP_64_S)
          return 0
        if bool(raltmap):
          gf_errno = cint(GF_E_SP_64_A)
          return 0
      elif arg1 == 4 and arg2 == 64:
        if bool(rsimd and not sse3):
          gf_errno = cint(GF_E_SP_SSE3)
          return 0
        if bool(raltmap and not sse3):
          gf_errno = cint(GF_E_SP_64AS)
          return 0
        if bool(raltmap and rnosimd):
          gf_errno = cint(GF_E_SP_64AS)
          return 0
      else:
        gf_errno = cint(GF_E_SP_64AR)
        return 0
    elif w == 128:
      if arg1 == 8 and arg2 == 128:
        if bool(rsimd or rnosimd):
          gf_errno = cint(GF_E_SP128_S)
          return 0
        if bool(raltmap):
          gf_errno = cint(GF_E_SP128_A)
          return 0
      elif arg1 == 4 and arg2 == 128:
        if bool(rsimd and not sse3):
          gf_errno = cint(GF_E_SP_SSE3)
          return 0
        if bool(raltmap and not sse3):
          gf_errno = cint(GF_E_SP128AS)
          return 0
        if bool(raltmap and rnosimd):
          gf_errno = cint(GF_E_SP128AS)
          return 0
      else:
        gf_errno = cint(GF_E_SP128AR)
        return 0
    else:
      gf_errno = cint(GF_E_SPLIT_W)
      return 0
    return 1
  if mult_type == int64(GF_MULT_COMPOSITE):
    if w != 8 and w != 16 and w != 32 and w != 64 and w != 128:
      gf_errno = cint(GF_E_COMP_W)
      return 0
    if w < 128 and (int64(poly) shr (w div 2)) != 0:
      gf_errno = cint(GF_E_COMP_PP)
      return 0
    if divide_type != ord(GF_DIVIDE_DEFAULT):
      gf_errno = cint(GF_E_DIVCOMP)
      return 0
    if arg1 != 2:
      gf_errno = cint(GF_E_COMP_A2)
      return 0
    if bool(rsimd or rnosimd):
      gf_errno = cint(GF_E_COMP_SS)
      return 0
    if base != nil:
      sub = cast[ptr gf_internal_t](base.scratch)
      if sub.w != w div 2:
        gf_errno = cint(GF_E_BASE_W)
        return 0
      if poly == 0:
        if gf_composite_get_default_poly(base) == 0:
          gf_errno = cint(GF_E_COMPXPP)
          return 0
    return 1
  gf_errno = cint(GF_E_UNKNOWN)
  return 0

proc gf_w4_scratch_size*(mult_type: cint; region_type: var cint; divide_type: var cint; arg1: var cint; arg2: var cint): cint {.cdecl.} =

  case mult_type
  of cint(GF_MULT_BYTWO_p), cint(GF_MULT_BYTWO_b):
    return int32(sizeof(gf_internal_t)+ sizeof(gf_bytwo_data))
  of cint(GF_MULT_DEFAULT), cint(GF_MULT_TABLE):
    if region_type == GF_REGION_CAUCHY:
      return int32(sizeof((gf_internal_t)) + sizeof(cast[gf_single_table_data](+ 64)))
    if mult_type == cint(GF_MULT_DEFAULT) and not bool((gf_cpu_supports_arm_neon or gf_cpu_supports_intel_ssse3)):

      region_type = GF_REGION_DOUBLE_TABLE
    if bool(region_type and GF_REGION_DOUBLE_TABLE):
      return int32(sizeof((gf_internal_t)) + sizeof(cast[gf_double_table_data](+ 64)))
    elif bool(region_type and GF_REGION_QUAD_TABLE):
      if (region_type and GF_REGION_LAZY) == 0:
        return int32(sizeof((gf_internal_t)) + sizeof(cast[gf_quad_table_data](+ 64)))
      else:
        return int32(sizeof((gf_internal_t)) + sizeof(cast[gf_quad_table_lazy_data](+ 64)))
    else:
      return int32(sizeof((gf_internal_t)) + sizeof(cast[gf_single_table_data](+ 64)))
  of int32(GF_MULT_LOG_TABLE):
    return int32(sizeof((gf_internal_t)) + sizeof(cast[gf_logtable_data](+ 64)))
  of int32(GF_MULT_CARRY_FREE):
    return int32(sizeof((gf_internal_t)))
  of int32(GF_MULT_SHIFT):
    return int32(sizeof((gf_internal_t)))
  else:
    return 0
  return 0

proc gf_w8_scratch_size*(mult_type: cint; region_type: var cint; divide_type: var cint;
                        arg1: cint; arg2: cint): cint {.cdecl.} =
  case mult_type
  of int32(GF_MULT_DEFAULT):
    if bool(gf_cpu_supports_intel_ssse3 or gf_cpu_supports_arm_neon):
      return int32(sizeof((gf_internal_t)) + sizeof(cast[gf_w8_default_data](+ 64)))

    return int32(sizeof((gf_internal_t)) + sizeof(cast[gf_w8_single_table_data](+ 64)))

  of int32(GF_MULT_TABLE):
    if region_type == GF_REGION_CAUCHY:
      return int32(sizeof((gf_internal_t)) + sizeof(cast[gf_w8_single_table_data](+ 64)))

    if bool(region_type == GF_REGION_DEFAULT):
      return int32(sizeof((gf_internal_t)) + sizeof(cast[gf_w8_single_table_data](+ 64)))

    if bool(region_type and GF_REGION_DOUBLE_TABLE):
      if region_type == GF_REGION_DOUBLE_TABLE:
        return int32(sizeof((gf_internal_t)) + sizeof(cast[gf_w8_double_table_data](+ 64)))

      elif region_type == (GF_REGION_DOUBLE_TABLE or GF_REGION_LAZY):
        return int32(sizeof((gf_internal_t)) + sizeof(cast[gf_w8_double_table_lazy_data](+ 64)))

      else:
        return 0
    return 0

  of int32(GF_MULT_BYTWO_p), int32(GF_MULT_BYTWO_b):
    return int32(sizeof((gf_internal_t)) + sizeof(gf_w8_bytwo_data))

  of int32(GF_MULT_SPLIT_TABLE):
    if (arg1 == 4 and arg2 == 8) or (arg1 == 8 and arg2 == 4):
      return int32(sizeof((gf_internal_t)) + sizeof(cast[gf_w8_half_table_data](+ 64)))

  of int32(GF_MULT_LOG_TABLE):
    return int32(sizeof((gf_internal_t)) + sizeof(cast[gf_w8_logtable_data](+ 64)))

  of int32(GF_MULT_LOG_ZERO):
    return int32(sizeof((gf_internal_t)) + sizeof(cast[gf_w8_logzero_small_table_data](+ 64)))

  of int32(GF_MULT_LOG_ZERO_EXT):
    return int32(sizeof((gf_internal_t)) + sizeof(cast[gf_w8_logzero_table_data](+ 64)))

  of int32(GF_MULT_CARRY_FREE):
    return cint(sizeof((gf_internal_t)))

  of int32(GF_MULT_SHIFT):
    return cint(sizeof((gf_internal_t)))

  of int32(GF_MULT_COMPOSITE):
    return cint(sizeof((gf_internal_t)) + sizeof(cast[gf_w8_composite_data](+ 64)))

  else:
    return 0
  return 0

proc gf_w16_scratch_size*(mult_type: cint; region_type: var cint; divide_type: var cint;
                         arg1: var cint; arg2: var cint): cint {.cdecl.} =
  case mult_type
  of cint(GF_MULT_TABLE):
    return cint(sizeof((gf_internal_t)) + sizeof(cast[gf_w16_lazytable_data](+ 64)))
  of cint(GF_MULT_BYTWO_p), cint(GF_MULT_BYTWO_b):
    return cint(sizeof((gf_internal_t)) + sizeof(gf_w16_bytwo_data))
  of cint(GF_MULT_LOG_ZERO):
    return cint(sizeof((gf_internal_t)) + sizeof(cast[gf_w16_zero_logtable_data](+ 64)))
  of cint(GF_MULT_LOG_TABLE):
    return cint(sizeof((gf_internal_t)) + sizeof(cast[gf_w16_logtable_data](+ 64)))
  of cint(GF_MULT_DEFAULT), cint(GF_MULT_SPLIT_TABLE):
    if arg1 == 8 and arg2 == 8:
      return cint(sizeof((gf_internal_t)) + sizeof(cast[gf_w16_split_8_8_data](+ 64)))
    elif (arg1 == 8 and arg2 == 16) or (arg2 == 8 and arg1 == 16):
      return cint(sizeof((gf_internal_t)) + sizeof(cast[gf_w16_logtable_data](+ 64)))
    elif mult_type == cint(GF_MULT_DEFAULT) or (arg1 == 4 and arg2 == 16) or (arg2 == 4 and arg1 == 16):
      return cint(sizeof((gf_internal_t)) + sizeof(cast[gf_w16_logtable_data](+ 64)))
    return 0
  of cint(GF_MULT_GROUP):
    return cint(sizeof((gf_internal_t)) + sizeof(cast[gf_w16_group_4_4_data](+ 64)))
  of cint(GF_MULT_CARRY_FREE):
    return cint(sizeof((gf_internal_t)))
  of cint(GF_MULT_SHIFT):
    return cint(sizeof((gf_internal_t)))
  of cint(GF_MULT_COMPOSITE):
    return cint(sizeof((gf_internal_t)) + sizeof(cast[gf_w16_composite_data](+ 64)))
  else:
    return 0
  return 0

proc gf_w32_scratch_size*(mult_type: cint; region_type: var cint; divide_type: var cint;
                         arg1: var cint; arg2: var cint): cint {.cdecl.} =
  case mult_type
  of cint(GF_MULT_BYTWO_p), cint(GF_MULT_BYTWO_b):
    return cint(sizeof(gf_internal_t)+ sizeof(cast[gf_w32_bytwo_data](+ 64)))

  of cint(GF_MULT_GROUP):
    #return sizeof(gf_internal_t)  + sizeof(cast[gf_w32_group_data](+ sizeof(int32))) * (1 shl arg1)))) + sizeof((int32) * (1 shl arg2)) + 64
    return cint(sizeof(gf_internal_t) + sizeof(cast[gf_w32_group_data]( + cint(cint(sizeof(uint32)   * cint(1 shl arg1))))) + cint(cint(sizeof(int32)) * cint(1 shl arg2) + 64))
    #return  sizeof(cast[gf_w32_group_data](+ sizeof(int32)))  #* (1 shl arg1)))) + sizeof(int32) * (1 shl arg2) + 64

  of cint(GF_MULT_DEFAULT), cint(GF_MULT_SPLIT_TABLE):
    if arg1 == 8 and arg2 == 8:
      return cint(sizeof((gf_internal_t)) + sizeof(cast[gf_w32_split_8_8_data](+ 64)))
    if (arg1 == 16 and arg2 == 32) or (arg2 == 16 and arg1 == 32):
      return cint(sizeof((gf_internal_t)) + sizeof(cast[gf_split_16_32_lazy_data](+ 64)))
    if (arg1 == 2 and arg2 == 32) or (arg2 == 2 and arg1 == 32):
      return cint(sizeof((gf_internal_t)) + sizeof(cast[gf_split_2_32_lazy_data](+ 64)))
    if (arg1 == 8 and arg2 == 32) or (arg2 == 8 and arg1 == 32) or
          (bool(mult_type == cint(GF_MULT_DEFAULT)) and not bool((gf_cpu_supports_intel_ssse3 or gf_cpu_supports_arm_neon))):

      return cint(sizeof((gf_internal_t)) + sizeof(cast[gf_split_8_32_lazy_data](+ 64)))

    if (arg1 == 4 and arg2 == 32) or (arg2 == 4 and arg1 == 32) or mult_type == cint(GF_MULT_DEFAULT):
      return cint(sizeof((gf_internal_t)) + sizeof(cast[gf_split_4_32_lazy_data](+ 64)))
    return 0
  of cint(GF_MULT_CARRY_FREE):
    return cint(sizeof((gf_internal_t)))
  of cint(GF_MULT_CARRY_FREE_GK):
    return cint(sizeof((gf_internal_t)) + (cint(sizeof((uint64))) * 2))

  of cint(GF_MULT_SHIFT):
    return cint(sizeof((gf_internal_t)))

  of cint(GF_MULT_COMPOSITE):
    return cint(sizeof((gf_internal_t)) + sizeof(cast[gf_w32_composite_data](+ 64)))
  else:
    return 0
  return 0

proc gf_w64_scratch_size*(mult_type: cint; region_type: var cint; divide_type: var cint;
                         arg1: var cint; arg2: var cint): cint {.cdecl.} =
  case mult_type
  of cint(GF_MULT_SHIFT):
    return cint(sizeof((gf_internal_t)))
  of cint(GF_MULT_CARRY_FREE):
    return cint(sizeof((gf_internal_t)))
  of cint(GF_MULT_BYTWO_p), cint(GF_MULT_BYTWO_b):
    return cint(sizeof((gf_internal_t)))
  of cint(GF_MULT_DEFAULT): ##  Allen: set the *local* arg1 and arg2, just for scratch size purposes,
                    ##  then fall through to split table scratch size code.
                    ## #if defined(INTEL_SSE4) || defined(ARCH_AARCH64)
    if bool(gf_cpu_supports_intel_sse4 or gf_cpu_supports_arm_neon):
      arg1 = 64
      arg2 = 4
    else:
      ## #endif
      arg1 = 64
      arg2 = 8
      ## #if defined(INTEL_SSE4) || defined(ARCH_AARCH64)
    ## #endif
  of cint(GF_MULT_SPLIT_TABLE):
    if arg1 == 8 and arg2 == 8:
      return cint(sizeof((gf_internal_t)) + sizeof(cast[gf_split_8_8_data](+ 64)))
    if (arg1 == 16 and arg2 == 64) or (arg2 == 16 and arg1 == 64):
      return cint(sizeof((gf_internal_t)) + sizeof(cast[gf_split_16_64_lazy_data](+ 64)))
    if (arg1 == 8 and arg2 == 64) or (arg2 == 8 and arg1 == 64):
      return cint(sizeof((gf_internal_t)) + sizeof(cast[gf_split_8_64_lazy_data](+ 64)))
    if (arg1 == 64 and arg2 == 4) or (arg1 == 4 and arg2 == 64):
      return cint(sizeof((gf_internal_t)) + sizeof(cast[gf_split_4_64_lazy_data](+ 64)))
    return 0
  of cint(GF_MULT_GROUP):
    return cint(sizeof(gf_internal_t) + sizeof(cast[gf_w64_group_data]( + cint(cint(sizeof(uint64)   * cint(1 shl arg1))))) + cint(cint(sizeof(uint64)) * cint(1 shl arg2) + 64))
    #return cint(sizeof(gf_internal_t) + sizeof(cast[gf_w32_group_data]( + cint(cint(sizeof(uint32)   * cint(1 shl arg1))))) + cint(cint(sizeof(int32)) * cint(1 shl arg2) + 64))

  of cint(GF_MULT_COMPOSITE):
    if arg1 == 2:
      return cint(sizeof((gf_internal_t)) + 64)
    return 0
  else:
    return 0

proc gf_w128_scratch_size*(mult_type: cint; region_type: var cint; divide_type: var cint;
                          arg1: var cint; arg2: var cint): cint {.cdecl.} =
  var
    size_m: cint
    size_r: cint
  if divide_type == cint(GF_DIVIDE_MATRIX):
    return 0
  case mult_type
  of cint(GF_MULT_CARRY_FREE):
    return cint(sizeof(gf_internal_t))
  of cint(GF_MULT_SHIFT):
    return cint(sizeof(gf_internal_t))

  of cint(GF_MULT_BYTWO_p), cint(GF_MULT_BYTWO_b):
    return cint(sizeof(gf_internal_t))

  of cint(GF_MULT_DEFAULT), cint(GF_MULT_SPLIT_TABLE):
    if (arg1 == 4 and arg2 == 128) or (arg1 == 128 and arg2 == 4):
      return cint(sizeof((gf_internal_t)) + sizeof(cast[gf_w128_split_4_128_data](+ 64)))

    elif (arg1 == 8 and arg2 == 128) or (arg1 == 128 and arg2 == 8) or
        mult_type == cint(GF_MULT_DEFAULT):
      return cint(sizeof((gf_internal_t)) + sizeof(cast[gf_w128_split_8_128_data](+ 64)))
    return 0
  of cint(GF_MULT_GROUP):            ##  JSP We've already error checked the arguments.
    size_m = cint((1 shl arg1) * 2 * sizeof((uint64)))
    size_r = cint((1 shl arg2) * 2 * sizeof((uint64)))
    ##
    ##  two pointers prepend the table data for structure
    ##  because the tables are of dynamic size
    ##
    return cint(sizeof(gf_internal_t) + size_m + size_r + 4 * sizeof(ptr uint64))

  of cint(GF_MULT_COMPOSITE):
    if arg1 == 2:
      return cint(sizeof((gf_internal_t)) + 4)
    else:
      return 0
  else:
    return 0

proc gf_wgen_scratch_size*(w: cint; mult_type: cint; region_type: var cint;
                          divide_type: var cint; arg1: var cint; arg2: var cint): cint {.cdecl.} =
  case mult_type
  of cint(GF_MULT_DEFAULT):
    if w <= 8:
      return cint(sizeof(gf_internal_t) + sizeof(cast[gf_wgen_table_w8_data] ( + cint(cint(sizeof(uint8)    * cint(1 shl w))))) * cint(cint(1 shl w) * 2) + 64)
      #return cint(sizeof(gf_internal_t) + sizeof(cast[gf_w64_group_data] ( + cint(cint(sizeof(uint64)   * cint(1 shl arg1))))) + cint(cint(sizeof(uint64)) * cint(1 shl arg2) + 64))

    elif w <= 16:
      return cint(sizeof(gf_internal_t) + sizeof(cast[gf_wgen_log_w16_data]  ( + cint(cint(sizeof(uint16)   * cint(1 shl w) * 3)))))
      #return cint(sizeof(gf_internal_t) + sizeof(cast[gf_wgen_table_w8_data] ( + cint(cint(sizeof(uint8)    * cint(1 shl w))))) * cint(cint(1 shl w) * 2) + 64)

    else:
      return cint(sizeof(gf_internal_t) + sizeof(cast[gf_wgen_group_data]    ( + cint(cint(sizeof(uint32)   * cint(1 shl 2))))) + cint(cint(sizeof(uint32) * (1 shl 8))) + 64)
      #return cint(sizeof(gf_internal_t) + sizeof(cast[gf_wgen_table_w8_data] ( + cint(cint(sizeof(uint8)    * cint(1 shl w))))) * cint(cint(1 shl w) * 2) + 64)

  of cint(GF_MULT_SHIFT), cint(GF_MULT_BYTWO_b), cint(GF_MULT_BYTWO_p):
    return cint(sizeof(gf_internal_t))

  of cint(GF_MULT_GROUP):
    return cint(sizeof(gf_internal_t) + sizeof(cast[gf_wgen_group_data]    ( + cint(cint(sizeof(uint32)   * cint(1 shl arg1))))) + cint(cint(sizeof(uint32) * (1 shl arg2))) + 64)
    #return cint(sizeof(gf_internal_t) + sizeof(cast[gf_wgen_group_data]    ( + cint(cint(sizeof(uint32)   * cint(1 shl 2)))))    + cint(cint(sizeof(uint32) * (1 shl 8))) + 64)

  of cint(GF_MULT_TABLE):
    if w <= 8:
      return cint(sizeof(gf_internal_t) + sizeof(cast[gf_wgen_table_w8_data] (+ cint(cint(sizeof(uint8)    * cint(1 shl w))))) * cint(cint((1 shl w) * 2)) + 64)
      #return cint(sizeof(gf_internal_t) + sizeof(cast[gf_wgen_group_data]    ( + cint(cint(sizeof(uint32)   * cint(1 shl arg1))))) + cint(cint(sizeof(uint32) * (1 shl arg2))) + 64)

    elif w < 15:
      return cint(sizeof(gf_internal_t) + sizeof(cast[gf_wgen_table_w16_data](+ cint(cint(sizeof(uint16)   * cint(1 shl w))))) * cint(cint((1 shl w) * 2)) + 64)
      #return cint(sizeof(gf_internal_t) + sizeof(cast[gf_wgen_table_w8_data] (+ cint(cint(sizeof(uint8)    * cint(1 shl w))))) * cint(cint((1 shl w) * 2)) + 64)

    return 0
  of cint(GF_MULT_LOG_TABLE):
    if w <= 8:
      return cint(sizeof(gf_internal_t) + sizeof(cast[gf_wgen_log_w8_data]   (+ cint(cint(sizeof(uint8)    * cint(1 shl w))))) * 3)
      #return cint(sizeof(gf_internal_t) + sizeof(cast[gf_wgen_table_w8_data] (+ cint(cint(sizeof(uint8)    * cint(1 shl w))))) * cint(cint((1 shl w) * 2)) + 64)

    elif w <= 16:
      return cint(sizeof(gf_internal_t) + sizeof(cast[gf_wgen_log_w16_data]  (+ cint(cint(sizeof(uint16)   * cint(1 shl w))))) * 3)
      #return cint(sizeof(gf_internal_t) + sizeof(cast[gf_wgen_log_w8_data]   (+ cint(cint(sizeof(uint8)    * cint(1 shl w))))) * 3)

    elif w <= 27:
      return cint(sizeof((gf_internal_t)) + sizeof(cast[gf_wgen_log_w32_data](+ cint(cint(sizeof(uint32)   * cint(1 shl w))))) * 3)
      #return cint(sizeof(gf_internal_t) + sizeof(cast[gf_wgen_log_w8_data]   (+ cint(cint(sizeof(uint8)    * cint(1 shl w))))) * 3)

    else:
      return 0
  else:
    return 0


proc gf_scratch_size*(w: cint; mult_type: cint; region_type: var cint; divide_type: var cint;
                     arg1: var cint; arg2:  var cint): cint {.cdecl.} =

  #gf_error_check*(w: cint; mult_type: cint; region_type: var cint; divide_type: var cint; arg1: var cint; arg2: var cint; poly: uint64; base: ptr gf_t):

  if gf_error_check(w, mult_type, region_type, divide_type, arg1, arg2, 0, nil) == 0:
    return 0
  case w
  of 4:
    return gf_w4_scratch_size(mult_type, region_type, divide_type, arg1, arg2)
  of 8:
    return gf_w8_scratch_size(mult_type, region_type, divide_type, arg1, arg2)
  of 16:
    return gf_w16_scratch_size(mult_type, region_type, divide_type, arg1, arg2)
  of 32:
    return gf_w32_scratch_size(mult_type, region_type, divide_type, arg1, arg2)
  of 64:
    return gf_w64_scratch_size(mult_type, region_type, divide_type, arg1, arg2)
  of 128:
    return gf_w128_scratch_size(mult_type, region_type, divide_type, arg1, arg2)
  else:
    return gf_wgen_scratch_size(w, mult_type, region_type, divide_type, arg1, arg2)

proc gf_w4_cfm_init*(gf: ptr gf_t): cint {.cdecl.} =
  when defined(INTEL_SSE4_PCLMUL):
    if gf_cpu_supports_intel_pclmul:
      SET_FUNCTION(gf, multiply, w32, gf_w4_clm_multiply)
      return 1
  elif defined(ARM_NEON):
    if gf_cpu_supports_arm_neon:
      return gf_w4_neon_cfm_init(gf)
  return 0

proc gf_w4_shift_init*(gf: ptr gf_t): cint {.cdecl.} =
  SET_FUNCTION(gf, multiply, w32, gf_w4_shift_multiply)
  return 1

proc gf_w4_bytwo_init*(gf: ptr gf_t): cint {.cdecl.} =
  var h: ptr gf_internal_t
  var
    ip: uint64
    m1: uint64
    m2: uint64
  var btd: ptr gf_bytwo_data
  h = cast[ptr gf_internal_t](gf.scratch)
  btd = cast[ptr gf_bytwo_data]((h.private))
  ip = h.prim_poly and 0x0000000F
  m1 = 0x0000000E
  m2 = 0x00000008
  btd.prim_poly = 0
  btd.mask1 = 0
  btd.mask2 = 0
  while ip != 0:
    btd.prim_poly = btd.prim_poly or ip
    btd.mask1 = btd.mask1 or m1
    btd.mask2 = btd.mask2 or m2
    ip = ip shl GF_FIELD_WIDTH
    m1 = m1 shl GF_FIELD_WIDTH
    m2 = m2 shl GF_FIELD_WIDTH
  if h.mult_type == cint(GF_MULT_BYTWO_p):
    SET_FUNCTION(gf, multiply, w32, gf_w4_bytwo_p_multiply)
    ## #ifdef INTEL_SSE2
    if bool(gf_cpu_supports_intel_sse2 and not (h.region_type and GF_REGION_NOSIMD)):
      SET_FUNCTION(gf, multiply_region, w32, gf_w4_bytwo_p_sse_multiply_region)
    else:
      ##     #endif
      SET_FUNCTION(gf, multiply_region, w32, gf_w4_bytwo_p_nosse_multiply_region)
      if bool(h.region_type and GF_REGION_SIMD):
        return 0
    ## #endif
  else:
    SET_FUNCTION(gf, multiply, w32, gf_w4_bytwo_b_multiply)
    ## #ifdef INTEL_SSE2
    if bool(gf_cpu_supports_intel_sse2 and not (h.region_type and GF_REGION_NOSIMD)):
      SET_FUNCTION(gf, multiply_region, w32, gf_w4_bytwo_b_sse_multiply_region)
    else:
      ## #endif
      SET_FUNCTION(gf, multiply_region, w32, gf_w4_bytwo_b_nosse_multiply_region)
      if bool(h.region_type and GF_REGION_SIMD):
        return 0
    ## #ifdef INTEL_SSE2
  ## #endif
  return 1

proc gf_w4_log_init*(gf: ptr gf_t): cint {.cdecl.} =
  var h: ptr gf_internal_t
  var ltd: ptr gf_logtable_data
  var
    i: cint
    b: cint
  h = cast[ptr gf_internal_t](gf.scratch)
  ltd = h.log_g_table
  i = 0
  while i < GF_FIELD_SIZE:
    ltd.log_tbl[i] = 0
    inc(i)
  echo (GF_FIELD_SIZE - 1)

  #var N = cast[ptr uint8](c)
  #ltd.antilog_tbl_div =  ltd.antilog_tbl[GF_FIELD_SIZE - 1] + (GF_FIELD_SIZE - 1)
  ltd.antilog_tbl_div = cast[ptr uint8](ltd.antilog_tbl[GF_FIELD_SIZE - 1] + (GF_FIELD_SIZE - 1))
  b = 1
  i = 0
  while true:
    if ltd.log_tbl[b] != 0 and i != 0:
      write(stderr, "Cannot construct log table: Polynomial is not primitive.\x0A\x0A")
      return 0
    ltd.log_tbl[b] = uint8(i)
    ltd.antilog_tbl[i] = uint8(b)
    ltd.antilog_tbl[i + GF_FIELD_SIZE - 1] = uint8(b)
    b = b shl 1
    inc(i)
    if bool(b and GF_FIELD_SIZE):
      b = b xor cint(h.prim_poly)

    if not (b != 1): break
  if i != GF_FIELD_SIZE - 1:
    gf_errno = cint(GF_E_LOGPOLY)
    return 0
  SET_FUNCTION(gf, inverse, w32, gf_w4_inverse_from_divide)
  SET_FUNCTION(gf, divide, w32, gf_w4_log_divide)
  SET_FUNCTION(gf, multiply, w32, gf_w4_log_multiply)
  SET_FUNCTION(gf, multiply_region, w32, gf_w4_log_multiply_region)
  return 1

proc gf_w4_shift_multiply*(gf: ptr gf_t; a: gf_val_32_t; b: gf_val_32_t): gf_val_32_t {.
    inline, cdecl.} =
  var
    product: uint8
    i: uint8
    pp: uint8
  var h: ptr gf_internal_t
  h = cast[ptr gf_internal_t](gf.scratch)
  pp = uint8(h.prim_poly)
  product = 0
  i = 0
  while i < GF_FIELD_WIDTH:
    if bool(int64(a) and (1 shl int32(i))):
      product = uint8(uint8(product) xor (uint8(b) shl uint8(i)))
      inc(i)

  i = (GF_FIELD_WIDTH * 2 - 2)
  while cint(i) >= cint(GF_FIELD_WIDTH):
    if bool(int32(product) and (1 shl int32(i))):
       product = product xor (pp shl (i - GF_FIELD_WIDTH))
       dec(i)
  return product

proc gf_w4_double_table_init*(gf: ptr gf_t): cint {.cdecl.} =
  var h: ptr gf_internal_t
  var std: ptr gf_double_table_data
  var
    a: cint
    b: cint
    c: cint
    prod: cint
    ab: cint
  var mult: array[GF_FIELD_SIZE, array[GF_FIELD_SIZE, uint8]]
  h = cast[ptr gf_internal_t](gf.scratch)
  std = cast[ptr gf_double_table_data](h.private)
  #bzero(mult, sizeof((uint8_t) * GF_FIELD_SIZE * GF_FIELD_SIZE))
  #bzero(std.`div`, sizeof((uint8_t) * GF_FIELD_SIZE * GF_FIELD_SIZE))
  a = 1
  while a < GF_FIELD_SIZE:
    b = 1
    while b < GF_FIELD_SIZE:
      prod = gf_w4_shift_multiply(gf, a, b)
      mult[a][b] = prod
      std.`div`[prod][b] = a
      inc(b)
    inc(a)
  #bzero(std.mult,
  #      sizeof((uint8) * GF_FIELD_SIZE * GF_FIELD_SIZE * GF_FIELD_SIZE))
  a = 0
  while a < GF_FIELD_SIZE:
    b = 0
    while b < GF_FIELD_SIZE:
      ab = mult[a][b]
      c = 0
      while c < GF_FIELD_SIZE:
        std.mult[a][(b shl 4) or c] = ((ab shl 4) or mult[a][c])
        inc(c)
      inc(b)
    inc(a)
  SET_FUNCTION(gf, inverse, w32, nil)
  SET_FUNCTION(gf, divide, w32, gf_w4_double_table_divide)
  SET_FUNCTION(gf, multiply, w32, gf_w4_double_table_multiply)
  SET_FUNCTION(gf, multiply_region, w32, gf_w4_double_table_multiply_region)
  return 1


proc gf_w4_table_init*(gf: ptr gf_t): cint {.cdecl.} =
  var rt: cint
  var h: ptr gf_internal_t
  h = cast[ptr gf_internal_t](gf.scratch)
  rt = (h.region_type)
  if h.mult_type == cint(GF_MULT_DEFAULT) and not bool(gf_cpu_supports_intel_ssse3 or gf_cpu_supports_arm_neon):
    rt = rt or GF_REGION_DOUBLE_TABLE
  if bool(rt and GF_REGION_DOUBLE_TABLE):
    return gf_w4_double_table_init(gf)
  elif rt and GF_REGION_QUAD_TABLE:
    if rt and GF_REGION_LAZY:
      return gf_w4_quad_table_lazy_init(gf)
    else:
      return gf_w4_quad_table_init(gf)
  else:
    return gf_w4_single_table_init(gf)
  return 0


proc gf_w4_init*(gf: ptr gf_t): cint {.cdecl.} =
  var h: ptr gf_internal_t
  h = cast[ptr gf_internal_t](gf.scratch)
  if h.prim_poly == 0: h.prim_poly = 0x00000013
  h.prim_poly = h.prim_poly or 0x00000010
  SET_FUNCTION(gf, multiply, w32, nil)
  SET_FUNCTION(gf, divide, w32, nil)
  SET_FUNCTION(gf, inverse, w32, nil)
  SET_FUNCTION(gf, multiply_region, w32, nil)
  SET_FUNCTION(gf, extract_word, w32, gf_w4_extract_word)
  case h.mult_type
  of cint(GF_MULT_CARRY_FREE):
    if gf_w4_cfm_init(gf) == 0: return 0
  of cint(GF_MULT_SHIFT):
    if gf_w4_shift_init(gf) == 0: return 0
  of cint(GF_MULT_BYTWO_p), cint(GF_MULT_BYTWO_b):
    if gf_w4_bytwo_init(gf) == 0: return 0
  of cint(GF_MULT_LOG_TABLE):
    if gf_w4_log_init(gf) == 0: return 0
  of cint(GF_MULT_DEFAULT), cint(GF_MULT_TABLE):
    if gf_w4_table_init(gf) == 0: return 0
  else:
    return 0
  if h.divide_type == cint(GF_DIVIDE_EUCLID):
    SET_FUNCTION(gf, divide, w32, gf_w4_divide_from_inverse)
    SET_FUNCTION(gf, inverse, w32, gf_w4_euclid)
  elif h.divide_type == cint(GF_DIVIDE_MATRIX):
    SET_FUNCTION(gf, divide, w32, gf_w4_divide_from_inverse)
    SET_FUNCTION(gf, inverse, w32, gf_w4_matrix)
  if gf.divide.w32 == nil:
    SET_FUNCTION(gf, divide, w32, gf_w4_divide_from_inverse)
    if gf.inverse.w32 == nil: SET_FUNCTION(gf, inverse, w32, gf_w4_euclid)
  if gf.inverse.w32 == nil:
    SET_FUNCTION(gf, inverse, w32, gf_w4_inverse_from_divide)
  if h.region_type == GF_REGION_CAUCHY:
    SET_FUNCTION(gf, multiply_region, w32, gf_wgen_cauchy_region)
    SET_FUNCTION(gf, extract_word, w32, gf_wgen_extract_word)
  if gf.multiply_region.w32 == nil:
    SET_FUNCTION(gf, multiply_region, w32, gf_w4_multiply_region_from_single)
  return 1


proc gf_init_hard*(gf: ptr gf_t; w: cint; mult_type: cint; region_type: var cint;
                  divide_type: var cint; prim_poly: uint64; arg1: var cint; arg2: var cint;
                  base_gf: ptr gf_t; scratch_memory: pointer): cint {.cdecl.} =
  var sz: cint
  var h: ptr gf_internal_t
  #gf_cpu_identify()

  if true: #gf_error_check(w, mult_type, region_type, divide_type, arg1, arg2, prim_poly, base_gf) == 0:
    return 0
  sz = 3 #gf_scratch_size(w, mult_type, region_type, divide_type, arg1, arg2)
  if sz <= 0:
    return 0
  if scratch_memory == nil:
    h = cast[ptr gf_internal_t](sizeof(sz))
    h.free_me = 1
  else:
    h = cast[ptr gf_internal_t](sizeof(sz))
    h.free_me = 0

  gf.scratch = cast[pointer](h)
  h.mult_type = mult_type
  h.region_type = region_type
  h.divide_type = divide_type
  h.w = w
  h.prim_poly = prim_poly
  h.arg1 = arg1
  h.arg2 = arg2
  h.base_gf = base_gf
  h.private = cast[pointer](gf.scratch)
  h.private = cast[ptr uint8](sizeof(h.private)  + int32(sizeof(gf_internal_t)))
  #cast[ptr uint8](sizeof(h.private)) #int32((sizeof((gf_internal_t))))
  gf.extract_word.w32 = nil
  case w
  of 4:
    return gf_w4_init(gf)
  of 8:
    return gf_w8_init(gf)
  of 16:
    return gf_w16_init(gf)
  of 32:
    return gf_w32_init(gf)
  of 64:
    return gf_w64_init(gf)
  of 128:
    return gf_w128_init(gf)
  else:
    return gf_wgen_init(gf)

proc gf_init_easy*(gf: ptr gf_t; w: cint): cint {.cdecl.} =
  return gf_init_hard(gf, w, GF_MULT_DEFAULT, GF_REGION_DEFAULT, GF_DIVIDE_DEFAULT, 0,
                     0, 0, nil, nil)

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

