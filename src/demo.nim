import jerasure
import galois
import cauchy

var c: cint = 12
var b: cint = 23

##cauchy_n_ones(c, b)

proc yes(n:cint, y:cint): cint =
    echo n
    echo y

echo cauchy_n_ones(b, c);
#echo yes(b, c)
