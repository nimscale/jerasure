##
##  GF-Complete: A Comprehensive Open Source Library for Galois Field Arithmetic
##  James S. Plank, Ethan L. Miller, Kevin M. Greenan,
##  Benjamin A. Arnold, John A. Burnum, Adam W. Disney, Allen C. McBride.
##
##  gf_cpu.h
##
##  Identifies whether the CPU supports SIMD instructions at runtime.
##



var gf_cpu_identified*: cint
var gf_cpu_supports_intel_pclmul*: cint
var gf_cpu_supports_intel_sse4*: cint
var gf_cpu_supports_intel_ssse3*: cint
var gf_cpu_supports_intel_sse3*: cint
var gf_cpu_supports_intel_sse2*: cint
var gf_cpu_supports_arm_neon*: cint
