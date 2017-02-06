import gf_typedef

var err_gf_errno*: cint

proc gf_error_check*(w: cint; mult_type: cint; region_type: cint; divide_type: cint;
                    arg1: cint; arg2: cint; poly: uint64; base: ptr gf_t): cint {.cdecl.} =
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


