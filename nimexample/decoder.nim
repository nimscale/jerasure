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

# Nim does not seem to have pointer arithemetic
# There is a solution on how to implement pointer
# Arithemetic within nim

var a: ptr int16
var t = @[1.int16, 2.int16, 3.int16]

proc `+`[T](a: ptr T, b: int): ptr T =
    if b >= 0:
        cast[ptr T](cast[uint](a) + cast[uint](b * a[].sizeof))
    else:
        cast[ptr T](cast[uint](a) - cast[uint](-1 * b * a[].sizeof))

template `-`[T](a: ptr T, b: int): ptr T = `+`(a, -b)


proc printf(formatstr: cstring) {.header: "<stdio.h>", importc: "printf", varargs.}
proc strrchr*(str: cstring; c: char): cstring {.header: "<stdio.h>", importc:"strrchr"}
proc strcpy*(dest: cstring; src: cstring): char {.header: "<string.h>", importc:"strcpy"}
proc strchr*(s: cstring; c: char): cstring {.header: "<string.h>", importc:"strchr"}
proc strdup*(s: cstring ): cstring {.header: "<string.h>", importc:"strdup"}
proc strlen*(s: cstring): csize {.header: "<string.h>", importc:"strlen"}
proc malloc*(size: csize): pointer {.header: "<stdlib.h>", importc:"malloc"}
proc sprintf*(str: cstring; format: cstring): cint {.header:"<stdio.h>", importc:"sprintf",varargs.}
proc fopen*(path: cstring; mode: cstring): ptr FILE {.header:"<stdio.h>", importc:"fopen"}
proc fprintf*(stream: ptr FILE; format: cstring): cint {.header:"<stdio.h>", importc:"fprintf",varargs.}
proc fscanf*(stream: ptr FILE; format: cstring): cint {.header:"<stdio.h>", importc:"fscanf",varargs.}
proc fclose*(stream: ptr FILE): cint {.header:"<stdio.h>", importc:"fclose"}
proc stat*(pathname: cstring; buf: ptr ): cint {.header:"<sys/stat.h>", importc:"stat"}
proc fread*(`ptr`: pointer; size: csize; nmemb: csize; stream: ptr FILE): csize {.header:"<stdio.h>", importc:"fread"}
proc fseek*(stream: ptr FILE; offset: clong; whence: cint): cint {.header:"<stdio.h>", importc:"fseek"}
proc fwrite*(`ptr`: pointer; size: csize; nmemb: csize; stream: ptr FILE): csize {.header:"<stdio.h>", importc:"fwrite"}
proc free*(`ptr`: pointer) {.header:"<stdlib.h>", importc:"free"}
proc getcwd*(buf: cstring; size: csize): cstring {.header: "<unistd.h>", importc: "getcwd"}
proc get_current_dir_name*(): cstring {.header: "<unistd.h>", importc: "get_current_dir_name"}

const
  SEEK_SET* = 0
  SEEK_CUR* = 1
  SEEK_END* = 2

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
type
  off_t*{.header: "<sys/stat.h>", importc:"off_t".} = object

type
    statt* = object #{.header: "<sys/stat.h>", importc:"stat".} = object
       st_size*: off_t            ##  total size, in bytes

proc main*(argc: cint; argv: cstringArray): cint =
    var fp: ptr FILE ##  File pointer

    ##  Jerasure arguments
    #var data: cstringArray
    #var coding: cstringArray

    var data_nim_array:seq[string]
    data_nim_array = @[]
    var data = allocCStringArray(data_nim_array)

    var coding_nim_array:seq[string]
    coding_nim_array = @[]
    var coding = allocCStringArray(coding_nim_array)

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

    var tmp_sprintf: cint;

    var blocksize: cint = 0 ##  size of individual files
    var origsize: cint##  size of file before padding
    var total: cint##  used to write data, not padding to file
    var status: statt

    #stat* {.header: "<sys/stat.h>", importc:"stat".} = object

    var numerased: cint #  number of erased files

    ##  Used to recreate file names
    var temp: cstring

    #var
    #  cs1: ptr char
    #  cs2: ptr char
    #  extension: ptr char
    #  empty_char: ptr char
    var
      cs1: cstring
      cs2: cstring
      extension: cstring

    var curdir: cstring = get_current_dir_name()

    # Create temprary char pointer holders
    var
       cs1_tmp: char
       cs2_tmp: char
       ext_tmp: char

    # Assign our cs1, cs2 temprary address
    cs1.addr[] = addr(cs1_tmp)
    cs2.addr[] = addr(cs2_tmp)

    var fname: cstring
    var md: cint
    #var curdir: ptr cstring
    var tmp_curdir:cstring

    ##  Used to time decoding
    var
      t1: timing
      t2: timing
      t3: timing
      t4: timing

    var tsec: cdouble
    var totalsec: uint

    #signal(SIGQUIT, ctrl_bs_handler)

    matrix = nil
    bitmatrix = nil
    totalsec = 0

    ##  Start timing
    timing_set(addr(t1))

    ##  Error checking parameters
    if argc != 2:
      write(stderr, "usage: inputfile\n")
      quit(0)

    #curdir = cast[cstring](malloc(sizeof(char) * 1000))
    ##  Begin recreation of file names
    #cs1 = cast[char](cast[cstring](alloc(sizeof(char) * (argv[1].len))))
    cs1 = cast[cstring](malloc(sizeof(char) * strlen(argv[1])))
    #echo "CSI MALLOCED ", cs1
    cs2 = strrchr(argv[1], '/')

    if cs2 != nil:
      # (matrix[].addr + i)[] = n # The failed C was like   matrix[i] = n
      #(cs2[].addr + cs2[].addr)[] = cs2[]
      #(cs2[].addr + cs2[].addr)[] = cs2.addr
      #inc(cs2)

      discard strcpy(cs1, cs2)

    else:
      discard strcpy(cs1, argv[1])

    cs2 = strchr(cs1, '.')

    if cs2 != nil:
      #(matrix[].addr + i)[] = n # The failed C was like   matrix[i] = n
      #(extension[].addr)[] = 'W' #(strdup(cs2)[].addr)[]
      extension = strdup(cs2)
      cs2 = cast[cstring]('\0')

    else:
      extension = strdup("")

    #echo "BEFORE MALLOCK ", fname
    #fname = cast[cstring](malloc(sizeof(cast[cstring]((10000 + strlen(argv[1]) + 400)))))
    fname = cast[cstring] (malloc( sizeof(cstring) * (100 + strlen(argv[1]) + 400)))
    ##  Read in parameters from metadata file

    discard sprintf(fname, "%s/Coding%s_meta.txt", curdir, cs1)

    #echo tmp_sprintf
    fp = fopen(fname, "rb")
    #echo "If we reach here then all if fine"

    if fp == nil:
      write(stderr, "Error: no metadata file ", fname)
      quit(1)

    temp = cast[cstring](malloc(sizeof(char) * (strlen(argv[1]) + 20)))

    if fscanf(fp, "%s", temp) != 1:
      write(stderr, "Metadata file - bad format\n")
      quit(0)

    if fscanf(fp, "%d", addr(origsize)) != 1:
      write(stderr, "Original size is not valid\n")
      quit(0)

    if fscanf(fp, "%d %d %d %d %d", addr(k), addr(m), addr(w), addr(packetsize),
             addr(buffersize)) != 5:
      write(stderr, "Parameters are not correct\n")

    #echo "WE have reached some kind of a peek"

    c_tech = cast[cstring](malloc(sizeof(char) * (strlen(argv[1]) + 20)))
    if fscanf(fp, "%s", c_tech) != 1:
      write(stderr, "Metadata file - bad format\n")
      quit(0)

    if fscanf(fp, "%d", addr(tech)) != 1:
      write(stderr, "Metadata file - bad format\n")
      quit(0)

    #`method` = tech
    `method` = cast[Coding_Technique](tech) # Original failed code `method` = tech

    if fscanf(fp, "%d", addr(readins)) != 1:
      write(stderr, "Metadata file - bad format\n")
      quit(0)

    discard fclose(fp)

    ##  Allocate memory
    erased = cast[ptr cint](malloc(sizeof(int) * (k + m)))
    i = 0
    while i < k + m:
      (erased[].addr + i)[] = 0 # Original converted failed one erased[i] = 0

      inc(i)

    erasures = cast[ptr cint](malloc(sizeof(int) * (k + m)))

    data = cast[cstringArray](malloc(sizeof(cast[cstring](k))))
    coding = cast[cstringArray](malloc(sizeof(cast[cstring](m))))

    if buffersize != origsize:
        i = 0
        while i < k:
          data[i] = cast[cstring](malloc(sizeof(char) * (buffersize div k)))
          inc(i)
        i = 0
        while i < m:
          coding[i] = cast[cstring](malloc(sizeof(char) * (buffersize div k)))
          inc(i)
        blocksize = buffersize div k

    discard sprintf(temp, "%d", k)
    md = cast[int32](strlen(temp))
    timing_set(addr(t3))

    ##  Create coding matrix or bitmatrix
    if cast[Coding_Technique](tech) == No_Coding:
      discard #nil
    elif cast[Coding_Technique](tech) == Reed_Sol_Van:
      matrix = reed_sol_vandermonde_coding_matrix(k, m, w)

    elif cast[Coding_Technique](tech) ==  Reed_Sol_R6_Op:
      matrix = reed_sol_r6_coding_matrix(k, w)
    elif cast[Coding_Technique](tech) ==  Cauchy_Orig:
      matrix = cauchy_original_coding_matrix(k, m, w)
      bitmatrix = jerasure_matrix_to_bitmatrix(k, m, w, matrix)
    elif cast[Coding_Technique](tech) ==  Cauchy_Good:
      matrix = cauchy_good_general_coding_matrix(k, m, w)
      bitmatrix = jerasure_matrix_to_bitmatrix(k, m, w, matrix)
    elif cast[Coding_Technique](tech) ==  Liberation:
      bitmatrix = liberation_coding_bitmatrix(k, w)
    elif cast[Coding_Technique](tech) ==  Blaum_Roth:
      bitmatrix = blaum_roth_coding_bitmatrix(k, w)
    elif cast[Coding_Technique](tech) ==  Liber8tion:
      bitmatrix = liber8tion_coding_bitmatrix(k)

    timing_set(addr(t4))
    inc(totalsec, cast[int](timing_delta(addr(t3), addr(t4))))

    ##  Begin decoding process

    total = 0
    n = 1
    while n <= readins:
      numerased = 0
      ##  Open files, check for erasures, read in data/coding
      i = 1
      while i <= k:
        discard sprintf(fname, "%s/Coding/%s_k%0*d%s", curdir, cs1, md, i, extension)
        fp = fopen(fname, "rb")
        if fp == nil:
          #(erased[].addr + i)[] = 0 # Original converted failed one erased[i] = 0
          (erased[].addr + (i - 1))[] = 1

          #erasures[numerased] = i - 1
          (erasures[].addr + numerased)[] = i - 1
          inc(numerased)

          ## printf("%s failed\n", fname);
        else:
          if buffersize == origsize:
            discard stat(fname, addr(status))
            blocksize = cast[cint](status.st_size)

            data[i - 1] = cast[cstring](malloc(sizeof(char) * blocksize))
            assert(blocksize == fread(data[i - 1], sizeof((char)), blocksize, fp))
          else:
            discard fseek(fp, blocksize * (n - 1), SEEK_SET)
            assert(buffersize div k ==
                fread(data[i - 1], sizeof((char)), buffersize div k, fp))
          discard fclose(fp)

        inc(i)

      i = 1
      while i <= m:
        discard sprintf(fname, "%s/Coding/%s_m%0*d%s", curdir, cs1, md, i, extension)
        fp = fopen(fname, "rb")
        if fp == nil:
          #(erased[].addr + (i - 1))[] = 1
          #erased[k + (i - 1)] = 1
          (erased[].addr + ( k + (i - 1)))[] = 1

          #erasures[numerased] = k + i - 1
          (erasures[].addr + numerased)[] = k + i - 1

          inc(numerased)
          ## printf("%s failed\n", fname);
        else:
          if buffersize == origsize:
            discard stat(fname, addr(status))
            blocksize = cast[cint](status.st_size)
            coding[i - 1] = cast[cstring](malloc(sizeof(char) * blocksize))
            assert(blocksize == fread(coding[i - 1], sizeof((char)), blocksize, fp))
          else:
            discard fseek(fp, blocksize * (n - 1), SEEK_SET)
            assert(blocksize == fread(coding[i - 1], sizeof((char)), blocksize, fp))
          discard fclose(fp)

        inc(i)

      ##  Finish allocating data/coding if needed
      #printf("I is zero\n")
      if n == 1:
        i = 0
        #printf("N is not equal to i\n")
        #printf("I %d\n", i)
        #printf("Numerased %d\n", numerased)

        while i < numerased:
          #(erasures[].addr + numerased)[] = k + i - 1
          if (erasures[].addr + 1)[] < k:
            data[(erasures[].addr + i)[]] = cast[cstring](malloc(sizeof(char) * blocksize))
          else:
              #printf("I is %d\n", i)
              #printf("Address %s\n", repr(erasures[].addr))

              #erasures[].addr[] = 10
              coding[erasures[].addr[]] = cast[cstring](malloc(sizeof(char) * blocksize))

              #coding[(erasures[].addr + i)[] - k] = cast[cstring](malloc(sizeof(char) * blocksize))
              # ORIGINAL coding[erasures[i] - k] = cast[cstring](malloc(sizeof((char) * blocksize)))
              #coding[erasures[i] - k] = "Joel" #cast[cstring](malloc(sizeof((char) * blocksize)))
              #(erasures[].addr + i)[] - k
              #echo coding[erasures[] - k] #= "joel" #= cast[cstring](malloc(sizeof((char) * blocksize)))
              #coding[(erasures[].addr - k)]
              #echo i
              #coding[(erasures[].addr - k)][]=1
              #echo "ME ", erasures[].addr - k
              #coding[(erasures[].addr - k)]
              #echo "M1 ", repr(erasures[].addr)
              #coding[(erasures[].addr + i)[] - k] = cast[cstring](malloc(sizeof(char) * blocksize))
              #coding[erasures[] - k] = cast[cstring](malloc(sizeof(char) * blocksize))


          inc(i)
      #echo coding[]

      #erasures[numerased] = -1
      (erasures[].addr + numerased)[] = -1
      timing_set(addr(t3))

      ##  Choose proper decoding method
      if cast[Coding_Technique](tech) == Reed_Sol_Van or cast[Coding_Technique](tech) == Reed_Sol_R6_Op:
        printf("We have choosen reed_sol_van!\n")
        printf("K %d\n", k)
        printf("M %d\n", m)
        printf("W %d\n", w)
        printf("Matrix %d\n", matrix)
        printf("Erasure %d\n", erasures)
        printf("Data %d\n", data)
        printf("Coding %d\n", coding)
        printf("Block size %d\n", blocksize)

        i = jerasure_matrix_decode(k, m, w, matrix, 1, erasures, data, coding, blocksize)

        printf("RETURN VALUE IS  %d\n", i)

      elif cast[Coding_Technique](tech) == Cauchy_Orig or cast[Coding_Technique](tech) == Cauchy_Good or cast[Coding_Technique](tech) == Liberation or
          cast[Coding_Technique](tech) == Blaum_Roth or cast[Coding_Technique](tech) == Liber8tion:

        i = jerasure_schedule_decode_lazy(k, m, w, bitmatrix, erasures, data, coding,
                                        blocksize, packetsize, 1)
      else:
        write(stderr, "Not a valid coding technique.\n")
        quit(0)

      timing_set(addr(t4))

      ##  Exit if decoding was unsuccessful
      if i == - 1:
        write(stderr, "Unsuccessful!\n")
        quit(0)

      discard sprintf(fname, "%s/Coding/%s_decoded%s", curdir, cs1, extension)
      if n == 1:
        fp = fopen(fname, "wb")
      else:
        fp = fopen(fname, "ab")
      i = 0
      while i < k:
        if total + blocksize <= origsize:
          discard fwrite(data[i], sizeof((char)), blocksize, fp)
          inc(total, blocksize)
        else:
          j = 0
          while j < blocksize:
            if total < origsize:
              discard fprintf(fp, "%c", data[i][j])
              inc(total)
            else:
              break
            inc(j)
        inc(i)
      inc(n)
      discard fclose(fp)
      inc(totalsec, cast[int](timing_delta(addr(t3), addr(t4))))

    ##  Free allocated memory
    free(cs1)
    free(extension)
    free(fname)
    free(data)
    free(coding)
    free(erasures)
    free(erased)

    ##  Stop timing and print time
    timing_set(addr(t2))
    tsec = timing_delta(addr(t1), addr(t2))
    printf("Decoding (MB/sec): %0.10f\n\n", ((cast[int64](origsize)) div cast[int64](1024.0) div cast[int64](1024.0)) div cast[int64](totalsec))

    printf("De_Total (MB/sec): %0.10f\n\n", ((cast[int64](origsize)) div cast[int64](1024.0) div cast[int64](1024.0)) div cast[int64](tsec))

    return 0

when isMainModule:
    var args: seq[TaintedString] #string
    args = commandLineParams()

    if args.len() >= 1:
          var source = allocCStringArray(args)

          ### NOTE: our main function will acess the values from 1
          # But if we try to access like this source[1] it is nill
          # So attempt to place in source[1] the value of source[0]
          if source[1] == nil:
              source[1] = source[0]

          discard main(2, source)
    else:
        echo "usage: inputfile"
        echo "eg  ./decoder  /home/s8software/index.html"
