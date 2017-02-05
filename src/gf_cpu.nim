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

# Did not find any equivalent to C __x86_x64__ in nimlang, but
# Decided alittle bit to create a simpple way of definiing this marcors
var arc_x86: bool = false
var arc_x64: bool = false
var arc_xUnknown: bool = false


if hostCPU == "amd64":
  arc_x64 = true

elif hostCPU == "i386":
  arc_x86 = true
else:
  arc_xUnknown = true

when defined(arc_x64):

#if arc_x64 or arc_x86:
  ##  CPUID Feature Bits
  ##  ECX
  const
    GF_CPU_SSE3* = (1 shl 0)
    GF_CPU_PCLMUL* = (1 shl 1)
    GF_CPU_SSSE3* = (1 shl 9)
    GF_CPU_SSE41* = (1 shl 19)
    GF_CPU_SSE42* = (1 shl 20)
