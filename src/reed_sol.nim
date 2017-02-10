

# Call our shared library to be linked together
{.link:"/usr/local/lib/libJerasure.so.2.0.0"}

proc reed_sol_vandermonde_coding_matrix*(k: cint; m: cint; w: cint): ptr cint {.importc.}

proc reed_sol_extended_vandermonde_matrix*(rows: cint; cols: cint; w: cint): ptr cint {.importc.}

proc reed_sol_big_vandermonde_distribution_matrix*(rows: cint; cols: cint; w: cint): ptr cint {.importc.}

proc reed_sol_r6_encode*(k: cint; w: cint; data_ptrs: cstringArray;
                        coding_ptrs: cstringArray; size: cint): cint {.importc.}

proc reed_sol_r6_coding_matrix*(k: cint; w: cint): ptr cint {.importc.}

proc reed_sol_galois_w08_region_multby_2*(region: cstring; nbytes: cint) {.importc.}

proc reed_sol_galois_w16_region_multby_2*(region: cstring; nbytes: cint) {.importc.}

proc reed_sol_galois_w32_region_multby_2*(region: cstring; nbytes: cint) {.importc.}
