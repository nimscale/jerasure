##  These are all pretty self-explanatory
{.link:"/usr/local/lib/libJerasure.so.2.0.0"}

proc MOA_Random_32*(): uint32 {.importc.}
proc MOA_Random_64*(): uint64 {.importc.}
proc MOA_Random_128*(x: ptr uint64) {.importc.}
proc MOA_Random_W*(w: cint; zero_ok: cint): uint32 {.importc.}
proc MOA_Fill_Random_Region*(reg: pointer; size: cint) {.importc.} ##  reg should be aligned to 4 bytes, but size can be anything.

proc MOA_Seed*(seed: uint32) {.importc.}
