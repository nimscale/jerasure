import galois, jerasure

# We want to test for galois here
# The test is going to run against
# this procs.

#****************************************************************************
# proc galois_init_default_field
# proc galois_uninit_field
# proc galois_init_default_field
# proc galois_uninit_field
# NOTE: the above proc will be tested with value four
# as the main proc below shows

{.link:"/usr/local/lib/libJerasure.so.2.0.0"}
proc main(four:cint, eight:cint): cint =
     # Performs a test against the galois proc defined above
     # @param: four, the interger value four will b sued
     # for the first test.
     # @param: eight, the integer value eight will be used
     # for the test test.
     # All tests should output zero.

     assert(galois_init_default_field(four) == 0)
     assert(galois_uninit_field(four) == 0)
     assert(galois_init_default_field(four) == 0)
     assert(galois_uninit_field(four) == 0)

     # Test the value of eight
     assert(galois_init_default_field(eight) == 0)
     assert(galois_uninit_field(eight) == 0)
     assert(galois_init_default_field(eight) == 0)
     assert(galois_uninit_field(eight) == 0)

     return 0

when isMainModule:
     discard main(4, 8)
