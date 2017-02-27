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
proc strrchr*(str: cstring; c: char): ptr char {.header: "<stdio.h>", importc:"strrchr"}
#proc strcpy*(dest: cstring; src: cstring): char {.header: "<string.h>", importc:"strcpy"}
proc strcpy*(dest: ptr cstring; src: ptr cstring): cstring {.header: "<string.h>", importc:"strcpy"}
proc strchr*(str: cstring; c: char): ptr char {.header: "<stdio.h>", importc:"strchr"}
proc strdup*(s: cstring): ptr char {.header: "<string.h>", importc:"strdup"}
proc strlen*(s: cstring): csize {.header: "<string.h>", importc:"strlen"}
proc malloc*(size: csize): ptr cstring {.header: "<stdlib.h>", importc:"malloc"}
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
proc get_current_dir_name*(): cstring {.header: "<unistd.h>", importc: "get_current_dir_name"}

# The following mkdir we ommited the mode mode_t which required a stat defined
# which we couln'd get. and we replaced with cstring
proc mkdir*(path: cstring; mode: cint): cint {.header:"<sys/stat.h>", importc:"mkdir"}

const
  SEEK_SET* = 0
  SEEK_CUR* = 1
  SEEK_END* = 2

const
  N* = 10

const
  coding_dir_mode: cint=16893

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
  #echo "Some oneis calling me"
  if stream != nil:
      echo "Stream is ", repr(stream)
      return fread(`ptr`, cast[cint](size), cast[cint](nmembers), stream)

  MOA_Fill_Random_Region(`ptr`, size)
  return size


proc main*(argc: cint; argv: cstringArray): cint =
      ##  file pointers
      var
        fp: ptr FILE
        fp2: ptr FILE

      ##  padding file
      var `block`: ptr cstring
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
        s1: cstring
        s2: cstring
        empty_char: cstring = ""
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
        tmp_sprintf:cint

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
          write(stderr, "usage: inputfile k m coding_technique w packetsize buffersize\n")
          echo ""
          write(stderr, "Choose one of the following coding techniques: \nreed_sol_van, \nreed_sol_r6_op, \ncauchy_orig, \ncauchy_good, \nliberation, \nblaum_roth, \nliber8tion")
          write(stderr, "\tPacketsize is ignored for the reed_sol\'s")
          write(stderr, "Buffersize of 0 means the buffersize is chosen automatically.\x0A")
          write(stderr, "If you just want to test speed, use an inputfile of \"-number\" where number is the size of the fake file you want to test.\x0A\x0A")
          quit(0)

      ##  Conversion of parameters and error checking
      if sscanf(argv[2], "%d", addr(k)) == 0 or k <= 0:
        write(stderr, "Invalid value for k\x0A")
        quit(0)

      if sscanf(argv[3], "%d", addr(m)) == 0 or m < 0:
        write(stderr, "Invalid value for m\x0A")
        quit(0)

      if sscanf(argv[5], "%d", addr(w)) == 0 or w < 0:
        write(stderr, "Invalid value for w\n")
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
            write(stderr, "w must be one of {8, 16, 32}\n")
            quit(0)

      elif strcmp(argv[4], "reed_sol_r6_op") == 0:
        if m != 2:
          write(stderr, "m must be equal to 2\n")
          quit(0)

        if w != 8 and w != 16 and w != 32:
          write(stderr, "w must be one of {8, 16, 32}\n")
          quit(0)
        tech = Reed_Sol_R6_Op

      elif strcmp(argv[4], "cauchy_orig") == 0:
        tech = Cauchy_Orig
        if packetsize == 0:
          write(stderr, "Must include packetsize.\n")
          quit(0)

      elif strcmp(argv[4], "liberation") == 0:
        if k > w:
          write(stderr, "k must be less than or equal to w\n")
          quit(0)

        if w <= 2 or not cast[bool](w mod 2) or not cast[bool](is_prime(w)):
          write(stderr, "w must be greater than two and w must be prime\n")
          quit(0)

        if packetsize == 0:
          write(stderr, "Must include packetsize.\x0A")
          quit(0)

        if (packetsize mod (sizeof(clong))) != 0:
          write(stderr, "packetsize must be a multiple of sizeof(long)\n")
          quit(0)
        tech = Liberation

      elif strcmp(argv[4], "blaum_roth") == 0:
          if k > w:
            write(stderr, "k must be less than or equal to w\n")
            quit(0)

          if w <= 2 or not cast[bool]((w + 1) mod 2) or not cast[bool](is_prime(w + 1)):
            write(stderr, "w must be greater than two and w+1 must be prime\n")
            quit(0)

          if packetsize == 0:
            write(stderr, "Must include packetsize.\x0A")
            quit(0)

          if (packetsize mod (sizeof((clong)))) != 0:
            write(stderr, "packetsize must be a multiple of sizeof(long)\n")
            quit(0)
          tech = Blaum_Roth

      elif strcmp(argv[4], "liber8tion") == 0:
          if packetsize == 0:
            write(stderr, "Must include packetsize\n")
            quit(0)

          if w != 8:
            write(stderr, "w must equal 8\n")
            quit(0)

          if m != 2:
            write(stderr, "m must equal 2\n")
            quit(0)

          if k > w:
            write(stderr, "k must be less than or equal to w\n")
            quit(0)
          tech = Liber8tion

      else:
          write(stderr, "Not a valid coding technique. Choose one of the following: reed_sol_van, reed_sol_r6_op, cauchy_orig, cauchy_good, liberation, blaum_roth, liber8tion, no_coding\x0A")
          quit(0)

      ##  Set global variable method for signal handler
      `method` = tech

      ##  Get current working directory for construction of file names
      #curdir = cast[cstring](malloc(sizeof(char) * 1000))
      #assert(curdir == getcwd(curdir, 1000))
      curdir = get_current_dir_name()

      if argv[1][0] != '-':
          ##  Open file and error check
          #echo "File opening in the file elif ", argv[1]
          fp = fopen(argv[1], "rb")
          #echo "FP IS ", repr(fp)
          if fp == nil:
            write(stderr, "Unable to open file.\x0A")
            quit(0)

          else:
              #echo "File successfuly opened!"
              #echo "FP IT IS ", repr(fp)

              i = mkdir("Coding", coding_dir_mode)

              if i == -1:
                  write(stderr, "Unable to create Coding directory. It already exists\n")
                  quit(0)

              discard stat(argv[1], addr(status))
              size = cast[int32](status.st_size)
              #echo "AGAIN FP IS ALIVE ", repr(fp)

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
        `block` = malloc(sizeof(cstring) * buffersize)
        echo "Block size ", repr(`block`)
        #`block` = addr(block_tmp_handler)

        blocksize = buffersize div k

      else:
        readins = 1
        buffersize = size

        # Temporary save the turn value and then
        # pass the pointer to our block variable.
        #echo "NEw size ", newsize
        #echo "Size cstring ", sizeof(cstring)
        `block` = malloc(sizeof(cstring) * newsize)
        #echo "OR block ", repr(`block`)
        #`block` = addr(block_tmp_handler)

      #echo "If you see this message then the Seg fault is belof this line"
      ##  Break inputfile name into the filename and extension
      #cs1 = cast[cstring](malloc(sizeof(char) * strlen(argv[1])))
      s1 = cast[cstring](malloc(sizeof(cstring) * (strlen(argv[1]) + 20)))

      #s1 = cast[cstring](cast[cstring](malloc(sizeof(char) * (strlen(argv[1]) + 20))))
      s2 = cast[cstring](strrchr(argv[1], '/'))

      if s2.addr != nil:
        discard strcpy(addr(s1), addr(s2))
      else:
        discard strcpy(addr(s1), addr(argv[1]))

      s2 = strchr(s1, '.')

      if s2 != nil:
        #extension = strdup(cs2)
        #echo "Segfault in here!"
        extension = strdup(s2)
        s2 = cast[cstring]("\0")
        #echo "After segfult "
      else:
          #echo "Seg fault in th else clause!"
          extension = strdup(empty_char)

      discard sprintf(temp, "%d", k)

      ##  Allocate for full file name
      fname = cast[cstring](malloc(sizeof(cstring) * (strlen(argv[1]) + strlen(curdir) + 20)))

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
      var ffname: cstring
      ffname = cast[cstring] (malloc( sizeof(cstring) * (100 + 100 + 400)))

      while n <= readins:
          ##  Check if padding is needed, if so, add appropriate
          ##  number of zeros
          if total < size and total + buffersize <= size:
            inc(total, jfread(addr(`block`), cast[cint](sizeof(char)), buffersize, fp))

          elif total < size and total + buffersize > size:
            extra = cast[cint](jfread(addr(`block`), cast[cint](sizeof(char)), buffersize, fp))
            i = extra

            while i < buffersize:
              var tmp_char: cstring = "0"
              (`block`.addr + 1)[] = addr(tmp_char)
              inc(i)

          elif total == size: ##  Set pointers to point to file data
            i = 0
            while i < buffersize:
              var tmp_char: cstring = "0"
              (`block`.addr + i)[] = addr(tmp_char)
              inc(i)

          i = 0
          ## Set a pointer to point to the file data
          while i < k:
            data[i] = cast[cstring](`block`.addr  + (i * blocksize))
            #cast[cstring](`block`.addr  + (i * blocksize))
            inc(i)

          #echo "Okay we are in the code coding chamber thea bove should be fine!"
          timing_set(addr(t3))
          ##  Encode according to coding method
          #echo "Tracking segmentation fault"
          #case tech
          if(No_Coding == tech):
            nil
          #of No_Coding:
            nil
          elif( Reed_Sol_Van == tech):
            echo "it's reed Solomon codding problem!"
            #jerasure_matrix_encode(k, m, w, matrix, data, coding, blocksize)

          elif (Reed_Sol_R6_Op == tech):
              echo "RED sold 5"
              #discard reed_sol_r6_encode(k, w, data, coding, blocksize)
          elif (Cauchy_Orig == tech):
              jerasure_schedule_encode(k, m, w, schedule, data, coding, blocksize, packetsize)
          elif (Cauchy_Good == tech):
              jerasure_schedule_encode(k, m, w, schedule, data, coding, blocksize, packetsize)
          elif( Liberation == tech):
              jerasure_schedule_encode(k, m, w, schedule, data, coding, blocksize, packetsize)
          elif(Blaum_Roth == tech):
              jerasure_schedule_encode(k, m, w, schedule, data, coding, blocksize, packetsize)
          elif (Liber8tion == tech):
              jerasure_schedule_encode(k, m, w, schedule, data, coding, blocksize, packetsize)
          elif (RDP == tech):
              assert(false)
          elif(EVENODD == tech):
              assert(false)

          #echo "What about here "
          timing_set(addr(t4))

          ##  Write data and encoded data to k+m files
          #echo "here is the sweet sport"
          i = 1

          while i <= k:
            if fp == nil:
              zeroMem(addr(data[i - 1]), blocksize)

            else:
                tmp_sprintf =  sprintf(fname, "%s/Coding%s_k%0*d%s", curdir, s1, md, i, extension)
                echo fname

                if n == 1:
                  fp2 = fopen(fname, "wb")
                else:
                  fp2 = fopen(fname, "ab")
                discard fwrite(data[i - 1], sizeof(char), blocksize, fp2)
                discard fclose(fp2)
            inc(i)
          i = 1

          while i <= m:
            if fp == nil:
              zeroMem(addr(data[i - 1]), blocksize)
            else:
              discard sprintf(fname, "%s/Coding/%s_m%0*d%s", curdir, s1, md, i, extension)
              if n == 1:
                fp2 = fopen(fname, "wb")
              else:
                fp2 = fopen(fname, "ab")
              discard fwrite(coding[i - 1], sizeof(char), blocksize, fp2)
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
      #free(s1)
      free(fname)
      free(`block`)
      free(curdir)

      ##  Calculate rate in MB/sec and print
      timing_set(addr(t2))
      tsec = timing_delta((addr(t1)), (addr(t2)))
      #echo cast[int32](1024.0) div cast[int32](totalsec)
      echo "Size ", cast[int32](size)
      #echo 10 div cast[int32](tsec)
      #printf("Encoding (MB/sec): %0.10f\x0A", ((cast[int32](size)) div cast[int32](1024.0) div cast[int32](1024.0)) div cast[int32](totalsec))
      #printf("En_Total (MB/sec): %0.10f\x0A", ((cast[int32](size)) div cast[int32](1024.0) div cast[int32](1024.0)) div cast[int32](tsec))

      return 0

when isMainModule:
      var args: seq[TaintedString] #string
      args = commandLineParams()

      if args.len() >= 1:
            # Our problem indexes from 1 which is the file to encode
            # but one according to our commandline arguments is a different
            # value. So insert at position 1 same as position 0
            args.insert(args[0], 0)

            var source = allocCStringArray(args)

            ### NOTE: our main function will acess the values from 1
            # But if we try to access like this source[1] it is nill
            # So attempt to place in source[1] the value of source[0]
            if source[1] == nil:
                source[1] = source[0]

            #/home/s8software/index.html 3  2 reed_sol_van 8 0 0
            #echo "At index  0 ", source[0]
            #echo "At index  1 ", source[1]
            #echo "At index  2 ", source[2]
            #echo "At index  3 ", source[3]
            #echo "At index  4 ", source[4]
            #echo "At index  5 ", source[5]
            #echo "At index  6 ", source[6]
            #echo "At index  7 ", source[7]

            discard main(cast[cint](args.len()), source)
      else:
          echo "usage: inputfile"
          echo "eg  ./encode  /home/s8software/index.html 3  2 reed_sol_van 8 0 0"
