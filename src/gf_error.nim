import gf_typedef

var err_gf_errno*: cint

proc gf_composite_get_default_poly*(base: ptr gf_t): uint64 =
  var h: ptr gf_internal_t
  var rv: uint64
  h = cast[ptr gf_internal_t](base.scratch)
  if h.w == 4:
    if h.mult_type == cast[cint](GF_MULT_COMPOSITE):
      return 0
    if h.prim_poly == 0x00000013: return 2
    return 0

  if h.w == 8:
    if h.mult_type == cast[cint](GF_MULT_COMPOSITE):
      return 0
    if h.prim_poly == 0x0000011D: return 3
    return 0

  if h.w == 16:
    if h.mult_type == cast[cint](GF_MULT_COMPOSITE):
      rv = gf_composite_get_default_poly(h.base_gf)
      if rv != h.prim_poly: return 0
      if rv == 3: return 0x00000105
      return 0
    else:
      if h.prim_poly == 0x0001100B: return 2
      if h.prim_poly == 0x0001002D: return 7
      return 0

  if h.w == 32:
    if h.mult_type == cast[cint](GF_MULT_COMPOSITE):
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
    if h.mult_type == cast[cint](GF_MULT_COMPOSITE):
      rv = gf_composite_get_default_poly(h.base_gf)
      if rv != h.prim_poly: return 0
      if rv == 3:
        return cast[uint64](0x0000000100000009'i64)
      if rv == 2:
        return cast[uint64](0x0000000100000004'i64)
      if rv == 0x00010005:
        return cast[uint64](0x0000000100000003'i64)
      if rv == 0x00010002:
        return cast[uint64](0x0000000100000005'i64)
      if rv == 0x00010008:
        return cast[uint64](0x0000000100000006'i64)
      return 0
    else:
      if h.prim_poly == 0x0000001B:
        return 2
      return 0
  return 0

proc gf_error_check*(w: cint; mult_type: cint; region_type: cint; divide_type: cint;
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

  rdouble = (region_type and GF_REGION_DOUBLE_TABLE)
  rquad = (region_type and GF_REGION_QUAD_TABLE)
  rlazy = (region_type and GF_REGION_LAZY)
  rsimd = (region_type and GF_REGION_SIMD)
  rnosimd = (region_type and GF_REGION_NOSIMD)
  raltmap = (region_type and GF_REGION_ALTMAP)
  rcauchy = (region_type and GF_REGION_CAUCHY)

  if divide_type != cast[cint](GF_DIVIDE_DEFAULT) and divide_type != cast[cint](GF_DIVIDE_MATRIX) and divide_type != cast[cint](GF_DIVIDE_EUCLID):
    err_gf_errno = cast[cint](GF_E_UNK_DIV)
    return 0

  tmp = (GF_REGION_DOUBLE_TABLE or GF_REGION_QUAD_TABLE or GF_REGION_LAZY or
      GF_REGION_SIMD or GF_REGION_NOSIMD or GF_REGION_ALTMAP or GF_REGION_CAUCHY)

  if cast[bool](region_type)  and (not cast[bool](tmp)):
    err_gf_errno  = cast[cint](GF_E_UNK_REG)
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
    err_gf_errno = cast[cint](GF_E_BAD_W)
    return 0

  if mult_type != cast[cint](GF_MULT_COMPOSITE) and w < 64:
    if (cast[int32](poly) shr (w + 1)) != 0:
      err_gf_errno = cast[cint](GF_E_BADPOLY)
      return 0

  if mult_type == cast[cint](GF_MULT_DEFAULT):
    if divide_type != cast[cint](GF_DIVIDE_DEFAULT):
      err_gf_errno = cast[cint](GF_E_MDEFDIV)
      return 0

    if region_type != GF_REGION_DEFAULT:
      err_gf_errno = cast[cint](GF_E_MDEFREG)
      return 0

    if arg1 != 0 or arg2 != 0:
      err_gf_errno = cast[cint](GF_E_MDEFARG)
      return 0
    return 1

  if cast[bool](rsimd and rnosimd):
    err_gf_errno = cast[cint](GF_E_SIMD_NO)
    return 0

  if cast[bool](rcauchy) and w > 32:
    err_gf_errno = cast[cint](GF_E_CAUGT32)
    return 0

  if cast[bool](rcauchy) and region_type != GF_REGION_CAUCHY:
    err_gf_errno = cast[cint](GF_E_CAUCHYB)
    return 0

  if cast[bool](rcauchy) and mult_type == cast[cint](GF_MULT_COMPOSITE):
    err_gf_errno = cast[cint](GF_E_CAUCOMP)
    return 0

  if arg1 != 0 and mult_type != cast[cint](GF_MULT_COMPOSITE) and mult_type != cast[cint](GF_MULT_SPLIT_TABLE) and mult_type != cast[cint](GF_MULT_GROUP):
    err_gf_errno = cast[cint](GF_E_ARG1SET)
    return 0

  if arg2 != 0 and mult_type != cast[cint](GF_MULT_SPLIT_TABLE) and mult_type != cast[cint](GF_MULT_GROUP):
    err_gf_errno = cast[cint](GF_E_ARG2SET)
    return 0

  if divide_type == cast[cint](GF_DIVIDE_MATRIX) and w > 32:
    err_gf_errno = cast[cint](GF_E_MATRIXW)
    return 0

  if cast[bool](rdouble):
    if cast[bool](rquad):
      err_gf_errno = cast[cint](GF_E_DOUQUAD)
      return 0

    if mult_type != cast[cint](GF_MULT_TABLE):
      err_gf_errno = cast[cint](GF_E_DOUBLET)
      return 0

    if w != 4 and w != 8:
      err_gf_errno = cast[cint](GF_E_DOUBLEW)
      return 0
    if cast[bool](rsimd or rnosimd or raltmap):
      err_gf_errno = cast[cint](GF_E_DOUBLEJ)
      return 0
    if cast[bool](rlazy) and w == 4:
      err_gf_errno = cast[cint](GF_E_DOUBLEL)
      return 0
    return 1

  if cast[bool](rquad):
    if mult_type != cast[cint](GF_MULT_TABLE):
      err_gf_errno= cast[cint](GF_E_QUAD_T)
      return 0

    if w != 4:
      err_gf_errno = cast[cint](GF_E_QUAD_W)
      return 0

    if cast[bool](rsimd or rnosimd or raltmap):
      err_gf_errno = cast[cint](GF_E_QUAD_J)
      return 0
    return 1

  if cast[bool](rlazy):
    err_gf_errno = cast[cint](GF_E_LAZY_X)
    return 0

  if mult_type == cast[cint](GF_MULT_SHIFT):
    if cast[bool](raltmap):
      err_gf_errno = cast[cint](GF_E_ALTSHIF)
      return 0
    if cast[bool](rsimd or rnosimd):
      err_gf_errno = cast[cint](GF_E_SSESHIF)
      return 0
    return 1

  if mult_type == cast[cint](GF_MULT_CARRY_FREE):
    if w != 4 and w != 8 and w != 16 and w != 32 and w != 64 and w != 128:
      err_gf_errno = cast[cint](GF_E_CFM_W)
      return 0
    if w == 4 and cast[bool](poly and 0x0000000C):
      err_gf_errno = cast[cint](GF_E_CFM4POL)
      return 0
    if w == 8 and cast[bool](poly and 0x00000080):
      err_gf_errno = cast[cint](GF_E_CFM8POL)
      return 0
    if w == 16 and cast[bool](poly and 0x0000E000):
      err_gf_errno = cast[cint](GF_E_CF16POL)
      return 0
    if w == 32 and cast[bool](cast[int64](poly) and 0xFE000000):
      err_gf_errno = cast[cint](GF_E_CF32POL)
      return 0
    if w == 64 and cast[bool](cast[int64](poly) and 0xFFFE000000000000'i64):
      err_gf_errno = cast[cint](GF_E_CF64POL)
      return 0
    if cast[bool](raltmap):
      err_gf_errno = cast[cint](GF_E_ALT_CFM)
      return 0
    if cast[bool](rsimd or rnosimd):
      err_gf_errno = cast[cint](GF_E_SSE_CFM)
      return 0
    if cast[bool](not pclmul):
      err_gf_errno = cast[cint](GF_E_PCLMULX)
      return 0
    return 1

  if mult_type == cast[cint](GF_MULT_CARRY_FREE_GK):
    if w != 4 and w != 8 and w != 16 and w != 32 and w != 64 and w != 128:
      err_gf_errno = cast[cint](GF_E_CFM_W)
      return 0

    if cast[bool](raltmap):
      err_gf_errno = cast[cint](GF_E_ALT_CFM)
      return 0

    if cast[bool](rsimd or rnosimd):
      err_gf_errno = cast[cint](GF_E_SSE_CFM)
      return 0

    if cast[bool](not pclmul):
      err_gf_errno = cast[cint](GF_E_PCLMULX)
      return 0
    return 1

  if mult_type == cast[cint](GF_MULT_BYTWO_p) or mult_type == cast[cint](GF_MULT_BYTWO_b):
    if cast[bool](raltmap):
      err_gf_errno = cast[cint](GF_E_ALT_BY2)
      return 0
    if cast[bool](rsimd and not sse2):
      err_gf_errno = cast[cint](GF_E_BY2_SSE)
      return 0
    return 1

  if mult_type == cast[cint](GF_MULT_LOG_TABLE) or mult_type == cast[cint](GF_MULT_LOG_ZERO) or mult_type == cast[cint](GF_MULT_LOG_ZERO_EXT):
    if w > 27:
      err_gf_errno = cast[cint](GF_E_LOGBADW)
      return 0
    if cast[bool](raltmap or rsimd or rnosimd):
      err_gf_errno = cast[cint](GF_E_LOG_J)
      return 0
    if mult_type == cast[cint](GF_MULT_LOG_TABLE):
      return 1
    if w != 8 and w != 16:
      err_gf_errno = cast[cint](GF_E_ZERBADW)
      return 0
    if mult_type == cast[cint](GF_MULT_LOG_ZERO):
      return 1

    if w != 8:
      err_gf_errno = cast[cint](GF_E_ZEXBADW)
      return 0
    return 1

  if mult_type == cast[cint](GF_MULT_GROUP):
    if arg1 <= 0 or arg2 <= 0:
      err_gf_errno = cast[cint](GF_E_GR_ARGX)
      return 0
    if w == 4 or w == 8:
      err_gf_errno = cast[cint](GF_E_GR_W_48)
      return 0
    if w == 16 and (arg1 != 4 or arg2 != 4):
      err_gf_errno = cast[cint](GF_E_GR_W_16)
      return 0
    if w == 128 and (arg1 != 4 or (arg2 != 4 and arg2 != 8 and arg2 != 16)):
      err_gf_errno = cast[cint](GF_E_GR_128A)
      return 0
    if arg1 > 27 or arg2 > 27:
      err_gf_errno = cast[cint](GF_E_GR_A_27)
      return 0
    if arg1 > w or arg2 > w:
      err_gf_errno = cast[cint](GF_E_GR_AR_W)
      return 0
    if cast[bool](raltmap or rsimd or rnosimd):
      err_gf_errno = cast[cint](GF_E_GR_J)
      return 0
    return 1

  if mult_type == cast[cint](GF_MULT_TABLE):
    if w != 16 and w >= 15:
      err_gf_errno = cast[cint](GF_E_TABLE_W)
      return 0
    if w != 4 and cast[bool](rsimd or rnosimd):
      err_gf_errno = cast[cint](GF_E_TAB_SSE)
      return 0
    if cast[bool](rsimd and not sse3):
      err_gf_errno = cast[cint](GF_E_TABSSE3)
      return 0
    if cast[bool](raltmap):
      err_gf_errno = cast[cint](GF_E_TAB_ALT)
      return 0
    return 1

  if mult_type == cast[cint](GF_MULT_SPLIT_TABLE):
    if arg1 > arg2:
      tmp = arg1
      arg1 = arg2
      arg2 = tmp
    if w == 8:
      if arg1 != 4 or arg2 != 8:
        err_gf_errno = cast[cint](GF_E_SP_8_AR)
        return 0
      if cast[bool](rsimd and not sse3):
        err_gf_errno = cast[cint](GF_E_SP_SSE3)
        return 0
      if cast[bool](raltmap):
        err_gf_errno = cast[cint](GF_E_SP_8_A)
        return 0

    elif w == 16:
      if (arg1 == 8 and arg2 == 8) or (arg1 == 8 and arg2 == 16):
        if cast[bool](rsimd or rnosimd):
          err_gf_errno = cast[cint](GF_E_SP_16_S)
          return 0
        if cast[bool](raltmap):
          err_gf_errno = cast[cint](GF_E_SP_16_A)
          return 0

      elif arg1 == 4 and arg2 == 16:
        if cast[bool](rsimd and not sse3):
          err_gf_errno = cast[cint](GF_E_SP_SSE3)
          return 0
      else:
        err_gf_errno = cast[cint](GF_E_SP_16AR)
        return 0

    elif w == 32:
      if (arg1 == 8 and arg2 == 8) or (arg1 == 8 and arg2 == 32) or
          (arg1 == 16 and arg2 == 32):
        if cast[bool](rsimd or rnosimd):
          err_gf_errno = cast[cint](GF_E_SP_32_S)
          return 0
        if cast[bool](raltmap):
          err_gf_errno = cast[cint](GF_E_SP_32_A)
          return 0
      elif arg1 == 4 and arg2 == 32:
        if cast[bool](rsimd and not sse3):
          err_gf_errno = cast[cint](GF_E_SP_SSE3)
          return 0
        if cast[bool](raltmap and not sse3):
          err_gf_errno = cast[cint](GF_E_SP_32AS)
          return 0
        if cast[bool](raltmap and rnosimd):
          err_gf_errno = cast[cint](GF_E_SP_32AS)
          return 0
      else:
        err_gf_errno = cast[cint](GF_E_SP_32AR)
        return 0

    elif w == 64:
      if (arg1 == 8 and arg2 == 8) or (arg1 == 8 and arg2 == 64) or
          (arg1 == 16 and arg2 == 64):
        if cast[bool](rsimd or rnosimd):
          err_gf_errno = cast[cint](GF_E_SP_64_S)
          return 0
        if cast[bool](raltmap):
          err_gf_errno = cast[cint](GF_E_SP_64_A)
          return 0

      elif arg1 == 4 and arg2 == 64:
        if cast[bool](rsimd and not sse3):
          err_gf_errno = cast[cint](GF_E_SP_SSE3)
          return 0
        if cast[bool](raltmap and not sse3):
          err_gf_errno = cast[cint](GF_E_SP_64AS)
          return 0
        if cast[bool](raltmap and rnosimd):
          err_gf_errno = cast[cint](GF_E_SP_64AS)
          return 0
      else:
        err_gf_errno = cast[cint](GF_E_SP_64AR)
        return 0

    elif w == 128:
      if arg1 == 8 and arg2 == 128:
        if cast[bool](rsimd or rnosimd):
          err_gf_errno = cast[cint](GF_E_SP128_S)
          return 0
        if cast[bool](raltmap):
          err_gf_errno = cast[cint](GF_E_SP128_A)
          return 0
      elif arg1 == 4 and arg2 == 128:
        if cast[bool](rsimd and not sse3):
          err_gf_errno = cast[cint](GF_E_SP_SSE3)
          return 0
        if cast[bool](raltmap and not sse3):
          err_gf_errno = cast[cint](GF_E_SP128AS)
          return 0
        if cast[bool](raltmap and rnosimd):
          err_gf_errno = cast[cint](GF_E_SP128AS)
          return 0
      else:
        err_gf_errno = cast[cint](GF_E_SP128AR)
        return 0
    else:
      err_gf_errno = cast[cint](GF_E_SPLIT_W)
      return 0
    return 1

  if mult_type == cast[cint](GF_MULT_GROUP):
    if arg1 <= 0 or arg2 <= 0:
      err_gf_errno = cast[cint](GF_E_GR_ARGX)
      return 0
    if w == 4 or w == 8:
      err_gf_errno = cast[cint](GF_E_GR_W_48)
      return 0
    if w == 16 and (arg1 != 4 or arg2 != 4):
      err_gf_errno = cast[cint](GF_E_GR_W_16)
      return 0
    if w == 128 and (arg1 != 4 or (arg2 != 4 and arg2 != 8 and arg2 != 16)):
      err_gf_errno = cast[cint](GF_E_GR_128A)
      return 0
    if arg1 > 27 or arg2 > 27:
      err_gf_errno = cast[cint](GF_E_GR_A_27)
      return 0
    if arg1 > w or arg2 > w:
      err_gf_errno = cast[cint](GF_E_GR_AR_W)
      return 0
    if cast[bool](raltmap or rsimd or rnosimd):
      err_gf_errno = cast[cint](GF_E_GR_J)
      return 0
    return 1

  if mult_type == cast[cint](GF_MULT_TABLE):
    if w != 16 and w >= 15:
      err_gf_errno = cast[cint](GF_E_TABLE_W)
      return 0
    if w != 4 and cast[bool](rsimd or rnosimd):
      err_gf_errno = cast[cint](GF_E_TAB_SSE)
      return 0
    if cast[bool](rsimd and not sse3):
      err_gf_errno = cast[cint](GF_E_TABSSE3)
      return 0
    if cast[bool](raltmap):
      err_gf_errno = cast[cint](GF_E_TAB_ALT)
      return 0
    return 1

  if mult_type == cast[cint](GF_MULT_SPLIT_TABLE):
    if arg1 > arg2:
      tmp = arg1
      arg1 = arg2
      arg2 = tmp
    if w == 8:
      if arg1 != 4 or arg2 != 8:
        err_gf_errno = cast[cint](GF_E_SP_8_AR)
        return 0
      if cast[bool](rsimd and not sse3):
        err_gf_errno = cast[cint](GF_E_SP_SSE3)
        return 0
      if cast[bool](raltmap):
        err_gf_errno = cast[cint](GF_E_SP_8_A)
        return 0

    elif w == 16:
      if (arg1 == 8 and arg2 == 8) or (arg1 == 8 and arg2 == 16):
        if cast[bool](rsimd or rnosimd):
          err_gf_errno = cast[cint](GF_E_SP_16_S)
          return 0
        if cast[bool](raltmap):
          err_gf_errno = cast[cint](GF_E_SP_16_A)
          return 0
      elif arg1 == 4 and arg2 == 16:
        if cast[bool](rsimd and not sse3):
          err_gf_errno = cast[cint](GF_E_SP_SSE3)
          return 0
      else:
        err_gf_errno = cast[cint](GF_E_SP_16AR)
        return 0
    elif w == 32:
      if (arg1 == 8 and arg2 == 8) or (arg1 == 8 and arg2 == 32) or (arg1 == 16 and arg2 == 32):
        if cast[bool](rsimd or rnosimd):
          err_gf_errno = cast[cint](GF_E_SP_32_S)
          return 0
        if cast[bool](raltmap):
          err_gf_errno = cast[cint](GF_E_SP_32_A)
          return 0

      elif arg1 == 4 and arg2 == 32:
        if cast[bool](rsimd and not sse3):
          err_gf_errno = cast[cint](GF_E_SP_SSE3)
          return 0
        if cast[bool](raltmap and not sse3):
          err_gf_errno = cast[cint](GF_E_SP_32AS)
          return 0
        if cast[bool](raltmap and rnosimd):
          err_gf_errno = cast[cint](GF_E_SP_32AS)
          return 0
      else:
        err_gf_errno = cast[cint](GF_E_SP_32AR)
        return 0

    elif w == 64:
      if (arg1 == 8 and arg2 == 8) or (arg1 == 8 and arg2 == 64) or
          (arg1 == 16 and arg2 == 64):
        if cast[bool](rsimd or rnosimd):
          err_gf_errno = cast[cint](GF_E_SP_64_S)
          return 0
        if cast[bool](raltmap):
          err_gf_errno = cast[cint](GF_E_SP_64_A)
          return 0
      elif arg1 == 4 and arg2 == 64:
        if cast[bool](rsimd and not sse3):
          err_gf_errno = cast[cint](GF_E_SP_SSE3)
          return 0
        if cast[bool](raltmap and not sse3):
          err_gf_errno = cast[cint](GF_E_SP_64AS)
          return 0
        if cast[bool](raltmap and rnosimd):
          err_gf_errno = cast[cint](GF_E_SP_64AS)
          return 0
      else:
        err_gf_errno = cast[cint](GF_E_SP_64AR)
        return 0

    elif w == 128:
      if arg1 == 8 and arg2 == 128:
        if cast[bool](rsimd or rnosimd):
          err_gf_errno = cast[cint](GF_E_SP128_S)
          return 0
        if cast[bool](raltmap):
          err_gf_errno = cast[cint](GF_E_SP128_A)
          return 0
      elif arg1 == 4 and arg2 == 128:
        if cast[bool](rsimd and not sse3):
          err_gf_errno = cast[cint](GF_E_SP_SSE3)
          return 0
        if cast[bool](raltmap and not sse3):
          err_gf_errno = cast[cint](GF_E_SP128AS)
          return 0
        if cast[bool](raltmap and rnosimd):
          err_gf_errno = cast[cint](GF_E_SP128AS)
          return 0
      else:
        err_gf_errno = cast[cint](GF_E_SP128AR)
        return 0
    else:
      err_gf_errno = cast[cint](GF_E_SPLIT_W)
      return 0
    return 1

  if mult_type == cast[cint](GF_MULT_COMPOSITE):
    if w != 8 and w != 16 and w != 32 and w != 64 and w != 128:
      err_gf_errno = cast[cint](GF_E_COMP_W)
      return 0
    if w < 128 and (cast[int32](poly) shr (w div 2)) != 0:
      err_gf_errno = cast[cint](GF_E_COMP_PP)
      return 0
    if divide_type != cast[cint](GF_DIVIDE_DEFAULT):
      err_gf_errno = cast[cint](GF_E_DIVCOMP)
      return 0
    if arg1 != 2:
      err_gf_errno = cast[cint](GF_E_COMP_A2)
      return 0
    if cast[bool](rsimd or rnosimd):
      err_gf_errno = cast[cint](GF_E_COMP_SS)
      return 0
    if base != nil:
      sub = cast[ptr gf_internal_t](base.scratch)
      if sub.w != w div 2:
        err_gf_errno = cast[cint](GF_E_BASE_W)
        return 0
      if poly == 0:
        if gf_composite_get_default_poly(base) == 0:
           err_gf_errno = cast[cint](GF_E_COMPXPP)
        return 0
    return 1
  err_gf_errno = cast[cint](GF_E_UNKNOWN)
  return 0
