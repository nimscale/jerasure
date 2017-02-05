import galois


var tmp: cint = 12

#echo galois_init_default_field(tmp)

#echo hostCPU

var arc_x86: bool = false
var arc_x64: bool = false
var arc_xUnknown: bool = false
var arc_x86_x64: bool = false

if hostCPU == "amd64":
  arc_x64 = true

elif hostCPU == "i386":
  arc_x86 = true
else:
  arc_xUnknown = true

if arc_x64 or arc_x86:
   const
      arc_x86_64* =true

else:
   echo "There is no hope for the arch to work@"

when defined(arc_x86_64):
    echo "it's a welcome!"
   
