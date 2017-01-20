##  Timing measurement utilities.

##  Define USE_CLOCK to use clock(). Otherwise use gettimeofday().

## NOTE: Wangolo Joel (wangoloj@outlook.com)
## In the corresponding C library there seemed to be a choice
## to the developers to use the <time.h> and the <sys/time.h>
## That is why they deciced to include #define USE_CLOCK
## And it looks like we here in the nim-lang we have only one choice time
## We may decide to comment off this line of code entirely and just
## import the time module.


## const
##   USE_CLOCK* = true

## when defined(USE_CLOCK):
## else:
## Read the commend about on the NOTE:----------------------

##
## struct timing {
## #ifdef USE_CLOCK
##   clock_t clock;
## #else
##   struct timeval tv;
## #endif
## };
##
##  Get the current time as a double in seconds.
import times

type
    timing* = object

proc timing_now*(): cdouble =
  #{.cdecl, importc: "timing_now", dynlib: libname.}
  ##  Set *t to the current time.
  echo "We are under timing_now"

proc timing_set*(t: ptr timing): ptr =
  #{.cdecl, importc: "timing_set", dynlib: libname.}
  ##  Get *t as a double in seconds.
  echo "We are under timme_set"

proc timing_get*(t: ptr timing): cdouble =
  #{.cdecl, importc: "timing_get", dynlib: libname.}
  ##  Return *t2 - *t1 as a double in seconds.
  echo "We are under timing_get"

proc timing_delta*(t1: ptr timing; t2: ptr timing): cdouble =
  #{.cdecl,importc: "timing_delta", dynlib: libname.}
    echo "We are under timing delta"
