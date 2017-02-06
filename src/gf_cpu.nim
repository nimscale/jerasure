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

when defined(amd64):
  ##  CPUID Feature Bits
  ##  ECX
  const
    GF_CPU_SSE3* = (1 shl 0)
    GF_CPU_PCLMUL* = (1 shl 1)
    GF_CPU_SSSE3* = (1 shl 9)
    GF_CPU_SSE41* = (1 shl 19)
    GF_CPU_SSE42* = (1 shl 20)

  ##  EDX
  const
    GF_CPU_SSE2* = (1 shl 26)

  when defined(vcc):
    template cpuid*(info, x: untyped): untyped =
      cpu_cpuidex(info, x, 0)

  elif defined(gcc):
    proc cpuid*(info: array[4, cint]; InfoType: cint) {.cdecl.} =
      echo "CPU Count not found"
      #cpuid_count(InfoType, 0, info[0], info[1], info[2], info[3])

proc gf_cpu_identify*(): cint {.cdecl.} =
    gf_cpu_identified = 1
    return 0
