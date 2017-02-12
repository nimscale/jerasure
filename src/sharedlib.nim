
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
#  MA 02110-1301, USA.
#

# sharedlib.nim
# This file contains paths to linux shared libraries
# that are required by jerasure.h
import os, osproc, strutils

const
  SHARED_LIB_PATH="/usr/local/lib"
  HEADER_PATH="/usr/local/include"

proc get_jerasure_sharedlib(lib_path: string): string =
    # Get's the jerasure shared library paths.
    # @param: lib_path the directory path of the shared libarry.
    # @return: a string of the path we have got.

    for dir_type, path in walkDir(lib_path):
        if path.endsWith("libJerasure.so"):
            return "{link:" & path & "}"
        elif path.endsWith("libJerasure.so.2"):
            return "{link:" & path & "}"

proc get_gfcomplete_sharedlib(lib_path: string): string =
    # Given the path containing our gf_complete shared library we
    # return the available shared library for use
    # @param: lib_path the directory path of the shared libarry.
    # @return: a string of the path we have got.
    for dir_type, path in walkDir(lib_path):
        if path.endsWith("libgf_complete.so"):
            return path
        elif path.endsWith("libgf_complete.so.1"):
            return path

proc get_jerasure_header_files(lib_path: string, header_f:string): string =
    # Searching for a given header file on a given directory
    # and returns it
    # @param: header_f Corresponds to the header file we are searching for.
    for is_dir, header_file in walkDir(lib_path):
        if header_file.endsWith(header_f):
           return header_file

        # Recursion should do the trick here
        # but had to avoid it.
        elif dirExists(header_file):
            for iss_dir, h_file in walkDir(header_file):
                if h_file.endsWith(header_f):
                    return h_file

when isMainModule:
    echo get_jerasure_sharedlib(SHARED_LIB_PATH)
    echo get_gfcomplete_sharedlib(SHARED_LIB_PATH)
    echo get_jerasure_header_files(HEADER_PATH, "galois.h")
