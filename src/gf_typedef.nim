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
