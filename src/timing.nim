##  Timing measurement utilities implementation.

import
  timing

proc timing_set*(t: ptr timing) =
  when defined(USE_CLOCK):
    t.clock = clock()
  else:
    gettimeofday(addr(t.tv), nil)

proc timing_get*(t: ptr timing): cdouble =
  when defined(USE_CLOCK):
    ##  The clock_t type is an "arithmetic type", which could be
    ##  integral, double, long double, or others.
    ## 
    ##  Add 0.0 to make it a double or long double, then divide (in
    ##  double or long double), then convert to double for our purposes.
    return (double)((t.clock + 0.0) div CLOCKS_PER_SEC)
  else:
    return cast[cdouble](t.tv.tv_sec) +
        (cast[cdouble](t.tv.tv_usec)) div 1000000.0

proc timing_now*(): cdouble =
  when defined(USE_CLOCK):
    return (double)((clock() + 0.0) div CLOCKS_PER_SEC)
  else:
    var tv: timeval
    gettimeofday(addr(tv), nil)
    return cast[cdouble](tv.tv_sec) + (cast[cdouble](tv.tv_usec)) div 1000000.0

proc timing_delta*(t1: ptr timing; t2: ptr timing): cdouble =
  when defined(USE_CLOCK):
    ##  The clock_t type is an "arithmetic type", which could be
    ##  integral, double, long double, or others.
    ## 
    ##  Subtract first, resulting in another clock_t, then add 0.0 to
    ##  make it a double or long double, then divide (in double or long
    ##  double), then convert to double for our purposes.
    return (double)(((t2.clock - t1.clock) + 0.0) div CLOCKS_PER_SEC)
  else:
    var d2: cdouble = cast[cdouble](t2.tv.tv_sec) +
        (cast[cdouble](t2.tv.tv_usec)) div 1000000.0
    var d1: cdouble = cast[cdouble](t1.tv.tv_sec) +
        (cast[cdouble](t1.tv.tv_usec)) div 1000000.0
    return d2 - d1
