##  Timing measurement utilities.

##  Define USE_CLOCK to use clock(). Otherwise use gettimeofday().

const
  USE_CLOCK* = true

when defined(USE_CLOCK):
else:
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

proc timing_now*(): cdouble {.cdecl, importc: "timing_now", dynlib: libname.}
##  Set *t to the current time.

proc timing_set*(t: ptr timing) {.cdecl, importc: "timing_set", dynlib: libname.}
##  Get *t as a double in seconds.

proc timing_get*(t: ptr timing): cdouble {.cdecl, importc: "timing_get", dynlib: libname.}
##  Return *t2 - *t1 as a double in seconds.

proc timing_delta*(t1: ptr timing; t2: ptr timing): cdouble {.cdecl,
    importc: "timing_delta", dynlib: libname.}