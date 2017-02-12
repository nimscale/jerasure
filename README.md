# jerasure
nim bindings for https://github.com/tsuraan/Jerasure

- check C2NIM which will do most of the work

### src ###
This source folder contains the nim binding.

### Shared Library ###
The Project uses a shared library method to create binding, there were a few options to
create bindng, one of which include, compiling the required header or c files, the best
options truely depends on the developer and the needs of the project.

### Common Shared Library path ###
- /usr/local/lib

### Platform Issue ###
The development was made on two platforms
- Debian 8(jessie)
- Ubuntu 16.04

During development ubuntu failed to automatically load for us the shared library path
this made our problem complain.
```sh
    ./jerasure_01: error while loading shared libraries: libJerasure.so.2: cannot open shared object file: No such file or directory
```
the walk around was to
```sh
    export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH
```

As for debian  everything is okay it makes sharedlibrary available by default.

### Include directory ###
This include directory contains the emergency c header files needed by the project, incase
we find a problem with the shared library for jerasure will need to compile everything for
our self from the include directory.
