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

#echo cauchy_n_ones(b, c);
#echo yes(b, c)
#if c == 4 and (b == 0x0000000C):
#  echo "it works"
#if c == 32 and (int64(b) == 0xFE000000):
#  echo "it works"
#if (c or 4) and (x or xx): #Error: unhandled exception: value out of range: 8 [RangeError]
#  echo "They are just working on it!"

#echo x or xx and  c or 4
