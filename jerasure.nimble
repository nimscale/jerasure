# Package

version       = "0.1.0"
author        = "Wangolo Joel"
description   = "Nim bindings for jerasure, a library in C that supports erasure coding in storage applications."
license       = "Apache License"

installDirs = "include, src"

# Dependencies

requires "nim >= 0.15.2"
#skipDirs = @["nimexample", "include"]

#when defined(nimdistros):
#    import distros
#    if(detectOs(Ubuntu):
#        foreignDep "libjerasure-dev"
#    else:
#        foreignDep "libjerasure-dev"
