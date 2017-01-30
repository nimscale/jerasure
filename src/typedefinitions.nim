## This files contains type definition that are needed
## by some procs and other operations.
## This is manaully got from other header files
#import system

type
  gf_mult_type_t* {.size: sizeof(cint).} = enum
    GF_MULT_DEFAULT, GF_MULT_SHIFT, GF_MULT_CARRY_FREE, GF_MULT_CARRY_FREE_GK,
    GF_MULT_GROUP, GF_MULT_BYTWO_p, GF_MULT_BYTWO_b, GF_MULT_TABLE,
    GF_MULT_LOG_TABLE, GF_MULT_LOG_ZERO, GF_MULT_LOG_ZERO_EXT, GF_MULT_SPLIT_TABLE GF_MULT_COMPOSITE
