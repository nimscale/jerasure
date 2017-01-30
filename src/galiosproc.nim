import typedefinitions, errors
const
  GF_FIELD_WIDTH* = 4
  GF_DOUBLE_WIDTH* = (GF_FIELD_WIDTH * 2)
  GF_FIELD_SIZE* = (1 shl GF_FIELD_WIDTH)
  GF_MULT_GROUP_SIZE* = (GF_FIELD_SIZE - 1)

const
  GF8_FIELD_WIDTH* = (8)
#  GF_FIELD_SIZE* = (1 shl GF_FIELD_WIDTH)
  GF_HALF_SIZE* = (1 shl (GF8_FIELD_WIDTH div 2))
#  GF_MULT_GROUP_SIZE* = GF_FIELD_SIZE - 1
#  GF_BASE_FIELD_WIDTH* = (4)
#  GF_BASE_FIELD_SIZE* = (1 shl GF_BASE_FIELD_WIDTH)

var gf_cpu_identified* : cint
var gf_cpu_supports_intel_pclmul*: cint
var gf_cpu_supports_intel_sse4* : cint
var gf_cpu_supports_intel_ssse3* : cint
var gf_cpu_supports_intel_sse3* : cint
var gf_cpu_supports_intel_sse2* : cint
var gf_cpu_supports_arm_neon* : cint



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
