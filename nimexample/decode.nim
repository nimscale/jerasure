import jerasure.src.jerasure
import jerasure.src.galois
import jerasure.src.cauchy
import jerasure.src.liberation
import jerasure.src.reed_sol
import jerasure.src.sharedlib # Not part of the standard binding
import jerasure.src.templates # Not part of the standard binding
import jerasure.src.gf_typedef # Not part of the standard binding
import jerasure.src.timing
import os
import system
import strutils

#proc printf(formatstr: cstring) {.header: "<stdio.h>", importc: "printf", varargs.}
proc strrchr*(str: cstring; c: int): char {.header: "<stdio.h>", importc:"strrchr"}
proc strcpy*(dest: cstring; src: cstring): char {.header: "<string.h>", importc:"strcpy"}
proc strchr*(s: cstring; c: cint): char {.header: "<string.h>", importc:"strchr"}
proc strdup*(s: cstring): char {.header: "<string.h>", importc:"strchr"}

const
  N* = 10

type
  Coding_Technique* = enum
    Reed_Sol_Van, Reed_Sol_R6_Op, Cauchy_Orig, Cauchy_Good, Liberation, Blaum_Roth,
    Liber8tion, RDP, EVENODD, No_Coding


var Methods*: array[N, string] = ["reed_sol_van", "reed_sol_r6_op", "cauchy_orig",
                              "cauchy_good", "liberation", "blaum_roth",
                              "liber8tion", "rdp", "evenodd", "no_coding"]

##  Global variables for signal handler
var `method`*: Coding_Technique

var
  readins*: cint
  n*: cint

##  Function prototype

#proc ctrl_bs_handler*(dummy: cint)


proc main*(argc: cint; argv: cstringArray): cint =
    #var fp: ptr FILE ##  File pointer
    ##  Jerasure arguments

    var data: cstringArray
    var coding: cstringArray
    var erasures: ptr cint
    var erased: ptr cint
    var matrix: ptr cint
    var bitmatrix: ptr cint

    ##  Parameters

    var
      k: cint
      m: cint
      w: cint
      packetsize: cint
      buffersize: cint

    var tech: cint
    var c_tech: cstring

    ##  loop control variable, s
    var
      i: cint
      j: cint

    var blocksize: cint = 0 ##  size of individual files
    var origsize: cint##  size of file before padding
    var total: cint##  used to write data, not padding to file
    #var status:
    #    stat##  used to find size of individual files

    var numerased: cint #  number of erased files

    ##  Used to recreate file names
    var temp: cstring

    var
      cs1: char
      cs2: char
      extension: char

    var fname: cstring
    var md: cint
    var curdir: cstring

    ##  Used to time decoding
    var
      t1: timing
      t2: timing
      t3: timing
      t4: timing

    var tsec: cdouble
    var totalsec: cdouble

    #signal(SIGQUIT, ctrl_bs_handler)

    matrix = nil
    bitmatrix = nil
    totalsec = 0.0

    ##  Start timing
    timing_set(addr(t1))

    ##  Error checking parameters
    if argc != 2:
      write(stderr, "usage: inputfile\x0A")
      quit(0)

    curdir = cast[cstring](alloc(sizeof(char) * 1000))

    #assert(curdir == getcwd(curdir, 1000))

    ##  Begin recreation of file names
    cs1 = cast[char](cast[cstring](alloc(sizeof(char) * (argv[1].len))))
    cs2 = strrchr(argv[1], cast[int]('/'))

    if cast[cstring](cs2) != nil:
      inc(cs2)

      discard strcpy(cast[cstring](cs1), cast[cstring](cs2))

    else:
      discard strcpy(cast[cstring](addr(cs1)), argv[1])

    cs2 = strchr(cast[cstring](cs1), cast[cint]('.'))

    if cast[cstring](cs2) != nil:
      extension = strdup(cast[cstring](cs2))
      cs2[1] = '\0'

    else:
      extension = strdup("")
      
