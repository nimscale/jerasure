# This is a personal module not part of the jerasure porting.
# That being said, it does not make me the author of the following
# code

type
  gf_error_type_t* {.size: sizeof(cint).} = enum
    GF_E_MDEFDIV,             ##  Dev != Default && Mult == Default
    GF_E_MDEFREG,             ##  Reg != Default && Mult == Default
    GF_E_MDEFARG,             ##  Args != Default && Mult == Default
    GF_E_DIVCOMP,             ##  Mult == Composite && Div != Default
    GF_E_CAUCOMP,             ##  Mult == Composite && Reg == CAUCHY
    GF_E_DOUQUAD,             ##  Reg == DOUBLE && Reg == QUAD
    GF_E_SIMD_NO,             ##  Reg == SIMD && Reg == NOSIMD
    GF_E_CAUCHYB,             ##  Reg == CAUCHY && Other Reg
    GF_E_CAUGT32,             ##  Reg == CAUCHY && w > 32
    GF_E_ARG1SET,             ##  Arg1 != 0 && Mult \notin COMPOSITE/SPLIT/GROUP
    GF_E_ARG2SET,             ##  Arg2 != 0 && Mult \notin SPLIT/GROUP
    GF_E_MATRIXW,             ##  Div == MATRIX && w > 32
    GF_E_BAD_W,             ##  Illegal w
    GF_E_DOUBLET,             ##  Reg == DOUBLE && Mult != TABLE
    GF_E_DOUBLEW,             ##  Reg == DOUBLE && w \notin {4,8}
    GF_E_DOUBLEJ,             ##  Reg == DOUBLE && other Reg
    GF_E_DOUBLEL,             ##  Reg == DOUBLE & LAZY but w = 4
    GF_E_QUAD_T,             ##  Reg == QUAD && Mult != TABLE
    GF_E_QUAD_W,             ##  Reg == QUAD && w != 4
    GF_E_QUAD_J,             ##  Reg == QUAD && other Reg
    GF_E_LAZY_X,             ##  Reg == LAZY && not DOUBLE or QUAD
    GF_E_ALTSHIF,             ##  Mult == Shift && Reg == ALTMAP
    GF_E_SSESHIF,             ##  Mult == Shift && Reg == SIMD|NOSIMD
    GF_E_ALT_CFM,             ##  Mult == CARRY_FREE && Reg == ALTMAP
    GF_E_SSE_CFM,             ##  Mult == CARRY_FREE && Reg == SIMD|NOSIMD
    GF_E_PCLMULX,             ##  Mult == Carry_Free && No PCLMUL
    GF_E_ALT_BY2,             ##  Mult == Bytwo_x && Reg == ALTMAP
    GF_E_BY2_SSE,             ##  Mult == Bytwo_x && Reg == SSE && No SSE2
    GF_E_LOGBADW,             ##  Mult == LOGx, w too big
    GF_E_LOG_J,             ##  Mult == LOGx, && Reg == SSE|ALTMAP|NOSSE
    GF_E_ZERBADW,             ##  Mult == LOG_ZERO, w \notin {8,16}
    GF_E_ZEXBADW,             ##  Mult == LOG_ZERO_EXT, w != 8
    GF_E_LOGPOLY,             ##  Mult == LOG & poly not primitive
    GF_E_GR_ARGX,             ##  Mult == GROUP, Bad arg1/2
    GF_E_GR_W_48,             ##  Mult == GROUP, w \in { 4, 8 }
    GF_E_GR_W_16,             ##  Mult == GROUP, w == 16, arg1 != 4 || arg2 != 4
    GF_E_GR_128A,             ##  Mult == GROUP, w == 128, bad args
    GF_E_GR_A_27,             ##  Mult == GROUP, either arg > 27
    GF_E_GR_AR_W,             ##  Mult == GROUP, either arg > w
    GF_E_GR_J,             ##  Mult == GROUP, Reg == SSE|ALTMAP|NOSSE
    GF_E_TABLE_W,             ##  Mult == TABLE, w too big
    GF_E_TAB_SSE,             ##  Mult == TABLE, SIMD|NOSIMD only apply to w == 4
    GF_E_TABSSE3,             ##  Mult == TABLE, Need SSSE3 for SSE
    GF_E_TAB_ALT,             ##  Mult == TABLE, Reg == ALTMAP
    GF_E_SP128AR,             ##  Mult == SPLIT, w=128, Bad arg1/arg2
    GF_E_SP128AL,             ##  Mult == SPLIT, w=128, SSE requires ALTMAP
    GF_E_SP128AS,             ##  Mult == SPLIT, w=128, ALTMAP requires SSE
    GF_E_SP128_A,             ##  Mult == SPLIT, w=128, ALTMAP only with 4/128
    GF_E_SP128_S,             ##  Mult == SPLIT, w=128, SSE only with 4/128
    GF_E_SPLIT_W,             ##  Mult == SPLIT, Bad w (8, 16, 32, 64, 128)
    GF_E_SP_16AR,             ##  Mult == SPLIT, w=16, Bad arg1/arg2
    GF_E_SP_16_A,             ##  Mult == SPLIT, w=16, ALTMAP only with 4/16
    GF_E_SP_16_S,             ##  Mult == SPLIT, w=16, SSE only with 4/16
    GF_E_SP_32AR,             ##  Mult == SPLIT, w=32, Bad arg1/arg2
    GF_E_SP_32AS,             ##  Mult == SPLIT, w=32, ALTMAP requires SSE
    GF_E_SP_32_A,             ##  Mult == SPLIT, w=32, ALTMAP only with 4/32
    GF_E_SP_32_S,             ##  Mult == SPLIT, w=32, SSE only with 4/32
    GF_E_SP_64AR,             ##  Mult == SPLIT, w=64, Bad arg1/arg2
    GF_E_SP_64AS,             ##  Mult == SPLIT, w=64, ALTMAP requires SSE
    GF_E_SP_64_A,             ##  Mult == SPLIT, w=64, ALTMAP only with 4/64
    GF_E_SP_64_S,             ##  Mult == SPLIT, w=64, SSE only with 4/64
    GF_E_SP_8_AR,             ##  Mult == SPLIT, w=8, Bad arg1/arg2
    GF_E_SP_8_A,             ##  Mult == SPLIT, w=8, no ALTMAP
    GF_E_SP_SSE3,             ##  Mult == SPLIT, Need SSSE3 for SSE
    GF_E_COMP_A2,             ##  Mult == COMP, arg1 must be = 2
    GF_E_COMP_SS,             ##  Mult == COMP, SIMD|NOSIMD
    GF_E_COMP_W,             ##  Mult == COMP, Bad w.
    GF_E_UNKFLAG,             ##  Unknown flag in create_from....
    GF_E_UNKNOWN,             ##  Unknown mult_type.
    GF_E_UNK_REG,             ##  Unknown region_type.
    GF_E_UNK_DIV,             ##  Unknown divide_type.
    GF_E_CFM_W,             ##  Mult == CFM,  Bad w.
    GF_E_CFM4POL,             ##  Mult == CFM & Prim Poly has high bits set.
    GF_E_CFM8POL,             ##  Mult == CFM & Prim Poly has high bits set.
    GF_E_CF16POL,             ##  Mult == CFM & Prim Poly has high bits set.
    GF_E_CF32POL,             ##  Mult == CFM & Prim Poly has high bits set.
    GF_E_CF64POL,             ##  Mult == CFM & Prim Poly has high bits set.
    GF_E_FEWARGS,             ##  Too few args in argc/argv.
    GF_E_BADPOLY,             ##  Bad primitive polynomial -- too many bits set.
    GF_E_COMP_PP,             ##  Bad primitive polynomial -- bigger than sub-field.
    GF_E_COMPXPP,             ##  Can't derive a default pp for composite field.
    GF_E_BASE_W,             ##  Composite -- Base field is the wrong size.
    GF_E_TWOMULT,             ##  In create_from... two -m's.
    GF_E_TWO_DIV,             ##  In create_from... two -d's.
    GF_E_POLYSPC,             ##  Bad numbera after -p.
    GF_E_SPLITAR,             ##  Ran out of arguments in SPLIT
    GF_E_SPLITNU,             ##  Arguments not integers in SPLIT.
    GF_E_GROUPAR,             ##  Ran out of arguments in GROUP
    GF_E_GROUPNU,             ##  Arguments not integers in GROUP.
    GF_E_DEFAULT


var e_gf_errno*: cint

proc gf_error_assignment*() {.cdecl.} =

  var s: cstring
  case e_gf_errno
  of ord(GF_E_DEFAULT):
    s = "No Error."
  of ord(GF_E_TWOMULT):
    s = "Cannot specify two -m\'s."
  of ord(GF_E_TWO_DIV):
    s = "Cannot specify two -d\'s."
  of ord(GF_E_POLYSPC):
    s = "-p needs to be followed by a number in hex (0x optional)."
  of ord(GF_E_GROUPAR):
    s = "Ran out of arguments in -m GROUP."
  of ord(GF_E_GROUPNU):
    s = "In -m GROUP g_s g_r -- g_s and g_r need to be numbers."
  of ord(GF_E_SPLITAR):
    s = "Ran out of arguments in -m SPLIT."
  of ord(GF_E_SPLITNU):
    s = "In -m SPLIT w_a w_b -- w_a and w_b need to be numbers."
  of ord(GF_E_FEWARGS):
    s = "Not enough arguments (Perhaps end with \'-\'?)"
  of ord(GF_E_CFM_W):
    s = "-m CARRY_FREE, w must be 4, 8, 16, 32, 64 or 128."
  of ord(GF_E_COMPXPP):
    s = "-m COMPOSITE, No poly specified, and we don\'t have a default for the given sub-field."
  of ord(GF_E_BASE_W):
    s = "-m COMPOSITE and the base field is not for w/2."
  of ord(GF_E_CFM4POL):
    s = "-m CARRY_FREE, w=4. (Prim-poly & 0xc) must equal 0."
  of ord(GF_E_CFM8POL):
    s = "-m CARRY_FREE, w=8. (Prim-poly & 0x80) must equal 0."
  of ord(GF_E_CF16POL):
    s = "-m CARRY_FREE, w=16. (Prim-poly & 0xe000) must equal 0."
  of ord(GF_E_CF32POL):
    s = "-m CARRY_FREE, w=32. (Prim-poly & 0xfe000000) must equal 0."
  of ord(GF_E_CF64POL):
    s = "-m CARRY_FREE, w=64. (Prim-poly & 0xfffe000000000000ULL) must equal 0."
  of ord(GF_E_MDEFDIV):
    s = "If multiplication method == default, can\'t change division."
  of ord(GF_E_MDEFREG):
    s = "If multiplication method == default, can\'t change region."
  of ord(GF_E_MDEFARG):
    s = "If multiplication method == default, can\'t use arg1/arg2."
  of ord(GF_E_DIVCOMP):
    s = "Cannot change the division technique with -m COMPOSITE."
  of ord(GF_E_DOUQUAD):
    s = "Cannot specify -r DOUBLE and -r QUAD."
  of ord(GF_E_SIMD_NO):
    s = "Cannot specify -r SIMD and -r NOSIMD."
  of ord(GF_E_CAUCHYB):
    s = "Cannot specify -r CAUCHY and any other -r."
  of ord(GF_E_CAUCOMP):
    s = "Cannot specify -m COMPOSITE and -r CAUCHY."
  of ord(GF_E_CAUGT32):
    s = "Cannot specify -r CAUCHY with w > 32."
  of ord(GF_E_ARG1SET):
    s = "Only use arg1 with SPLIT, GROUP or COMPOSITE."
  of ord(GF_E_ARG2SET):
    s = "Only use arg2 with SPLIT or GROUP."
  of ord(GF_E_MATRIXW):
    s = "Cannot specify -d MATRIX with w > 32."
  of ord(GF_E_BAD_W):
    s = "W must be 1-32, 64 or 128."
  of ord(GF_E_DOUBLET):
    s = "Can only specify -r DOUBLE with -m TABLE."
  of ord(GF_E_DOUBLEW):
    s = "Can only specify -r DOUBLE w = 4 or w = 8."
  of ord(GF_E_DOUBLEJ):
    s = "Cannot specify -r DOUBLE with -r ALTMAP|SIMD|NOSIMD."
  of ord(GF_E_DOUBLEL):
    s = "Can only specify -r DOUBLE -r LAZY with w = 8"
  of ord(GF_E_QUAD_T):
    s = "Can only specify -r QUAD with -m TABLE."
  of ord(GF_E_QUAD_W):
    s = "Can only specify -r QUAD w = 4."
  of ord(GF_E_QUAD_J):
    s = "Cannot specify -r QUAD with -r ALTMAP|SIMD|NOSIMD."
  of ord(GF_E_BADPOLY):
    s = "Bad primitive polynomial (high bits set)."
  of ord(GF_E_COMP_PP):
    s = "Bad primitive polynomial -- bigger than sub-field."
  of ord(GF_E_LAZY_X):
    s = "If -r LAZY, then -r must be DOUBLE or QUAD."
  of ord(GF_E_ALTSHIF):
    s = "Cannot specify -m SHIFT and -r ALTMAP."
  of ord(GF_E_SSESHIF):
    s = "Cannot specify -m SHIFT and -r SIMD|NOSIMD."
  of ord(GF_E_ALT_CFM):
    s = "Cannot specify -m CARRY_FREE and -r ALTMAP."
  of ord(GF_E_SSE_CFM):
    s = "Cannot specify -m CARRY_FREE and -r SIMD|NOSIMD."
  of ord(GF_E_PCLMULX):
    s = "Specified -m CARRY_FREE, but PCLMUL is not supported."
  of ord(GF_E_ALT_BY2):
    s = "Cannot specify -m BYTWO_x and -r ALTMAP."
  of ord(GF_E_BY2_SSE):
    s = "Specified -m BYTWO_x -r SIMD, but SSE2 is not supported."
  of ord(GF_E_LOGBADW):
    s = "With Log Tables, w must be <= 27."
  of ord(GF_E_LOG_J):
    s = "Cannot use Log tables with -r ALTMAP|SIMD|NOSIMD."
  of ord(GF_E_LOGPOLY):
    s = "Cannot use Log tables because the polynomial is not primitive."
  of ord(GF_E_ZERBADW):
    s = "With -m LOG_ZERO, w must be 8 or 16."
  of ord(GF_E_ZEXBADW):
    s = "With -m LOG_ZERO_EXT, w must be 8."
  of ord(GF_E_GR_ARGX):
    s = "With -m GROUP, arg1 and arg2 must be >= 0."
  of ord(GF_E_GR_W_48):
    s = "With -m GROUP, w cannot be 4 or 8."
  of ord(GF_E_GR_W_16):
    s = "With -m GROUP, w == 16, arg1 and arg2 must be 4."
  of ord(GF_E_GR_128A):
    s = "With -m GROUP, w == 128, arg1 must be 4, and arg2 in { 4,8,16 }."
  of ord(GF_E_GR_A_27):
    s = "With -m GROUP, arg1 and arg2 must be <= 27."
  of ord(GF_E_GR_AR_W):
    s = "With -m GROUP, arg1 and arg2 must be <= w."
  of ord(GF_E_GR_J):
    s = "Cannot use GROUP with -r ALTMAP|SIMD|NOSIMD."
  of ord(GF_E_TABLE_W):
    s = "With -m TABLE, w must be < 15, or == 16."
  of ord(GF_E_TAB_SSE):
    s = "With -m TABLE, SIMD|NOSIMD only applies to w=4."
  of ord(GF_E_TABSSE3):
    s = "With -m TABLE, -r SIMD, you need SSSE3 supported."
  of ord(GF_E_TAB_ALT):
    s = "With -m TABLE, you cannot use ALTMAP."
  of ord(GF_E_SP128AR):
    s = "With -m SPLIT, w=128, bad arg1/arg2."
  of ord(GF_E_SP128AL):
    s = "With -m SPLIT, w=128, -r SIMD requires -r ALTMAP."
  of ord(GF_E_SP128AS):
    s = "With -m SPLIT, w=128, ALTMAP needs SSSE3 supported."
  of ord(GF_E_SP128_A):
    s = "With -m SPLIT, w=128, -r ALTMAP only with arg1/arg2 = 4/128."
  of ord(GF_E_SP128_S):
    s = "With -m SPLIT, w=128, -r SIMD|NOSIMD only with arg1/arg2 = 4/128."
  of ord(GF_E_SPLIT_W):
    s = "With -m SPLIT, w must be in {8, 16, 32, 64, 128}."
  of ord(GF_E_SP_16AR):
    s = "With -m SPLIT, w=16, Bad arg1/arg2."
  of ord(GF_E_SP_16_A):
    s = "With -m SPLIT, w=16, -r ALTMAP only with arg1/arg2 = 4/16."
  of ord(GF_E_SP_16_S):
    s = "With -m SPLIT, w=16, -r SIMD|NOSIMD only with arg1/arg2 = 4/16."
  of ord(GF_E_SP_32AR):
    s = "With -m SPLIT, w=32, Bad arg1/arg2."
  of ord(GF_E_SP_32AS):
    s = "With -m SPLIT, w=32, -r ALTMAP needs SSSE3 supported."
  of ord(GF_E_SP_32_A):
    s = "With -m SPLIT, w=32, -r ALTMAP only with arg1/arg2 = 4/32."
  of ord(GF_E_SP_32_S):
    s = "With -m SPLIT, w=32, -r SIMD|NOSIMD only with arg1/arg2 = 4/32."
  of ord(GF_E_SP_64AR):
    s = "With -m SPLIT, w=64, Bad arg1/arg2."
  of ord(GF_E_SP_64AS):
    s = "With -m SPLIT, w=64, -r ALTMAP needs SSSE3 supported."
  of ord(GF_E_SP_64_A):
    s = "With -m SPLIT, w=64, -r ALTMAP only with arg1/arg2 = 4/64."
  of ord(GF_E_SP_64_S):
    s = "With -m SPLIT, w=64, -r SIMD|NOSIMD only with arg1/arg2 = 4/64."
  of ord(GF_E_SP_8_AR):
    s = "With -m SPLIT, w=8, Bad arg1/arg2."
  of ord(GF_E_SP_8_A):
    s = "With -m SPLIT, w=8, Can\'t have -r ALTMAP."
  of ord(GF_E_SP_SSE3):
    s = "With -m SPLIT, Need SSSE3 support for SIMD."
  of ord(GF_E_COMP_A2):
    s = "With -m COMPOSITE, arg1 must equal 2."
  of ord(GF_E_COMP_SS):
    s = "With -m COMPOSITE, -r SIMD and -r NOSIMD do not apply."
  of ord(GF_E_COMP_W):
    s = "With -m COMPOSITE, w must be 8, 16, 32, 64 or 128."
  of ord(GF_E_UNKFLAG):
    s = "Unknown method flag - should be -m, -d, -r or -p."
  of ord(GF_E_UNKNOWN):
    s = "Unknown multiplication type."
  of ord(GF_E_UNK_REG):
    s = "Unknown region type."
  of ord(GF_E_UNK_DIV):
    s = "Unknown division type."
  else:
    s = "Undefined error."
  write(stderr, "%s\x0A", s)
