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
## 
##    Revision 2.x - 2014: James S. Plank and Kevin M. Greenan
##    Revision 1.2 - 2008: James S. Plank, Scott Simmerman and Catherine D. Schuman.
##    Revision 1.0 - 2007: James S. Plank
## 

import
  galois, jerasure, reed_sol

template talloc*(`type`, num: untyped): untyped =
  cast[ptr `type`](malloc(sizeof((`type`) * (num))))

proc reed_sol_r6_coding_matrix*(k: cint; w: cint): ptr cint =
  var matrix: ptr cint
  var
    i: cint
    tmp: cint
  if w != 8 and w != 16 and w != 32: return nil
  matrix = talloc(int, 2 * k)
  if matrix == nil: return nil
  i = 0
  while i < k:
    matrix[i] = 1
    inc(i)
  matrix[k] = 1
  tmp = 1
  i = 1
  while i < k:
    tmp = galois_single_multiply(tmp, 2, w)
    matrix[k + i] = tmp
    inc(i)
  return matrix

proc reed_sol_vandermonde_coding_matrix*(k: cint; m: cint; w: cint): ptr cint =
  var
    i: cint
    j: cint
  var
    vdm: ptr cint
    dist: ptr cint
  vdm = reed_sol_big_vandermonde_distribution_matrix(k + m, k, w)
  if vdm == nil: return nil
  dist = talloc(int, m * k)
  if dist == nil:
    free(vdm)
    return nil
  i = k * k
  j = 0
  while j < m * k:
    dist[j] = vdm[i]
    inc(i)
    inc(j)
  free(vdm)
  return dist

var prim08*: cint = - 1

var GF08*: gf_t

proc reed_sol_galois_w08_region_multby_2*(region: cstring; nbytes: cint) =
  if prim08 == - 1:
    prim08 = galois_single_multiply((1 shl 7), 2, 8)
    if not gf_init_hard(addr(GF08), 8, GF_MULT_BYTWO_b, GF_REGION_DEFAULT,
                      GF_DIVIDE_DEFAULT, prim08, 0, 0, nil, nil):
      fprintf(stderr, "Error: Can\'t initialize the GF for reed_sol_galois_w08_region_multby_2\x0A")
      assert(0)
  GF08.multiply_region.w32(addr(GF08), region, region, 2, nbytes, 0)

var prim16*: cint = - 1

var GF16*: gf_t

proc reed_sol_galois_w16_region_multby_2*(region: cstring; nbytes: cint) =
  if prim16 == - 1:
    prim16 = galois_single_multiply((1 shl 15), 2, 16)
    if not gf_init_hard(addr(GF16), 16, GF_MULT_BYTWO_b, GF_REGION_DEFAULT,
                      GF_DIVIDE_DEFAULT, prim16, 0, 0, nil, nil):
      fprintf(stderr, "Error: Can\'t initialize the GF for reed_sol_galois_w16_region_multby_2\x0A")
      assert(0)
  GF16.multiply_region.w32(addr(GF16), region, region, 2, nbytes, 0)

var prim32*: cint = - 1

var GF32*: gf_t

proc reed_sol_galois_w32_region_multby_2*(region: cstring; nbytes: cint) =
  if prim32 == - 1:
    prim32 = galois_single_multiply((1 shl 31), 2, 32)
    if not gf_init_hard(addr(GF32), 32, GF_MULT_BYTWO_b, GF_REGION_DEFAULT,
                      GF_DIVIDE_DEFAULT, prim32, 0, 0, nil, nil):
      fprintf(stderr, "Error: Can\'t initialize the GF for reed_sol_galois_w32_region_multby_2\x0A")
      assert(0)
  GF32.multiply_region.w32(addr(GF32), region, region, 2, nbytes, 0)

proc reed_sol_r6_encode*(k: cint; w: cint; data_ptrs: cstringArray;
                        coding_ptrs: cstringArray; size: cint): cint =
  var i: cint
  ##  First, put the XOR into coding region 0
  memcpy(coding_ptrs[0], data_ptrs[0], size)
  i = 1
  while i < k:
    galois_region_xor(data_ptrs[i], coding_ptrs[0], size)
    inc(i)
  ##  Next, put the sum of (2^j)*Dj into coding region 1
  memcpy(coding_ptrs[1], data_ptrs[k - 1], size)
  i = k - 2
  while i >= 0:
    case w
    of 8:
      reed_sol_galois_w08_region_multby_2(coding_ptrs[1], size)
    of 16:
      reed_sol_galois_w16_region_multby_2(coding_ptrs[1], size)
    of 32:
      reed_sol_galois_w32_region_multby_2(coding_ptrs[1], size)
    else:
      return 0
    galois_region_xor(data_ptrs[i], coding_ptrs[1], size)
    dec(i)
  return 1

proc reed_sol_extended_vandermonde_matrix*(rows: cint; cols: cint; w: cint): ptr cint =
  var vdm: ptr cint
  var
    i: cint
    j: cint
    k: cint
  if w < 30 and (1 shl w) < rows: return nil
  if w < 30 and (1 shl w) < cols: return nil
  vdm = talloc(int, rows * cols)
  if vdm == nil:
    return nil
  vdm[0] = 1
  j = 1
  while j < cols:
    vdm[j] = 0
    inc(j)
  if rows == 1: return vdm
  i = (rows - 1) * cols
  j = 0
  while j < cols - 1:
    vdm[i + j] = 0
    inc(j)
  vdm[i + j] = 1
  if rows == 2: return vdm
  i = 1
  while i < rows - 1:
    k = 1
    j = 0
    while j < cols:
      vdm[i * cols + j] = k
      k = galois_single_multiply(k, i, w)
      inc(j)
    inc(i)
  return vdm

proc reed_sol_big_vandermonde_distribution_matrix*(rows: cint; cols: cint; w: cint): ptr cint =
  var dist: ptr cint
  var
    i: cint
    j: cint
    k: cint
  var
    sindex: cint
    srindex: cint
    siindex: cint
    tmp: cint
  if cols >= rows: return nil
  dist = reed_sol_extended_vandermonde_matrix(rows, cols, w)
  if dist == nil: return nil
  sindex = 0
  i = 1
  while i < cols:
    inc(sindex, cols)
    ##  Find an appropriate row -- where i,i != 0
    srindex = sindex + i
    j = i
    while j < rows and dist[srindex] == 0:
      inc(srindex, cols)
      inc(j)
    if j >= rows:
      ##  This should never happen if rows/w are correct
      fprintf(stderr, "reed_sol_big_vandermonde_distribution_matrix(%d,%d,%d) - couldn\'t make matrix\x0A",
              rows, cols, w)
      assert(0)
    if j != i:
      dec(srindex, i)
      k = 0
      while k < cols:
        tmp = dist[srindex + k]
        dist[srindex + k] = dist[sindex + k]
        dist[sindex + k] = tmp
        inc(k)
    if dist[sindex + i] != 1:
      tmp = galois_single_divide(1, dist[sindex + i], w)
      srindex = i
      j = 0
      while j < rows:
        dist[srindex] = galois_single_multiply(tmp, dist[srindex], w)
        inc(srindex, cols)
        inc(j)
    j = 0
    while j < cols:
      tmp = dist[sindex + j]
      if j != i and tmp != 0:
        srindex = j
        siindex = i
        k = 0
        while k < rows:
          dist[srindex] = dist[srindex] xor
              galois_single_multiply(tmp, dist[siindex], w)
          inc(srindex, cols)
          inc(siindex, cols)
          inc(k)
      inc(j)
    inc(i)
  ##  We desire to have row k be all ones.  To do that, multiply
  ##      the entire column j by 1/dist[k,j].  Then row j by 1/dist[j,j].
  sindex = cols * cols
  j = 0
  while j < cols:
    tmp = dist[sindex]
    if tmp != 1:
      tmp = galois_single_divide(1, tmp, w)
      srindex = sindex
      i = cols
      while i < rows:
        dist[srindex] = galois_single_multiply(tmp, dist[srindex], w)
        inc(srindex, cols)
        inc(i)
    inc(sindex)
    inc(j)
  ##  Finally, we'd like the first column of each row to be all ones.  To
  ##      do that, we multiply the row by the inverse of the first element.
  sindex = cols * (cols + 1)
  i = cols + 1
  while i < rows:
    tmp = dist[sindex]
    if tmp != 1:
      tmp = galois_single_divide(1, tmp, w)
      j = 0
      while j < cols:
        dist[sindex + j] = galois_single_multiply(dist[sindex + j], tmp, w)
        inc(j)
    inc(sindex, cols)
    inc(i)
  return dist
