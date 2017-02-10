# Here we want to track external tempaltes that are needed
# By most of the proc.


# talloc is a hierarchical, reference counted memory pool system with destructors
# many proc or funtions needed. Mostly those printing matixs
template talloc*(`type`, num: untyped): untyped =
  cast[ptr `type`](alloc(sizeof(`type`) * (num)))

var a: ptr int16

var t = @[1.int16, 2.int16, 3.int16]

proc `+`[T](a: ptr T, b: int): ptr T =
    if b >= 0:
        cast[ptr T](cast[uint](a) + cast[uint](b * a[].sizeof))
    else:
        cast[ptr T](cast[uint](a) - cast[uint](-1 * b * a[].sizeof))

template `-`[T](a: ptr T, b: int): ptr T = `+`(a, -b)
