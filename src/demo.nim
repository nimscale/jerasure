#import jerasure
#import galois
#import cauchy
#import system

var c: cint = 12
var b: cint = 23
var x: culong = 123
var xx: cint = 33


dec(xx, cast[int](x))

##cauchy_n_ones(c, b)

proc yes(n:var cint, y:var cint): cint =
    echo n
    echo y
    if y > n:
       n = y
       y = y + 1;

    echo "We have re-assigned"
    echo n
    echo y

#ptr [c](uint8)
#var N: cast[ptr uint8[uint8]](c)
var N = cast[ptr uint8](c)


type
  gf_val_32_t* = uint32
  gf_val_64_t* = uint64
  gf_val_128_t* = ptr uint64

proc gf_w4_shift_multiply*(bb: var cint; a: gf_val_32_t; b: gf_val_32_t): gf_val_32_t  =
    #cho "Welcome"
    return cast[gf_val_32_t](bb)

var
    a: cint
    bc: cint
    ca: cint
    prod: cint
    ab: cint

const
  GF_FIELD_WIDTH* = 4
  GF_DOUBLE_WIDTH* = (GF_FIELD_WIDTH * 2)
  GF_FIELD_SIZE* = (1 shl GF_FIELD_WIDTH)
  GF_MULT_GROUP_SIZE* = (GF_FIELD_SIZE - 1)


type
  gf_single_table_data* = object
    mult*: array[GF_FIELD_SIZE, array[GF_FIELD_SIZE, uint8]]
    `div`*: array[GF_FIELD_SIZE, array[GF_FIELD_SIZE, uint8]]

#var std: ptr gf_single_table_data
#std = cast[ptr gf_single_table_data](h.private)

#echo gf_single_table_data.mult
#zeroMem(std.mult, sizeof(uint8) * GF_FIELD_SIZE * GF_FIELD_SIZE)
#var new = cast[gf_val_32_t](bc)
#echo new
#echo gf_w4_shift_multiply(c, cast[gf_val_32_t](a), cast[gf_val_32_t](bc))
#var xxy = int(1.0 / 3) # type conversion

#var y = "Foobar"
#proc ffi(foo: ptr array[6, char]) = echo repr(foo)

#ffi(cast[ptr array[6, char]](addr y[0]))

#var s = "12"

#proc fff(str: ptr uint8) = echo repr(str)

#fff(cast[ptr uint8](s))
