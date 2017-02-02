proc gf_w4_shift_init*(gf: ptr gf_t): cint {.cdecl.} =
  SET_FUNCTION(gf, multiply, w32, gf_w4_shift_multiply)
  return 1
