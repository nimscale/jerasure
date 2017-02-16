## Timing measurement utilities.

type
  nim_clock_t* = int32  # __clock_t* = __int32_t

type
  clock_t* = nim_clock_t # _  clock_t* = __clock_t

## Define USE_CLOCK to use clock(). Otherwise use gettimeofday().
const
  USE_CLOCK* = true

type
  timing* = object
    clock*: clock_t

{.compile:"../include/timing.c"}
# Get the current time as a double in seconds.
proc timing_now*(): cdouble {.importc.}

##  Set *t to the current time.
proc timing_set*(t: ptr timing) {.importc.}

##  Get *t as a double in seconds.
proc timing_get*(t: ptr timing): cdouble {.importc.}
      ##  The clock_t type is an "arithmetic type", which could be
      ##  integral, double, long double, or others.
      ##
      ##  Add 0.0 to make it a double or long double, then divide (in
      ##  double or long double), then convert to double for our purposes.

##  Return *t2 - *t1 as a double in seconds.
proc timing_delta*(t1: ptr timing; t2: ptr timing): cdouble {.importc.}
      ##  The clock_t type is an "arithmetic type", which could be
      ##  integral, double, long double, or others.
      ##
      ##  Subtract first, resulting in another clock_t, then add 0.0 to
      ##  make it a double or long double, then divide (in double or long
      ##  double), then convert to double for our purposes.

when isMainModule:
    var
      t1*: timing
      t2*: timing
      t3*: timing
      t4*: timing

    echo timing_now()

    timing_set(addr(t1))
    timing_set(addr(t2))

    echo timing_get(addr(t1))
    echo timing_get(addr(t2))

    echo timing_delta(addr(t1), addr(t2))
