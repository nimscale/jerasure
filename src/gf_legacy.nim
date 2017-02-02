import gf_definitions

type
  FAST_U8* = cuint
  FAST_U16* = cuint
  FAST_U32* = cuint

const
  UNALIGNED_BUFSIZE* = (8)
  UNALIGNED_BUFSIZE_BYTES* = (UNALIGNED_BUFSIZE * sizeof((FAST_U8)))

proc gf_multby_zero*(dest: pointer; bytes: cint; `xor`: cint) {.cdecl.} =
  if bool(`xor`):
    return
  zeroMem(dest,  bytes)
  return

proc gf_set_region_data*(rd: ptr gf_region_data; gf: ptr gf_t; src: pointer;
                        dest: pointer; bytes: cint; val: uint64; `xor`: cint;
                        align: cint; walign: cint) {.cdecl.} =
  var h: ptr gf_internal_t
  var wb: cint
  var
    uls: culong
    uld: culong
  if gf == nil:
    ##  JSP - Can be NULL if you're just doing XOR's
    wb = 1
  else:
    h = cast[ptr gf_internal_t](gf.scratch)
    wb = (h.w) div 8
    if wb == 0: wb = 1
  rd.gf = gf
  rd.src = src
  rd.dest = dest
  rd.bytes = bytes
  rd.val = val
  rd.`xor` = `xor`
  uls = cast[culong](src)
  uld = cast[culong](dest)
  if align == - 1:
    ##  JSP: This is cauchy.  Error check bytes, then set up the pointers
    ##                         so that there are no alignment regions.
    if h != nil and bytes mod h.w != 0:
      write(stderr, "Error in region multiply operation.\x0A")
      write(stderr, "The size must be a multiple of %d bytes.\x0A", h.w)
      assert(true)
    rd.s_start = src
    rd.d_start = dest
    rd.s_top = cast[ptr uint8](cast[uint8](src) + cast[uint8](bytes))
    #rd.d_top = cast[ptr uint8](src) + bytes
    return

  if uls mod align != uld mod align:
    write(stderr, "Error in region multiply operation.\x0A")
    write(stderr, "The source & destination pointers must be aligned with respect\x0A")
    write(stderr, "to each other along a %d byte boundary.\x0A", align)
    write(stderr, "Src = 0x%lx.  Dest = 0x%lx\x0A", cast[culong](src),
            cast[culong](dest))
    assert(0)
  if uls mod wb != 0:
    write(stderr, "Error in region multiply operation.\x0A")
    write(stderr, "The pointers must be aligned along a %d byte boundary.\x0A",
            wb)
    write(stderr, "Src = 0x%lx.  Dest = 0x%lx\x0A", cast[culong](src),
            cast[culong](dest))
    assert(0)
  if bytes mod wb != 0:
    write(stderr, "Error in region multiply operation.\x0A")
    write(stderr, "The size must be a multiple of %d bytes.\x0A", wb)
    assert(0)
  uls = uls mod align
  if uls != 0: uls = (align - uls)
  rd.s_start = cast[ptr uint8](rd.src) + uls
  rd.d_start = cast[ptr uint8](rd.dest) + uls
  dec(bytes, uls)
  dec(bytes, (bytes mod walign))
  rd.s_top = cast[ptr uint8](rd.s_start) + bytes
  rd.d_top = cast[ptr uint8](rd.d_start) + bytes

proc gf_unaligned_xor*(src: pointer; dest: pointer; bytes: cint) {.cdecl.} =
  var
    scopy: array[UNALIGNED_BUFSIZE, FAST_U8]
    d64: ptr FAST_U8
  var i: cint
  var rd: gf_region_data
  var
    s8: ptr uint8
    d8: ptr uint8
  ##  JSP - call gf_set_region_data(), but use dest in both places.  This is
  ##      because I only want to set up dest.  If I used src, gf_set_region_data()
  ##      would fail because src and dest are not aligned to each other wrt
  ##      8-byte pointers.  I know this will actually align d_start to 16 bytes.
  ##      If I change gf_set_region_data() to split alignment & chunksize, then
  ##      I could do this correctly.
  gf_set_region_data(addr(rd), nil, dest, dest, bytes, 1, 1, sizeof((FAST_U8)),
                     UNALIGNED_BUFSIZE_BYTES)
  s8 = cast[ptr uint8](src)
  d8 = cast[ptr uint8](dest)
  while d8 < cast[ptr uint8](rd.d_start):
    d8[] = d8[] xor s8[]
    inc(d8)
    inc(s8)
  d64 = cast[ptr FAST_U8](d8)
  while d64 < cast[ptr FAST_U8](rd.d_top):
    memcpy(scopy, s8, UNALIGNED_BUFSIZE_BYTES)
    inc(s8, UNALIGNED_BUFSIZE_BYTES)
    i = 0
    while i < UNALIGNED_BUFSIZE:
      d64[] = d64[] xor scopy[i]
      inc(d64)
      inc(i)
  d8 = cast[ptr uint8](d64)
  while d8 < cast[ptr uint8]((cast[ptr uint8](dest) + bytes)):
    d8[] = d8[] xor s8[]
    inc(d8)
    inc(s8)

proc gf_multby_one*(src: pointer; dest: pointer; bytes: cint; `xor`: cint) {.cdecl.} =
  when defined(INTEL_SSE2):
    var
      ms: rp_m128i
      md: rp_m128i
    var abytes: cint
  var
    uls: culong
    uld: culong
  var
    s8: ptr uint8
    d8: ptr uint8
  var
    s64: ptr FAST_U8
    d64: ptr FAST_U8
    dtop64: ptr FAST_U8
  var rd: gf_region_data
  if bool(not `xor`):
    copyMem(dest, src, bytes)
    return
  uls = cast[culong](src)
  uld = cast[culong](dest)
  when defined(INTEL_SSE2):
    s8 = cast[ptr uint8](src)
    d8 = cast[ptr uint8](dest)
    if uls mod 16 == uld mod 16:
      gf_set_region_data(addr(rd), nil, src, dest, bytes, 1, `xor`, 16, 16)
      while s8 != rd.s_start:
        d8[] = d8[] xor s8[]
        inc(d8)
        inc(s8)
      while s8 < cast[ptr uint8](rd.s_top):
        ms = rp_mm_load_si128(cast[ptr rp_m128i]((s8)))
        md = rp_mm_load_si128(cast[ptr rp_m128i]((d8)))
        md = rp_mm_xor_si128(md, ms)
        rp_mm_store_si128(cast[ptr rp_m128i]((d8)), md)
        inc(s8, 16)
        inc(d8, 16)
      while s8 != cast[ptr uint8](src) + bytes:
        d8[] = d8[] xor s8[]
        inc(d8)
        inc(s8)
      return
    abytes = (bytes and 0xFFFFFFF0)
    while d8 < cast[ptr uint8_t](dest) + abytes:
      ms = rp_mm_loadu_si128(cast[ptr rp_m128i]((s8)))
      md = rp_mm_loadu_si128(cast[ptr rp_m128i]((d8)))
      md = rp_mm_xor_si128(md, ms)
      rp_mm_storeu_si128(cast[ptr rp_m128i]((d8)), md)
      inc(s8, 16)
      inc(d8, 16)
    while d8 != cast[ptr uint8](dest) + bytes:
      d8[] = d8[] xor s8[]
      inc(d8)
      inc(s8)
    return
  when defined(ARM_NEON):
    s8 = cast[ptr uint8_t](src)
    d8 = cast[ptr uint8_t](dest)
    if uls mod 16 == uld mod 16:
      gf_set_region_data(addr(rd), nil, src, dest, bytes, 1, `xor`, 16, 16)
      while s8 != rd.s_start:
        d8[] = d8[] xor s8[]
        inc(s8)
        inc(d8)
      while s8 < cast[ptr uint8_t](rd.s_top):
        var vs: uint8x16_t
        var vd: uint8x16_t
        var vr: uint8x16_t
        vst1q_u8(d8, vr)
        inc(s8, 16)
        inc(d8, 16)
    else:
      while s8 + 15 < cast[ptr uint8_t](src) + bytes:
        var vs: uint8x16_t
        var vd: uint8x16_t
        var vr: uint8x16_t
        vst1q_u8(d8, vr)
        inc(s8, 16)
        inc(d8, 16)
    while s8 < cast[ptr uint8_t](src) + bytes:
      d8[] = d8[] xor s8[]
      inc(s8)
      inc(d8)
    return
  if uls mod 8 != uld mod 8:
    gf_unaligned_xor(src, dest, bytes)
    return
  gf_set_region_data(addr(rd), nil, src, dest, bytes, 1, `xor`, 1, 8)
  s8 = cast[ptr uint8_t](src)
  d8 = cast[ptr uint8_t](dest)
  while d8 != rd.d_start:
    d8[] = d8[] xor s8[]
    inc(d8)
    inc(s8)
  dtop64 = cast[ptr FAST_U8](rd.d_top)
  d64 = cast[ptr FAST_U8](rd.d_start)
  s64 = cast[ptr FAST_U8](rd.s_start)
  while d64 < dtop64:
    d64[] = d64[] xor s64[]
    inc(d64)
    inc(s64)
  s8 = cast[ptr uint8](rd.s_top)
  d8 = cast[ptr uint8](rd.d_top)
  while d8 != cast[ptr uint8_t](dest) + bytes:
    d8[] = d8[] xor s8[]
    inc(d8)
    inc(s8)
  return

