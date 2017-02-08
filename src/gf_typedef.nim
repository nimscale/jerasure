##  These are the different ways to perform multiplication.
##    Not all are implemented for all values of w.
##    See the paper for an explanation of how they work.

type
  gf_mult_type_t* {.size: sizeof(cint).} = enum
    GF_MULT_DEFAULT, GF_MULT_SHIFT, GF_MULT_CARRY_FREE, GF_MULT_CARRY_FREE_GK,
    GF_MULT_GROUP, GF_MULT_BYTWO_p, GF_MULT_BYTWO_b, GF_MULT_TABLE,
    GF_MULT_LOG_TABLE, GF_MULT_LOG_ZERO, GF_MULT_LOG_ZERO_EXT, GF_MULT_SPLIT_TABLE,
    GF_MULT_COMPOSITE


##  These are the different ways to optimize region
##    operations.  They are bits because you can compose them.
##    Certain optimizations only apply to certain gf_mult_type_t's.
##    Again, please see documentation for how to use these

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

type
  gf_region_type_t* = uint32

##  These are different ways to implement division.
##    Once again, it's best to use "DEFAULT".  However,
##    there are times when you may want to experiment
##    with the others.

type
  gf_division_type_t* {.size: sizeof(cint).} = enum
    GF_DIVIDE_DEFAULT, GF_DIVIDE_MATRIX, GF_DIVIDE_EUCLID


##  We support w=4,8,16,32,64 and 128 with their own data types and
##    operations for multiplication, division, etc.  We also support
##    a "gen" type so that you can do general gf arithmetic for any
##    value of w from 1 to 32.  You can perform a "region" operation
##    on these if you use "CAUCHY" as the mapping.
##

type
  gf_val_32_t* = uint32
  gf_val_64_t* = uint64
  gf_val_128_t* = ptr uint64

var g_gf_errno*: cint

#proc gf_error*()

type
  GFP* = object
    gf:int
type
  #GFP* = ptr gf

  gf_func_a_b* = object {.union.}
    w32*: proc (gf: GFP; a: gf_val_32_t; b: gf_val_32_t): gf_val_32_t {.cdecl.}
    w64*: proc (gf: GFP; a: gf_val_64_t; b: gf_val_64_t): gf_val_64_t {.cdecl.}
    w128*: proc (gf: GFP; a: gf_val_128_t; b: gf_val_128_t; c: gf_val_128_t) {.cdecl.}

  gf_func_a* = object {.union.}
    w32*: proc (gf: GFP; a: gf_val_32_t): gf_val_32_t {.cdecl.}
    w64*: proc (gf: GFP; a: gf_val_64_t): gf_val_64_t {.cdecl.}
    w128*: proc (gf: GFP; a: gf_val_128_t; b: gf_val_128_t) {.cdecl.}

  gf_region* = object {.union.}
    w32*: proc (gf: GFP; src: pointer; dest: pointer; val: gf_val_32_t; bytes: cint;
              add: cint) {.cdecl.}
    w64*: proc (gf: GFP; src: pointer; dest: pointer; val: gf_val_64_t; bytes: cint;
              add: cint) {.cdecl.}
    w128*: proc (gf: GFP; src: pointer; dest: pointer; val: gf_val_128_t; bytes: cint;
               add: cint) {.cdecl.}

  gf_extract* = object {.union.}
    w32*: proc (gf: GFP; start: pointer; bytes: cint; index: cint): gf_val_32_t {.cdecl.}
    w64*: proc (gf: GFP; start: pointer; bytes: cint; index: cint): gf_val_64_t {.cdecl.}
    w128*: proc (gf: GFP; start: pointer; bytes: cint; index: cint; rv: gf_val_128_t) {.
        cdecl.}

  gf_t* = object
    multiply*: gf_func_a_b
    divide*: gf_func_a_b
    inverse*: gf_func_a
    multiply_region*: gf_region
    extract_word*: gf_extract
    scratch*: pointer

const
  MAX_GF_INSTANCES* = 64

const
  GF_FIELD_WIDTH* = 4
  GF_DOUBLE_WIDTH* = (GF_FIELD_WIDTH * 2)
  GF_FIELD_SIZE* = (1 shl GF_FIELD_WIDTH)
  GF_MULT_GROUP_SIZE* = (GF_FIELD_SIZE - 1)

var gfp_array*: array[MAX_GF_INSTANCES, ptr gf_t]

const
  EPERM* = 1
  ENOENT* = 2
  ESRCH* = 3
  EINTR* = 4
  EIO* = 5
  ENXIO* = 6
  E2BIG* = 7
  ENOEXEC* = 8
  EBADF* = 9
  ECHILD* = 10
  EAGAIN* = 11
  ENOMEM* = 12
  EACCES* = 13
  EFAULT* = 14
  ENOTBLK* = 15
  EBUSY* = 16
  EEXIST* = 17
  EXDEV* = 18
  ENODEV* = 19
  ENOTDIR* = 20
  EISDIR* = 21
  EINVAL* = 22
  ENFILE* = 23
  EMFILE* = 24
  ENOTTY* = 25
  ETXTBSY* = 26
  EFBIG* = 27
  ENOSPC* = 28
  ESPIPE* = 29
  EROFS* = 30
  EMLINK* = 31
  EPIPE* = 32
  EDOM* = 33
  ERANGE* = 34

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



# Got from gf_int.h
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
    private*: pointer          ## #ifdef DEBUG_FUNCTIONS
    multiply*: cstring
    divide*: cstring
    inverse*: cstring
    multiply_region*: cstring
    extract_word*: cstring     ## #endif

type
  gf_bytwo_data* = object
    prim_poly*: uint64
    mask1*: uint64
    mask2*: uint64

type
  gf_single_table_data* = object
    mult*: array[GF_FIELD_SIZE, array[GF_FIELD_SIZE, uint8]]
    `div`*: array[GF_FIELD_SIZE, array[GF_FIELD_SIZE, uint8]]

type
  gf_double_table_data* = object
    `div`*: array[GF_FIELD_SIZE, array[GF_FIELD_SIZE, uint8]]
    mult*: array[GF_FIELD_SIZE, array[GF_FIELD_SIZE * GF_FIELD_SIZE, uint8]]

type
  gf_quad_table_data* = object
    `div`*: array[GF_FIELD_SIZE, array[GF_FIELD_SIZE, uint8]]
    mult*: array[GF_FIELD_SIZE, array[(1 shl 16), uint16]]


type
  gf_quad_table_lazy_data* = object
    `div`*: array[GF_FIELD_SIZE, array[GF_FIELD_SIZE, uint8]]
    smult*: array[GF_FIELD_SIZE, array[GF_FIELD_SIZE, uint8]]
    mult*: array[(1 shl 16), uint16]

type
  gf_logtable_data* = object
    log_tbl*: array[GF_FIELD_SIZE, uint8]
    antilog_tbl*: array[GF_FIELD_SIZE * 2, uint8]
    antilog_tbl_div*: ptr uint8

const
  GF_HALF_SIZE* = (1 shl (GF_FIELD_WIDTH div 2))
  GF_BASE_FIELD_WIDTH* = (4)
  GF_BASE_FIELD_SIZE* = (1 shl GF_BASE_FIELD_WIDTH)


type
  gf_w8_default_data* = object
    high*: array[GF_FIELD_SIZE, array[GF_HALF_SIZE, uint8]]
    low*: array[GF_FIELD_SIZE, array[GF_HALF_SIZE, uint8]]
    divtable*: array[GF_FIELD_SIZE, array[GF_FIELD_SIZE, uint8]]
    multtable*: array[GF_FIELD_SIZE, array[GF_FIELD_SIZE, uint8]]

type
  gf_w8_single_table_data* = object
    divtable*: array[GF_FIELD_SIZE, array[GF_FIELD_SIZE, uint8]]
    multtable*: array[GF_FIELD_SIZE, array[GF_FIELD_SIZE, uint8]]


type
  gf_w8_double_table_data* = object
    `div`*: array[GF_FIELD_SIZE, array[GF_FIELD_SIZE, uint8]]
    mult*: array[GF_FIELD_SIZE, array[GF_FIELD_SIZE * GF_FIELD_SIZE, uint16]]

type
  gf_w8_double_table_lazy_data* = object
    `div`*: array[GF_FIELD_SIZE, array[GF_FIELD_SIZE, uint8]]
    smult*: array[GF_FIELD_SIZE, array[GF_FIELD_SIZE, uint8]]
    mult*: array[GF_FIELD_SIZE * GF_FIELD_SIZE, uint16]

type
  gf_w8_bytwo_data* = object
    prim_poly*: uint64
    mask1*: uint64
    mask2*: uint64

type
  gf_w8_half_table_data* = object
    high*: array[GF_FIELD_SIZE, array[GF_HALF_SIZE, uint8]]
    low*: array[GF_FIELD_SIZE, array[GF_HALF_SIZE, uint8]]

type
  gf_w8_logtable_data* = object
    log_tbl*: array[GF_FIELD_SIZE, uint8]
    antilog_tbl*: array[GF_FIELD_SIZE * 2, uint8]
    inv_tbl*: array[GF_FIELD_SIZE, uint8]

type
  gf_w8_logzero_small_table_data* = object
    log_tbl*: array[GF_FIELD_SIZE, cshort] ##  Make this signed, so that we can divide easily
    antilog_tbl*: array[255 * 3, uint8]
    inv_tbl*: array[GF_FIELD_SIZE, uint8]
    div_tbl*: ptr uint8

type
  gf_w8_logzero_table_data* = object
    log_tbl*: array[GF_FIELD_SIZE, cshort] ##  Make this signed, so that we can divide easily
    antilog_tbl*: array[512 + 512 + 1, uint8]
    div_tbl*: ptr uint8
    inv_tbl*: ptr uint8

type
  gf_w8_composite_data* = object
    mult_table*: ptr uint8


# This type object are for "gf_w16_scratch_size" proc
type
  gf_w16_logtable_data* = object
    log_tbl*: array[GF_FIELD_SIZE, uint16]
    antilog_tbl*: array[GF_FIELD_SIZE * 2, uint16]
    inv_tbl*: array[GF_FIELD_SIZE, uint16]
    d_antilog*: ptr uint16

  gf_w16_zero_logtable_data* = object
    log_tbl*: array[GF_FIELD_SIZE, cint]
    a_antilog_tbl*: array[GF_FIELD_SIZE * 4, uint16]
    antilog_tbl*: ptr uint16
    inv_tbl*: array[GF_FIELD_SIZE, uint16]

  gf_w16_lazytable_data* = object
    log_tbl*: array[GF_FIELD_SIZE, uint16]
    antilog_tbl*: array[GF_FIELD_SIZE * 2, uint16]
    inv_tbl*: array[GF_FIELD_SIZE, uint16]
    d_antilog*: ptr uint16
    lazytable*: array[GF_FIELD_SIZE, uint16]

  gf_w16_bytwo_data* = object
    prim_poly*: uint64
    mask1*: uint64
    mask2*: uint64

  gf_w16_split_8_8_data* = object
    tables*: array[3, array[256, array[256, uint16]]]

  gf_w16_group_4_4_data* = object
    reduce*: array[16, uint16]
    shift*: array[16, uint16]

  gf_w16_composite_data* = object
    mult_table*: ptr uint8

type
  gf_split_2_32_lazy_data* = object
    tables*: array[16, array[4, uint32]]
    last_value*: uint32

  gf_w32_split_8_8_data* = object
    tables*: array[7, array[256, array[256, uint32]]]
    region_tables*: array[4, array[256, uint32]]
    last_value*: uint32

  gf_w32_group_data* = object
    reduce*: ptr uint32
    shift*: ptr uint32
    tshift*: cint
    rmask*: uint64
    memory*: ptr uint32

  gf_split_16_32_lazy_data* = object
    tables*: array[2, array[(1 shl 16), uint32]]
    last_value*: uint32

  gf_split_8_32_lazy_data* = object
    tables*: array[4, array[256, uint32]]
    last_value*: uint32

  gf_split_4_32_lazy_data* = object
    tables*: array[8, array[16, uint32]]
    last_value*: uint32

  gf_w32_bytwo_data* = object
    prim_poly*: uint64
    mask1*: uint64
    mask2*: uint64

  gf_w32_composite_data* = object
    log*: ptr uint16
    alog*: ptr uint16


