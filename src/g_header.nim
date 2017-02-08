type
  GFP* = object
    gf:int

type
  #GFP* = ptr gf

  gf_func_a_b* = object {.union.}
    w32*: proc (gf: GFP; a: gf_val_32_t; b: gf_val_32_t): gf_val_32_t {.cdecl, dynlib: "gf_complete.h".}
    w64*: proc (gf: GFP; a: gf_val_64_t; b: gf_val_64_t): gf_val_64_t {.cdecl.}
    w128*: proc (gf: GFP; a: gf_val_128_t; b: gf_val_128_t; c: gf_val_128_t) {.cdecl.}

  gf_func_a* = object {.union.}
    w32*: proc (gf: GFP; a: gf_val_32_t): gf_val_32_t {.cdecl.}
    w64*: proc (gf: GFP; a: gf_val_64_t): gf_val_64_t {.cdecl.}
    w128*: proc (gf: GFP; a: gf_val_128_t; b: gf_val_128_t) {.cdecl.}

  gf_region* = object {.union.}
    w32*: proc (gf: GFP; src: pointer; dest: pointer; val: gf_val_32_t; bytes: cint;
              add: cint) {.cdecl.}
    w64*: proc (gf: GFP; src: pointer; dest: pointer; val: gf_val_64_t; bytes: cint;
              add: cint) {.cdecl.}
    w128*: proc (gf: GFP; src: pointer; dest: pointer; val: gf_val_128_t; bytes: cint;
               add: cint) {.cdecl.}

  gf_extract* = object {.union.}
    w32*: proc (gf: GFP; start: pointer; bytes: cint; index: cint): gf_val_32_t {.cdecl.}
    w64*: proc (gf: GFP; start: pointer; bytes: cint; index: cint): gf_val_64_t {.cdecl.}
    w128*: proc (gf: GFP; start: pointer; bytes: cint; index: cint; rv: gf_val_128_t) {.
        cdecl.}

  gf_t* = object
    multiply*: gf_func_a_b
    divide*: gf_func_a_b
    inverse*: gf_func_a
    multiply_region*: gf_region
    extract_word*: gf_extract
    scratch*: pointer
