import gf_galois_constants

var gf_errno*: cint

const
  MAX_GF_INSTANCES* = 64
const
  ENOMEM* = 12
const
    EINVAL* = 22

var gf_cpu_identified* : cint
var gf_cpu_supports_intel_pclmul*: cint
var gf_cpu_supports_intel_sse4* : cint
var gf_cpu_supports_intel_ssse3* : cint
var gf_cpu_supports_intel_sse3* : cint
var gf_cpu_supports_intel_sse2* : cint
var gf_cpu_supports_arm_neon* : cint

type
  gf_val_32_t* = uint32
  gf_val_64_t* = uint64
  gf_val_128_t* = ptr uint64

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

type
  gf_w8_single_table_data* = object
    divtable*: array[GF_FIELD_SIZE, array[GF_FIELD_SIZE, uint8]]
    multtable*: array[GF_FIELD_SIZE, array[GF_FIELD_SIZE, uint8]]

type
  gf_w8_default_data* = object
    high*: array[GF_FIELD_SIZE, array[GF_HALF_SIZE, uint8]]
    low*: array[GF_FIELD_SIZE, array[GF_HALF_SIZE, uint8]]
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

type
  gf_w16_lazytable_data* = object
    log_tbl*: array[GF_FIELD_SIZE, uint16]
    antilog_tbl*: array[GF_FIELD_SIZE * 2, uint16]
    inv_tbl*: array[GF_FIELD_SIZE, uint16]
    d_antilog*: ptr uint16
    lazytable*: array[GF_FIELD_SIZE, uint16]

type
  gf_w16_bytwo_data* = object
    prim_poly*: uint64
    mask1*: uint64
    mask2*: uint64

type
  gf_w16_zero_logtable_data* = object
    log_tbl*: array[GF_FIELD_SIZE, cint]
    a_antilog_tbl*: array[GF_FIELD_SIZE * 4, uint16]
    antilog_tbl*: ptr uint16
    inv_tbl*: array[GF_FIELD_SIZE, uint16]

type
  gf_w16_logtable_data* = object
    log_tbl*: array[GF_FIELD_SIZE, uint16]
    antilog_tbl*: array[GF_FIELD_SIZE * 2, uint16]
    inv_tbl*: array[GF_FIELD_SIZE, uint16]
    d_antilog*: ptr uint16

type
  gf_w16_split_8_8_data* = object
    tables*: array[3, array[256, array[256, uint16]]]

type
  gf_w16_group_4_4_data* = object
    reduce*: array[16, uint16]
    shift*: array[16, uint16]

type
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

type
  gf_w64_group_data* = object
    reduce*: ptr uint64
    shift*: ptr uint64
    memory*: ptr uint64

  gf_split_4_64_lazy_data* = object
    tables*: array[16, array[16, uint64]]
    last_value*: uint64

  gf_split_8_64_lazy_data* = object
    tables*: array[8, array[(1 shl 8), uint64]]
    last_value*: uint64

  gf_split_16_64_lazy_data* = object
    tables*: array[4, array[(1 shl 16), uint64]]
    last_value*: uint64

  gf_split_8_8_data* = object
    tables*: array[15, array[256, array[256, uint64]]]

type
  gf_w128_split_4_128_data* = object
    last_value*: array[2, uint64]
    tables*: array[2, array[32, array[16, uint64]]]

  gf_w128_split_8_128_data* = object
    last_value*: array[2, uint64]
    tables*: array[2, array[16, array[256, uint64]]]

  gf_group_tables_t* = object
    m_table*: gf_val_128_t
    r_table*: gf_val_128_t

type
  gf_wgen_table_w8_data* = object
    mult*: ptr uint8
    `div`*: ptr uint8
    base*: uint8

  gf_wgen_table_w16_data* = object
    mult*: ptr uint16
    `div`*: ptr uint16
    base*: uint16

  gf_wgen_log_w8_data* = object
    log*: ptr uint8
    anti*: ptr uint8
    danti*: ptr uint8
    base*: uint8

  gf_wgen_log_w16_data* = object
    log*: ptr uint16
    anti*: ptr uint16
    danti*: ptr uint16
    base*: uint16

  gf_wgen_log_w32_data* = object
    log*: ptr uint32
    anti*: ptr uint32
    danti*: ptr uint32
    base*: uint32

  gf_wgen_group_data* = object
    reduce*: ptr uint32
    shift*: ptr uint32
    mask*: uint32
    rmask*: uint64
    tshift*: cint
    memory*: uint32

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


type
  gf_region_data* = object
    gf*: ptr gf_t
    src*: pointer
    dest*: pointer
    bytes*: cint
    val*: uint64
    `xor`*: cint
    align*: cint               ##  The number of bytes to which to align.
    s_start*: pointer          ##  The start and the top of the aligned region.
    d_start*: pointer
    s_top*: pointer
    d_top*: pointer


# Template definistions follows
template SET_FUNCTION*(gf, `method`, size, `func`: untyped): void =
  nil

#gf.`method`.size = (`func`)
#(cast[ptr gf_internal_t]((gf).scratch)).`method` = `func`
#template SET_FUNCTION*(gf, `method`, size, `func`: untyped): void =
#  nil

#(gf).`method`.size = (`func`)

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

var mult_type, divide_type, region_type, gf_divide_matrix, gf_divide_euclid: int

type
  gf_division_type_t* {.size: sizeof(cint).} = enum
    GF_DIVIDE_DEFAULT, GF_DIVIDE_MATRIX, GF_DIVIDE_EUCLID

#var GF_DIVIDE_DEFAULT, GF_DIVIDE_MATRIX, GF_DIVIDE_EUCLID: cint

