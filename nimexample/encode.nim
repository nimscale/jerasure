##  *
##  Copyright (c) 2014, James S. Plank and Kevin Greenan
##  All rights reserved.
##
##  Jerasure - A C/C++ Library for a Variety of Reed-Solomon and RAID-6 Erasure
##  Coding Techniques
##
##  Revision 2.0: Galois Field backend now links to GF-Complete
##
##  Redistribution and use in source and binary forms, with or without
##  modification, are permitted provided that the following conditions
##  are met:
##
##   - Redistributions of source code must retain the above copyright
##     notice, this list of conditions and the following disclaimer.
##
##   - Redistributions in binary form must reproduce the above copyright
##     notice, this list of conditions and the following disclaimer in
##     the documentation and/or other materials provided with the
##     distribution.
##
##   - Neither the name of the University of Tennessee nor the names of its
##     contributors may be used to endorse or promote products derived
##     from this software without specific prior written permission.
##
##  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
##  "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
##  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
##  A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
##  HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
##  INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
##  BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS
##  OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED
##  AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
##  LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY
##  WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
##  POSSIBILITY OF SUCH DAMAGE.
##
##  Jerasure's authors:
##    Revision 2.x - 2014: James S. Plank and Kevin M. Greenan.
##    Revision 1.2 - 2008: James S. Plank, Scott Simmerman and Catherine D. Schuman.
##    Revision 1.0 - 2007: James S. Plank.
##
##
## This program takes as input an inputfile, k, m, a coding
## technique, w, and packetsize.  It creates k+m files from
## the original file so that k of these files are parts of
## the original file and m of the files are encoded based on
## the given coding technique. The format of the created files
## is the file name with "_k#" or "_m#" and then the extension.
## (For example, inputfile test.txt would yield file "test_k1.txt".)
##

import jerasure.src.jerasure
import jerasure.src.galois
import jerasure.src.cauchy
import jerasure.src.liberation
import jerasure.src.reed_sol
import jerasure.src.sharedlib # Not part of the standard binding
import jerasure.src.templates # Not part of the standard binding
import jerasure.src.gf_typedef # Not part of the standard binding
import jerasure.src.timing
import jerasure.src.gf_rand
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
proc strrchr*(str: cstring; c: int): char {.header: "<stdio.h>", importc:"strrchr"}
proc strcpy*(dest: cstring; src: cstring): char {.header: "<string.h>", importc:"strcpy"}
proc strchr*(s: cstring; c: cint): char {.header: "<string.h>", importc:"strchr"}
proc strdup*(s: ptr char): ptr char {.header: "<string.h>", importc:"strdup"}
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
proc sscanf*(str: cstring; format: cstring): cint {.header:"<stdio.h>", importc:"sscanf",varargs.}
proc strcmp*(s1: cstring; s2: cstring): cint {.header:"<string.h>", importc:"strcmp"}
proc getcwd*(buf: cstring; size: csize): cstring {.header:"<unistd.h>", importc:"getcwd"}
proc mkdir*(path: cstring): cint {.header:"<sys/stat.h>", importc:"mkdir"}
proc perror*(s: cstring) {.header:"<stdio.h>", importc:"perror"}

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

# TRicky methd of handling "struct stat status"
type
  off_t*{.header: "<sys/stat.h>", importc:"off_t".} = object

type
    statt* = object #{.header: "<sys/stat.h>", importc:"stat".} = object
       st_size*: off_t            ##  total size, in bytes


##  Global variables for signal handler
var
  readins*: cint
  n*: cint

var `method`*: Coding_Technique

##  is_prime returns 1 if number if prime, 0 if not prime
proc is_prime*(w: cint): cint =
  var prime55: array[0..54, int] = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67, 71,
                      73, 79, 83, 89, 97, 101, 103, 107, 109, 113, 127, 131, 137, 139, 149,
                      151, 157, 163, 167, 173, 179, 181, 191, 193, 197, 199, 211, 223, 227,
                      229, 233, 239, 241, 251, 257]
  var i: cint
  i = 0
  while i < 55:
    if w mod prime55[i] == 0:
      if w == prime55[i]:
        return 1
      else:
        return 0
    inc(i)
  assert(false)

proc jfread*(`ptr`: pointer; size: cint; nmembers: cint; stream: ptr FILE): csize =
  if stream != nil:
      return fread(`ptr`, cast[cint](size), cast[cint](nmembers), stream)

  MOA_Fill_Random_Region(`ptr`, size)
  return size


proc main*(argc: cint; argv: cstringArray): cint =
      ##  file pointers
      var
        fp: ptr FILE
        fp2: ptr FILE

      ##  padding file
      var `block`: pointer
      var block_tmp_handler: cstring # Shall use to tmprary save the return value and then assign to block

      ##  size of file and temp size
      var
        size: cint
        newsize: cint

      # Finding file size
      var status: statt

      ##  coding technique (parameter)
      var tech: Coding_Technique

      ##  parameters
      var
        k: cint
        m: cint
        w: cint
        packetsize: cint

      var buffersize: cint

      var i: cint  ##  loop control variables
      var blocksize: cint  ##  size of k+m files
      var total: cint
      var extra: cint

      ##  Jerasure Arguments
      var data: cstringArray
      var coding: cstringArray
      var matrix: ptr cint
      var bitmatrix: ptr cint
      var schedule: ptr ptr cint

      ##  Creation of file name variables
      var temp: array[5, char]

      var
        s1: ptr char
        s2: ptr  char
        empty_char: ptr char
        extension: cstring

      var fname: cstring
      var md: cint
      var curdir: cstring

      ##  Timing variables
      var
        t1: timing
        t2: timing
        t3: timing
        t4: timing

      var tsec: cdouble
      var totalsec: uint
      var start: timing

      ##  Find buffersize

      var
        up: cint
        down: cint

      # This is not implement in decode.nim
      ## signal(SIGQUIT, ctrl_bs_handler)

      ##  Start timing
      timing_set(addr(t1))
      totalsec = 0
      matrix = nil
      bitmatrix = nil
      schedule = nil

      ##  Error check Arguments
      if argc != 8:
          write(stderr,
                  "usage: inputfile k m coding_technique w packetsize buffersize\x0A")
          write(stderr, "\x0AChoose one of the following coding techniques: \x0Areed_sol_van, \x0Areed_sol_r6_op, \x0Acauchy_orig, \x0Acauchy_good, \x0Aliberation, \x0Ablaum_roth, \x0Aliber8tion")
          write(stderr, "\x0A\x0APacketsize is ignored for the reed_sol\'s")
          write(stderr, "\x0ABuffersize of 0 means the buffersize is chosen automatically.\x0A")
          write(stderr, "\x0AIf you just want to test speed, use an inputfile of \"-number\" where number is the size of the fake file you want to test.\x0A\x0A")
          quit(0)

      ##  Conversion of parameters and error checking
      if sscanf(argv[2], "%d", addr(k)) == 0 or k <= 0:
        write(stderr, "Invalid value for k\x0A")
        quit(0)

      if sscanf(argv[3], "%d", addr(m)) == 0 or m < 0:
        write(stderr, "Invalid value for m\x0A")
        quit(0)

      ##  Determine proper buffersize by finding the closest valid buffersize to the input value
      if buffersize != 0:
        if packetsize != 0 and
            buffersize mod (sizeof(clong) * w * k * packetsize) != 0:
          up = buffersize
          down = buffersize

          while up mod (sizeof(clong) * w * k * packetsize) != 0 and
              (down mod (sizeof(clong) * w * k * packetsize) != 0):
            inc(up)
            if down == 0:
              dec(down)
          if up mod (sizeof(clong) * w * k * packetsize) == 0:
            buffersize = up
          else:
            if down != 0:
              buffersize = down

        elif packetsize == 0 and buffersize mod (sizeof(clong) * w * k) != 0:
          up = buffersize
          down = buffersize
          while up mod (sizeof(clong) * w * k) != 0 and
              down mod (sizeof(clong) * w * k) != 0:
            inc(up)
            dec(down)
          if up mod (sizeof(clong) * w * k) == 0:
            buffersize = up
          else:
            buffersize = down

      ##  Setting of coding technique and error checking
      if strcmp(argv[4], "no_coding") == 0:
        tech = No_Coding

      elif strcmp(argv[4], "reed_sol_van") == 0:
        tech = Reed_Sol_Van
        if w != 8 and w != 16 and w != 32:
            write(stderr, "w must be one of {8, 16, 32}\x0A")
            quit(0)

      elif strcmp(argv[4], "reed_sol_r6_op") == 0:
        if m != 2:
          write(stderr, "m must be equal to 2\x0A")
          quit(0)

        if w != 8 and w != 16 and w != 32:
          write(stderr, "w must be one of {8, 16, 32}\x0A")
          quit(0)
        tech = Reed_Sol_R6_Op

      elif strcmp(argv[4], "cauchy_orig") == 0:
        tech = Cauchy_Orig
        if packetsize == 0:
          write(stderr, "Must include packetsize.\x0A")
          quit(0)

      elif strcmp(argv[4], "liberation") == 0:
        if k > w:
          write(stderr, "k must be less than or equal to w\x0A")
          quit(0)

        if w <= 2 or not cast[bool](w mod 2) or not cast[bool](is_prime(w)):
          write(stderr, "w must be greater than two and w must be prime\x0A")
          quit(0)

        if packetsize == 0:
          write(stderr, "Must include packetsize.\x0A")
          quit(0)

        if (packetsize mod (sizeof(clong))) != 0:
          write(stderr, "packetsize must be a multiple of sizeof(long)\x0A")
          quit(0)
        tech = Liberation

      elif strcmp(argv[4], "blaum_roth") == 0:
          if k > w:
            write(stderr, "k must be less than or equal to w\x0A")
            quit(0)

          if w <= 2 or not cast[bool]((w + 1) mod 2) or not cast[bool](is_prime(w + 1)):
            write(stderr, "w must be greater than two and w+1 must be prime\x0A")
            quit(0)

          if packetsize == 0:
            write(stderr, "Must include packetsize.\x0A")
            quit(0)

          if (packetsize mod (sizeof((clong)))) != 0:
            write(stderr, "packetsize must be a multiple of sizeof(long)\x0A")
            quit(0)
          tech = Blaum_Roth

      elif strcmp(argv[4], "liber8tion") == 0:
          if packetsize == 0:
            write(stderr, "Must include packetsize\x0A")
            quit(0)

          if w != 8:
            write(stderr, "w must equal 8\x0A")
            quit(0)

          if m != 2:
            write(stderr, "m must equal 2\x0A")
            quit(0)

          if k > w:
            write(stderr, "k must be less than or equal to w\x0A")
            quit(0)
          tech = Liber8tion

      else:
          write(stderr, "Not a valid coding technique. Choose one of the following: reed_sol_van, reed_sol_r6_op, cauchy_orig, cauchy_good, liberation, blaum_roth, liber8tion, no_coding\x0A")
          quit(0)

      ##  Set global variable method for signal handler
      `method` = tech

      ##  Get current working directory for construction of file names
      curdir = cast[cstring](malloc(sizeof(char) * 1000))
      assert(curdir == getcwd(curdir, 1000))

      if argv[1][0] != '-':
          ##  Open file and error check
          fp = fopen(argv[1], "rb")
          if fp == nil:
            write(stderr, "Unable to open file.\x0A")
            quit(0)

          if(dirExists("Coding")):
              write(stderr, "Unable to create Coding directory.It already exists")
              quit(0)

          createDir("Coding")
          #if i == - 1 and errno != EEXIST:
          #  quit(0)
          discard stat(argv[1], addr(status))
          size = cast[int32](status.st_size)

      else:
          if sscanf((argv[1].addr + 1)[], "%d", addr(size)) != 1 or size <= 0:
            write(stderr, "Files starting with \'-\' should be sizes for randomly created input\x0A")
            quit(1)
          fp = nil
          #MOA_Seed(time(0))

      newsize = size

      ##  Find new size by determining next closest multiple
      if packetsize != 0:
        if size mod (k * w * packetsize * sizeof(clong)) != 0:
          while newsize mod (k * w * packetsize * sizeof(clong)) != 0:
              inc(newsize)
      else:
        if size mod (k * w * sizeof(clong)) != 0:
          while newsize mod (k * w * sizeof(clong)) != 0:
              inc(newsize)
      if buffersize != 0:
        while newsize mod buffersize != 0:
          inc(newsize)

      ##  Determine size of k+m files
      blocksize = newsize div k

      ##  Allow for buffersize and determine number of read-ins
      if size > buffersize and buffersize != 0:
        if newsize mod buffersize != 0:
           readins = newsize div buffersize
        else:
           readins = newsize div buffersize

        # Temporary save the return value and then
        # pass the pointer to our block variable
        block_tmp_handler = cast[cstring](malloc(sizeof(char) * buffersize))
        `block` = addr(block_tmp_handler)

        blocksize = buffersize div k

      else:
        readins = 1
        buffersize = size

        # Temporary save the turn value and then
        # pass the pointer to our block variable.
        block_tmp_handler = cast[cstring](malloc(sizeof(char) * newsize))
        `block` = addr(block_tmp_handler)

      ##  Break inputfile name into the filename and extension
      s1[] = cast[char](cast[cstring](malloc(sizeof(char) * (strlen(argv[1]) + 20))))
      s2[] = cast[char](strrchr(argv[1], cast[int]('/')))

      if s2[].addr != nil:
        inc(s2[])
        discard strcpy(s1, s2)
      else:
        discard strcpy(s1, argv[1])
      s2[] = strchr(cast[cstring](s1[]), cast[cint]('.'))

      if s2 != nil:
        extension = strdup(s2)
        s2[] = '\0'
      else:
        extension = strdup(empty_char)

      ##  Allocate for full file name
      fname = cast[cstring](malloc(sizeof(char) * (strlen(argv[1]) + strlen(curdir) + 20)))

      discard sprintf(temp, "%d", k)
      md = cast[int32](strlen(temp))
      ##  Allocate data and coding

      data = cast[cstringArray](malloc(sizeof(cast[cstring](k))))
      coding = cast[cstringArray](malloc(sizeof(cast[cstring](m))))

      i = 0
      while i < m:
        coding[i] = cast[cstring](malloc(sizeof(char) * blocksize))
        if coding[i] == nil:
          perror("malloc")
          quit(1)
        inc(i)

      ##  Create coding matrix or bitmatrix and schedule
      timing_set(addr(t3))
      case tech

      of No_Coding:
        nil
      of Reed_Sol_Van:
        matrix = reed_sol_vandermonde_coding_matrix(k, m, w)
      of Reed_Sol_R6_Op:
        nil
      of Cauchy_Orig:
        matrix = cauchy_original_coding_matrix(k, m, w)
        bitmatrix = jerasure_matrix_to_bitmatrix(k, m, w, matrix)
        schedule = jerasure_smart_bitmatrix_to_schedule(k, m, w, bitmatrix)
      of Cauchy_Good:
        matrix = cauchy_good_general_coding_matrix(k, m, w)
        bitmatrix = jerasure_matrix_to_bitmatrix(k, m, w, matrix)
        schedule = jerasure_smart_bitmatrix_to_schedule(k, m, w, bitmatrix)
      of Liberation:
        bitmatrix = liberation_coding_bitmatrix(k, w)
        schedule = jerasure_smart_bitmatrix_to_schedule(k, m, w, bitmatrix)
      of Blaum_Roth:
        bitmatrix = blaum_roth_coding_bitmatrix(k, w)
        schedule = jerasure_smart_bitmatrix_to_schedule(k, m, w, bitmatrix)
      of Liber8tion:
        bitmatrix = liber8tion_coding_bitmatrix(k)
        schedule = jerasure_smart_bitmatrix_to_schedule(k, m, w, bitmatrix)
      of RDP, EVENODD:
        assert(false)

      timing_set(addr(start))
      timing_set(addr(t4))
      inc(totalsec, cast[int](timing_delta(addr(t3), addr(t4))))

      ##  Read in data until finished
      n = 1
      total = 0

      while n <= readins:
          ##  Check if padding is needed, if so, add appropriate
          ## 		   number of zeros
          if total < size and total + buffersize <= size:
            inc(total, jfread(`block`, cast[cint](sizeof(char)), buffersize, fp))

          elif total < size and total + buffersize > size:
            extra = cast[cint](jfread(`block`, cast[cint](sizeof(char)), buffersize, fp))
            i = extra
            while i < buffersize:
              var tmp_char: char = '0'
              (`block`.addr + 1)[] = addr(tmp_char)
              inc(i)

          elif total == size:            ##  Set pointers to point to file data
            i = 0
            while i < buffersize:
              var tmp_char: char = '0'
              (`block`.addr + i)[] = addr(tmp_char)
              inc(i)

          i = 0
          while i < k:
            data[i] = cast[cstring]((`block`.addr  + (i * blocksize))[])
            inc(i)

          timing_set(addr(t3))
          ##  Encode according to coding method
          case tech
          of No_Coding:
            nil
          of Reed_Sol_Van:
            jerasure_matrix_encode(k, m, w, matrix, data, coding, blocksize)
          of Reed_Sol_R6_Op:
            discard reed_sol_r6_encode(k, w, data, coding, blocksize)
          of Cauchy_Orig:
            jerasure_schedule_encode(k, m, w, schedule, data, coding, blocksize, packetsize)
          of Cauchy_Good:
            jerasure_schedule_encode(k, m, w, schedule, data, coding, blocksize, packetsize)
          of Liberation:
            jerasure_schedule_encode(k, m, w, schedule, data, coding, blocksize, packetsize)
          of Blaum_Roth:
            jerasure_schedule_encode(k, m, w, schedule, data, coding, blocksize, packetsize)
          of Liber8tion:
            jerasure_schedule_encode(k, m, w, schedule, data, coding, blocksize, packetsize)
          of RDP, EVENODD:
            assert(false)
          timing_set(addr(t4))
          ##  Write data and encoded data to k+m files
          i = 1
          while i <= k:
            if fp == nil:
              zeroMem(data[i - 1], blocksize)

            else:
              discard sprintf(fname, "%s/Coding/%s_k%0*d%s", curdir, s1, md, i, extension)
              if n == 1:
                fp2 = fopen(fname, "wb")
              else:
                fp2 = fopen(fname, "ab")
              discard fwrite(data[i - 1], sizeof((char)), blocksize, fp2)
              discard fclose(fp2)
            inc(i)
          i = 1

          while i <= m:
            if fp == nil:
              zeroMem(data[i - 1], blocksize)
            else:
              discard sprintf(fname, "%s/Coding/%s_m%0*d%s", curdir, s1, md, i, extension)
              if n == 1:
                fp2 = fopen(fname, "wb")
              else:
                fp2 = fopen(fname, "ab")
              discard fwrite(coding[i - 1], sizeof((char)), blocksize, fp2)
              discard fclose(fp2)
            inc(i)
          inc(n)

          ##  Calculate encoding time
          inc(totalsec, cast[int](timing_delta(addr(t3), addr(t4))))

      ##  Create metadata file
      if fp != nil:
        discard sprintf(fname, "%s/Coding/%s_meta.txt", curdir, s1)
        fp2 = fopen(fname, "wb")
        discard fprintf(fp2, "%s\x0A", argv[1])
        discard fprintf(fp2, "%d\x0A", size)
        discard fprintf(fp2, "%d %d %d %d %d\x0A", k, m, w, packetsize, buffersize)
        discard fprintf(fp2, "%s\x0A", argv[4])
        discard fprintf(fp2, "%d\x0A", tech)
        discard fprintf(fp2, "%d\x0A", readins)
        discard fclose(fp2)

      ##  Free allocated memory
      free(s1)
      free(fname)
      free(`block`)
      free(curdir)

      ##  Calculate rate in MB/sec and print
      timing_set(addr(t2))
      tsec = timing_delta((addr(t1)), (addr(t2)))
      printf("Encoding (MB/sec): %0.10f\x0A", ((cast[int32](size)) div cast[int32](1024.0) div cast[int32](1024.0)) div cast[int32](totalsec))
      printf("En_Total (MB/sec): %0.10f\x0A", ((cast[int32](size)) div cast[int32](1024.0) div cast[int32](1024.0)) div cast[int32](tsec))

      return 0
