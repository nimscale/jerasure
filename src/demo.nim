#import jerasure
import galois
#import cauchy
#import system

var c: cint = 12
var b: cint = 23
var x: cint = 123
var xx: cint = 33

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

var xxy = int(1.0 / 3) # type conversion

var y = "Foobar"
proc ffi(foo: ptr array[6, char]) = echo repr(foo)

ffi(cast[ptr array[6, char]](addr y[0]))

var s = "12"

proc fff(str: ptr uint8) = echo repr(str)

fff(cast[ptr uint8](s))
