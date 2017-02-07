import galois, gf_typedef
import gf_error

var tmp: cint = 12
var w: cint  = 12
var mult_type: cint = 2
var region_type: cint = 3
var divide_type: cint = 4
var arg1: cint = 43
var arg2: cint = 4

#echo galois_init_default_field(tmp)

#echo hostCPU

#(w: cint; mult_type: cint; region_type: cint; divide_type: cint; arg1: cint; arg2: cint; poly: uint64; base: ptr gf_t): cint
#echo gf_error_check(w, mult_type, region_type, divide_type, arg1, arg2, 0, nil)
#echo err_gf_errno

#case tmp
#  of cast[cint](GF_MULT_BYTWO_p), cast[cint](GF_MULT_BYTWO_b):
#    echo "We are  a similar one"
