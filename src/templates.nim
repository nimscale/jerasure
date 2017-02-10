# Here we want to track external tempaltes that are needed
# By most of the proc.


# talloc is a hierarchical, reference counted memory pool system with destructors
# many proc or funtions needed. Mostly those printing matixs
template talloc*(`type`, num: untyped): untyped =
  cast[ptr `type`](alloc(sizeof(`type`) * (num)))
