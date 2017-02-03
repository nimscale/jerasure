import gf_typedef

proc gf_init_easy*(gf: ptr gf_t; w: cint): cint {.cdecl.} =
  return w
  #return gf_init_hard(gf, w, GF_MULT_DEFAULT, GF_REGION_DEFAULT, GF_DIVIDE_DEFAULT, 0,
   #                  0, 0, nil, nil)


#proc gf_free*(gf: ptr gf_t; recursive: cint): cint {.cdecl.} =
#  var h: ptr gf_internal_t
#  h = cast[ptr gf_internal_t](gf.scratch)
#  if recursive and h.base_gf != nil:
#    gf_free(h.base_gf, 1)
#    free(h.base_gf)
#  if h.free_me: free(h)
#  return 0

  
