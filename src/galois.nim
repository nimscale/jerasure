import gf_typedef


{.link:"/usr/local/lib/libgf_complete.so.1.0.0"}
{.link:"/usr/local/lib/libJerasure.so.2.0.0"}
proc galois_init_default_field*(w: cint): cint {.importc.}

proc galois_uninit_field*(w: cint): cint {.importc.}

proc galois_change_technique*(gf: ptr gf_t; w: cint) {.importc.}

proc galois_single_multiply*(a: cint; b: cint; w: cint): cint {.importc.}

proc galois_single_divide*(a: cint; b: cint; w: cint): cint {.importc.}

proc galois_inverse*(x: cint; w: cint): cint {.importc.}

proc galois_region_xor*(src: cstring; dest: cstring; nbytes: cint) {.importc.}

##  Source Region
##  Dest Region (holds result)
##  Number of bytes in region
##  These multiply regions in w=8, w=16 and w=32.  They are much faster
##    than calling galois_single_multiply.  The regions must be long word aligned.

proc galois_w08_region_multiply*(region: cstring; multby: cint; nbytes: cint;
                                r2: cstring; add: cint) {.importc.}
  ##  Region to multiply
  ##  Number to multiply by
  ##  Number of bytes in region
  ##  If r2 != NULL, products go here.
  ##                                                        Otherwise region is overwritten
##  If (r2 != NULL && add) the produce is XOR'd with r2

proc galois_w16_region_multiply*(region: cstring; multby: cint; nbytes: cint;
                                r2: cstring; add: cint) {.importc.}
  ##  Region to multiply
  ##  Number to multiply by
  ##  Number of bytes in region
  ##  If r2 != NULL, products go here.
  ##                                                        Otherwise region is overwritten
##  If (r2 != NULL && add) the produce is XOR'd with r2

proc galois_w32_region_multiply*(region: cstring; multby: cint; nbytes: cint;
                                r2: cstring; add: cint) {.importc.}
  ##  Region to multiply
  ##  Number to multiply by
  ##  Number of bytes in region
  ##  If r2 != NULL, products go here.
  ##                                                        Otherwise region is overwritten
##  If (r2 != NULL && add) the produce is XOR'd with r2

proc galois_init_field*(w: cint; mult_type: cint; region_type: cint; divide_type: cint;
                       prim_poly: uint64; arg1: cint; arg2: cint): ptr gf_t {.importc.}

proc galois_init_composite_field*(w: cint; region_type: cint; divide_type: cint;
                                 degree: cint; base_gf: ptr gf_t): ptr gf_t {.importc.}

proc galois_get_field_ptr*(w: cint): ptr gf_t {.importc.}
