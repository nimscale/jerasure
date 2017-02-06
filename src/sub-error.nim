  #rdouble = (region_type and GF_REGION_DOUBLE_TABLE)
  #rquad = (region_type and GF_REGION_QUAD_TABLE)
  #rlazy = (region_type and GF_REGION_LAZY)
  #rsimd = (region_type and GF_REGION_SIMD)
  #rnosimd = (region_type and GF_REGION_NOSIMD)
  #raltmap = (region_type and GF_REGION_ALTMAP)
  #rcauchy = (region_type and GF_REGION_CAUCHY)
  #if divide_type != GF_DIVIDE_DEFAULT and divide_type != GF_DIVIDE_MATRIX and
  #    divide_type != GF_DIVIDE_EUCLID:
  #  err_gf_errno = GF_E_UNK_DIV
   # return 0
  #tmp = (GF_REGION_DOUBLE_TABLE or GF_REGION_QUAD_TABLE or GF_REGION_LAZY or
  #    GF_REGION_SIMD or GF_REGION_NOSIMD or GF_REGION_ALTMAP or GF_REGION_CAUCHY)
  #if region_type and (not tmp):
  #  err_gf_errno = GF_E_UNK_REG
  #  return 0
  #when defined(INTEL_SSE2):
  #  if gf_cpu_supports_intel_sse2:
  #    sse2 = 1
  #when defined(INTEL_SSSE3):
  #  if gf_cpu_supports_intel_ssse3:
  #    sse3 = 1
  #when defined(INTEL_SSE4_PCLMUL):
   # if gf_cpu_supports_intel_pclmul:
  #    pclmul = 1
  #when defined(ARM_NEON):
  #  if gf_cpu_supports_arm_neon:
  #    pclmul = (w == 4 or w == 8)
  #    sse3 = 1
  #if w < 1 or (w > 32 and w != 64 and w != 128):
  #  err_gf_errno= GF_E_BAD_W
  #  return 0
  #if mult_type != GF_MULT_COMPOSITE and w < 64:
  #  if (poly shr (w + 1)) != 0:
  #    err_gf_errno = GF_E_BADPOLY
  #    return 0
  #if mult_type == GF_MULT_DEFAULT:
  #  if divide_type != GF_DIVIDE_DEFAULT:
   #   err_gf_errno = GF_E_MDEFDIV
   #   return 0
   # if region_type != GF_REGION_DEFAULT:
   #   err_gf_errno = GF_E_MDEFREG
   #   return 0
   # if arg1 != 0 or arg2 != 0:
   #   err_gf_errno = GF_E_MDEFARG
   #   return 0
  #  return 1
  #if rsimd and rnosimd:
  #  err_gf_errno = GF_E_SIMD_NO
  #  return 0
  #if rcauchy and w > 32:
  #  err_gf_errno = GF_E_CAUGT32
  #  return 0
  #if rcauchy and region_type != GF_REGION_CAUCHY:
  #  err_gf_errno = GF_E_CAUCHYB
  #  return 0
  #if rcauchy and mult_type == GF_MULT_COMPOSITE:
  #  err_gf_errno = GF_E_CAUCOMP
  #  return 0
  #if arg1 != 0 and mult_type != GF_MULT_COMPOSITE and
  #    mult_type != GF_MULT_SPLIT_TABLE and mult_type != GF_MULT_GROUP:
  #  err_gf_errno = GF_E_ARG1SET
   # return 0
  #if arg2 != 0 and mult_type != GF_MULT_SPLIT_TABLE and mult_type != GF_MULT_GROUP:
  #  err_gf_errno = GF_E_ARG2SET
  #  return 0
  #if divide_type == GF_DIVIDE_MATRIX and w > 32:
  #  err_gf_errno= GF_E_MATRIXW
  #  return 0
  #if rdouble:
  #  if rquad:
  #    err_gf_errno = GF_E_DOUQUAD
  #    return 0
  #  if mult_type != GF_MULT_TABLE:
  #    err_gf_errno = GF_E_DOUBLET
  #    return 0
   # if w != 4 and w != 8:
  #    err_gf_errno = GF_E_DOUBLEW
  #    return 0
  #  if rsimd or rnosimd or raltmap:
  #    err_gf_errno = GF_E_DOUBLEJ
  #    return 0
  # if rlazy and w == 4:
  #    err_gf_errno = GF_E_DOUBLEL
  #    return 0
  #  return 1
  #if rquad:
  #  if mult_type != GF_MULT_TABLE:
  #    err_gf_errno = GF_E_QUAD_T
  #    return 0
  #  if w != 4:
  #    err_gf_errno = GF_E_QUAD_W
  #    return 0
  #  if rsimd or rnosimd or raltmap:
  #    err_gf_errno = GF_E_QUAD_J
   #   return 0
  #  return 1
 # if rlazy:
  #  err_gf_errno = GF_E_LAZY_X
 #   return 0
  #if mult_type == GF_MULT_SHIFT:
 #[
    if raltmap:
      err_gf_errno = GF_E_ALTSHIF
      return 0
    if rsimd or rnosimd:
      err_gf_errno = GF_E_SSESHIF
      return 0
    return 1
  if mult_type == GF_MULT_CARRY_FREE:
    if w != 4 and w != 8 and w != 16 and w != 32 and w != 64 and w != 128:
      err_gf_errno = GF_E_CFM_W
      return 0
    if w == 4 and (poly and 0x0000000C):
      err_gf_errno = GF_E_CFM4POL
      return 0
    if w == 8 and (poly and 0x00000080):
      err_gf_errno = GF_E_CFM8POL
      return 0
    if w == 16 and (poly and 0x0000E000):
      err_gf_errno = GF_E_CF16POL
      return 0
    if w == 32 and (poly and 0xFE000000):
      err_gf_errno = GF_E_CF32POL
      return 0
    if w == 64 and (poly and 0xFFFE000000000000'i64):
      err_gf_errno = GF_E_CF64POL
      return 0
    if raltmap:
      err_gf_errno = GF_E_ALT_CFM
      return 0
    if rsimd or rnosimd:
      err_gf_errno = GF_E_SSE_CFM
      return 0
    if not pclmul:
      err_gf_errno = GF_E_PCLMULX
      return 0
    return 1
  if mult_type == GF_MULT_CARRY_FREE_GK:
    if w != 4 and w != 8 and w != 16 and w != 32 and w != 64 and w != 128:
      err_gf_errno = GF_E_CFM_W
      return 0
    if raltmap:
      err_gf_errno = GF_E_ALT_CFM
      return 0
    if rsimd or rnosimd:
      err_gf_errno = GF_E_SSE_CFM
      return 0
    if not pclmul:
      err_gf_errno = GF_E_PCLMULX
      return 0
    return 1
  if mult_type == GF_MULT_BYTWO_p or mult_type == GF_MULT_BYTWO_b:
    if raltmap:
      err_gf_errno = GF_E_ALT_BY2
      return 0
    if rsimd and not sse2:
      err_gf_errno = GF_E_BY2_SSE
      return 0
    return 1
  if mult_type == GF_MULT_LOG_TABLE or mult_type == GF_MULT_LOG_ZERO or
      mult_type == GF_MULT_LOG_ZERO_EXT:
    if w > 27:
      err_gf_errno = GF_E_LOGBADW
      return 0
    if raltmap or rsimd or rnosimd:
      err_gf_errno = GF_E_LOG_J
      return 0
    if mult_type == GF_MULT_LOG_TABLE: return 1
    if w != 8 and w != 16:
      err_gf_errno = GF_E_ZERBADW
      return 0
    if mult_type == GF_MULT_LOG_ZERO: return 1
    if w != 8:
      err_gf_errno = GF_E_ZEXBADW
      return 0
    return 1
  if mult_type == GF_MULT_GROUP:
    if arg1 <= 0 or arg2 <= 0:
      err_gf_errno = GF_E_GR_ARGX
      return 0
    if w == 4 or w == 8:
      err_gf_errno = GF_E_GR_W_48
      return 0
    if w == 16 and (arg1 != 4 or arg2 != 4):
      err_gf_errno = GF_E_GR_W_16
      return 0
    if w == 128 and (arg1 != 4 or (arg2 != 4 and arg2 != 8 and arg2 != 16)):
      err_gf_errno = GF_E_GR_128A
      return 0
    if arg1 > 27 or arg2 > 27:
      err_gf_errno = GF_E_GR_A_27
      return 0
    if arg1 > w or arg2 > w:
      err_gf_errno = GF_E_GR_AR_W
      return 0
    if raltmap or rsimd or rnosimd:
      err_gf_errno = GF_E_GR_J
      return 0
    return 1
  if mult_type == GF_MULT_TABLE:
    if w != 16 and w >= 15:
      err_gf_errno = GF_E_TABLE_W
      return 0
    if w != 4 and (rsimd or rnosimd):
      err_gf_errno = GF_E_TAB_SSE
      return 0
    if rsimd and not sse3:
      err_gf_errno = GF_E_TABSSE3
      return 0
    if raltmap:
      err_gf_errno= GF_E_TAB_ALT
      return 0
    return 1
  if mult_type == GF_MULT_SPLIT_TABLE:
    if arg1 > arg2:
      tmp = arg1
      arg1 = arg2
      arg2 = tmp
    if w == 8:
      if arg1 != 4 or arg2 != 8:
        err_gf_errno = GF_E_SP_8_AR
        return 0
      if rsimd and not sse3:
        err_gf_errno = GF_E_SP_SSE3
        return 0
      if raltmap:
        err_gf_errno = GF_E_SP_8_A
        return 0
    elif w == 16:
      if (arg1 == 8 and arg2 == 8) or (arg1 == 8 and arg2 == 16):
        if rsimd or rnosimd:
          err_gf_errno = GF_E_SP_16_S
          return 0
        if raltmap:
          err_gf_errno = GF_E_SP_16_A
          return 0
      elif arg1 == 4 and arg2 == 16:
        if rsimd and not sse3:
          err_gf_errno = GF_E_SP_SSE3
          return 0
      else:
        err_gf_errno = GF_E_SP_16AR
        return 0
    elif w == 32:
      if (arg1 == 8 and arg2 == 8) or (arg1 == 8 and arg2 == 32) or
          (arg1 == 16 and arg2 == 32):
        if rsimd or rnosimd:
          err_gf_errno = GF_E_SP_32_S
          return 0
        if raltmap:
          err_gf_errno = GF_E_SP_32_A
          return 0
      elif arg1 == 4 and arg2 == 32:
        if rsimd and not sse3:
          err_gf_errno = GF_E_SP_SSE3
          return 0
        if raltmap and not sse3:
          err_gf_errno = GF_E_SP_32AS
          return 0
        if raltmap and rnosimd:
          err_gf_errno = GF_E_SP_32AS
          return 0
      else:
        err_gf_errno = GF_E_SP_32AR
        return 0
    elif w == 64:
      if (arg1 == 8 and arg2 == 8) or (arg1 == 8 and arg2 == 64) or
          (arg1 == 16 and arg2 == 64):
        if rsimd or rnosimd:
          err_gf_errno = GF_E_SP_64_S
          return 0
        if raltmap:
          err_gf_errno = GF_E_SP_64_A
          return 0
      elif arg1 == 4 and arg2 == 64:
        if rsimd and not sse3:
          err_gf_errno = GF_E_SP_SSE3
          return 0
        if raltmap and not sse3:
          err_gf_errno = GF_E_SP_64AS
          return 0
        if raltmap and rnosimd:
          err_gf_errno = GF_E_SP_64AS
          return 0
      else:
        err_gf_errno= GF_E_SP_64AR
        return 0
    elif w == 128:
      if arg1 == 8 and arg2 == 128:
        if rsimd or rnosimd:
          err_gf_errno = GF_E_SP128_S
          return 0
        if raltmap:
          err_gf_errno = GF_E_SP128_A
          return 0
      elif arg1 == 4 and arg2 == 128:
        if rsimd and not sse3:
          err_gf_errno = GF_E_SP_SSE3
          return 0
        if raltmap and not sse3:
          err_gf_errno = GF_E_SP128AS
          return 0
        if raltmap and rnosimd:
          err_gf_errno = GF_E_SP128AS
          return 0
      else:
        err_gf_errno = GF_E_SP128AR
        return 0
    else:
      err_gf_errno = GF_E_SPLIT_W
      return 0
    return 1
  if mult_type == GF_MULT_COMPOSITE:
    if w != 8 and w != 16 and w != 32 and w != 64 and w != 128:
      err_gf_errno = GF_E_COMP_W
      return 0
    if w < 128 and (poly shr (w div 2)) != 0:
      err_gf_errno = GF_E_COMP_PP
      return 0
    if divide_type != GF_DIVIDE_DEFAULT:
      err_gf_errno = GF_E_DIVCOMP
      return 0
    if arg1 != 2:
      err_gf_errno = GF_E_COMP_A2
      return 0
    if rsimd or rnosimd:
      err_gf_errno = GF_E_COMP_SS
      return 0
    if base != nil:
      sub = cast[ptr gf_internal_t](base.scratch)
      if sub.w != w div 2:
        err_gf_errno = GF_E_BASE_W
        return 0
      if poly == 0:
        if gf_composite_get_default_poly(base) == 0:
          err_gf_errno = GF_E_COMPXPP
          return 0
    return 1
  err_gf_errno = GF_E_UNKNOWN
  return 0
  ]#
