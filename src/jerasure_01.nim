import jerasure, galois

template talloc*(`type`, num: untyped): untyped =
  cast[ptr `type`](alloc(sizeof(`type`) * (num)))

proc main(x: varargs[int]) =
  var
    r: cint = 12
    c: cint = 100
    w: cint = 12
    i: cint
    n: cint

  var matrix: ptr cint

  matrix = talloc(int32, r*c)

  n = 1
  i = 0

  while i < r * c:
    matrix[i] = n
    n = galois_single_multiply(n, 2, w)
    inc(i)

  jerasure_print_matrix(matrix, r, c, w);

main()
