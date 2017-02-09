template talloc*(`type`, num: untyped): untyped =
  cast[ptr `type`](alloc(sizeof(`type`) * (num)))

var
    r: cint = 12
    c: cint = 100
    w: cint = 12
    i: cint

var matrix: ptr cint

matrix = talloc(int32, r*c)

matrix[1] = 12
