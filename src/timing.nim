## Timing measurement utilities.

## Define USE_CLOCK to use clock(). Otherwise use gettimeofday().
const
  USE_CLOCK* = true

type
   timing_clock* {.importc: "clock_t", header: "<time.h>".} = object   ## #ifdef USE_CLOCK

type
    timeval* {.importc: "clock_t", header: "<sys/time.h>".} = object

type
  timing* = object
     when defined(USE_CLOCK):
        clock*:timing_clock
     else:
         tv*: timeval  ## #endif

# Get the current time as a double in seconds.
proc timing_now*(): cdouble {.importc.} =
    when defined(USE_CLOCK):
      return (double)((clock() + 0.0) div CLOCKS_PER_SEC)
    else:
      var tv* {.importc: "tv", header:"<sys/time.h>".}: timeval
      gettimeofday(addr(tv), nil)
      return cast[cdouble](tv.tv_sec) + (cast[cdouble](tv.tv_usec)) div 1000000.0

##  Set *t to the current time.
proc timing_set*(t: ptr timing) {.importc.} =
    when defined(USE_CLOCK):
      t.clock = clock()
    else:
      gettimeofday(addr(t.tv), nil)

##  Get *t as a double in seconds.
proc timing_get*(t: ptr timing): cdouble {.importc.} =
    when defined(USE_CLOCK):
      ##  The clock_t type is an "arithmetic type", which could be
      ##  integral, double, long double, or others.
      ##
      ##  Add 0.0 to make it a double or long double, then divide (in
      ##  double or long double), then convert to double for our purposes.
      return (double)((t.clock + 0.0) div CLOCKS_PER_SEC)
    else:
      return cast[cdouble](t.tv.tv_sec) + (cast[cdouble](t.tv.tv_usec)) div 1000000.0


##  Return *t2 - *t1 as a double in seconds.
proc timing_delta*(t1: ptr timing; t2: ptr timing): cdouble {.importc.} =
    when defined(USE_CLOCK):
      ##  The clock_t type is an "arithmetic type", which could be
      ##  integral, double, long double, or others.
      ##
      ##  Subtract first, resulting in another clock_t, then add 0.0 to
      ##  make it a double or long double, then divide (in double or long
      ##  double), then convert to double for our purposes.
      return (double)(((t2.clock - t1.clock) + 0.0) div CLOCKS_PER_SEC)
    else:
      var d2* {.importc: "d2", header:"<time.h>".}: cdouble
      var d1* {.importc: "d1", dynlib:"<time.h>".}: cdouble
      return d2 - d1
      
