import jerasure.src.jerasure
import jerasure.src.galois
import jerasure.src.cauchy
import jerasure.src.liberation
import jerasure.src.reed_sol
import jerasure.src.sharedlib # Not part of the standard binding
import jerasure.src.templates # Not part of the standard binding
import jerasure.src.gf_typedef # Not part of the standard binding
import jerasure.src.timing

template talloc*(`type`, num: untyped): untyped =
  cast[ptr `type`](alloc(sizeof(`type`) * (num)))


# Nim does not seem to have pointer arithemetic
# There is a solution on how to implement pointer
# Arithemetic within nim

var a: ptr int16
var t = @[1.int16, 2.int16, 3.int16]

proc `+`[T](a: ptr T, b: int): ptr T =
    if b >= 0:
        cast[ptr T](cast[uint](a) + cast[uint](b * a[].sizeof))
    else:
        cast[ptr T](cast[uint](a) - cast[uint](-1 * b * a[].sizeof))

template `-`[T](a: ptr T, b: int): ptr T = `+`(a, -b)

proc main(x: varargs[int]) =
  var
    r: cint = 2
    c: cint = 4
    w: cint = 12
    i: cint
    n: cint

  var matrix: ptr cint

  matrix = talloc(int32, r*c)

  n = 1
  i = 0

  while i < r * c:
    (matrix[].addr + i)[] = n # The failed C was like   matrix[i] = n

    n = galois_single_multiply(n, 2, w)
    inc(i)

  jerasure_print_bitmatrix(matrix, r, c, w);

main()
