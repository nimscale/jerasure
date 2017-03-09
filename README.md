# jerasure
nim bindings for https://github.com/tsuraan/Jerasure
- check C2NIM which will do most of the work
- 
### src ###
This source folder contains the converted c headers to nim.

### Shared Library ###
The Project uses a shared library method to create binding, there were a few options to
create bindng, one of which include, compiling the required header or c files, the best
options truely depends on the developer.

### Downloading and Building jerasure shared library
Follow the instruction here.
https://github.com/tsuraan/Jerasure
Download, compile and install the library
when your done installing you will have this;
```sh
     "/usr/local/lib/libJerasure.so"
    # NOTE will include version also
```
### Including shared path library in nim.cfg ###
During compilation the binding requires this libraries; so you may need to include
them in your nim.cfg where every it is.
```sh
    --passl: "/usr/local/lib/libJerasure.so"
    --passl: "/usr/local/lib/libgf_complete.so"
```
NOTE: Depending on where nim is installed, at times it will automatically do
the linking as we have included it already into development binding.
But if there is an error demanding those library then just include them in your
nim.cfg.

### Edit your nim.cfg to include  jerasure library search path ###
When you begin using our binding like;
```py
    import jerasure.src.jerasure
    import jerasure.src.galois
```
Nim compiler may complain about the absense of those import files;
in those instance, then you will need to include this line in your nim.cfg
module search path. 

```ssh
   $path="/usr/lib/nim"
```

```sh
    # NOTE: This search path is different from library search path
    # Here we want nim to search for it's own module import.
    # As shown above we want nim to search for shared library.
```
This is were nim will look for when importing our library

### No building header files needed ###
Because we are using shared library methods, we don't need to build c files.
this makes the project smaller in size. But we can make the project depend on both
header files and sharedlibrary when one of them is missing we can easily switch to available one.

### Common Shared Library path ###
- /usr/local/lib

### Platform Issue ###
The development was made on two platforms
- Debian 8(jessie)
- Ubuntu 16.04

During development ubuntu failed to automatically load for us the shared library path
this made our program complain.
```sh
    ./jerasure_01: error while loading shared libraries: libJerasure.so.2: cannot open shared object file: No such file or directory
```

the walk around was to
```sh
    export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH
```

As for debian looks like everything is okay it makes sharedlibrary available by default

### Dependencies ###
```sh
    sudo apt-get install libjerasure-dev
    
    # NOTE This is also is different from manauly compiling jerasure to build
    # shared library.
    # This command does not compile jerasure into shared libarary so don't 
    # depend on it, but install it.
```

Optionally the init.sh script can help configure dependencies.

#### Using the init.sh script to configure and test jerasure binding. ####
- Checking and installing dependencies required ( not nim )
```sh
./init.sh depends
```

- Installing  nim jerasure binding with init.sh
```sh
    # This will move the whole jerasure binding to "/usr/lib/nim"  or to "/usr/local" for global access.
    # by nim scripts that need binding.
    ./init.sh install 
    
    # NOTE /usr/lib/nim  and /usr/local
    # Script will install binding in /usr/lib/nim if that path already exists
    # if the path does not exists it will fall back to /usr/local
    
    # Recall above that you included $path="/usr/lib/nim" in your nim.cfg
    # module import search path
    # so when you run ./init install it will install the binding in "/usr/lib/nim" or in /usr/local.
    # So if the bindings are installed in $path="/usr/local" then edit your
    # nim.cfg and include $path="/usr/local"
    
    # Pay attention where the $./init.sh install installs the binding
    $/usr/lib/nim # If the path exists; else
    $/usr/local # as the fallback.
    
```
### Checking where the module are installed
If you want to know where the ./init.sh installed the binding
do this
```sh
    $ ./init.sh install 
    # It will check where the module is and return the path
    # get that path and include in your nim.cfg
```

- Unistalling or purging jerasure with init.sh
```sh
    # This will do the opposite of the install command, rm -rf /usr/lib/nim/jerasure
    ./init.sh purge
```

### How to use Jerasure nim binding in you project ###
After you have performed the installation step as shown above.
- Create a simple jtesting.nim
```py
    import jerasure.src.jerasure
    import jerasure.src.galois
    import jerasure.src.cauchy
    import jerasure.src.liberation
    import jerasure.src.reed_sol
    import jerasure.src.sharedlib # Not part of the standard binding
    import jerasure.src.templates # Not part of the standard binding
    import jerasure.src.gf_typedef # Not part of the standard binding
    import jerasure.src.timing
```
Pass the path were our module was installed to see where the module is installed re run the script with the install command
```sh
    # Try the following
    nim c jtesting.nim
    
    # If the above fails by complaing about missing modules
    # Then try the following.(Ensure that ./init.sh install installed the modules ini $path="/usr/lib/nim"
    
    nim c -p:/usr/lib/nim jtesting.nim
```
- Compile if there are no errors complaining about missing modules. Greate! we good to develop using this binding.

### Testing the binding examples ###
You will see a directory called nimexample. Let's test the binding.
```sh
    # Please note that /usr/local may change depending on your installation directory
    # You may need to note when installing the script it will show you where
    # the module is installed.
    nim c -p:/usr/local nimexample/jerasure_01.nim
    # The ouput will be inside the nimexample go in.
    ./jerasure_01 
    # You should see some output.
    
    nim c -p:/usr/local nimexample/galois_01.nim
    ./galois_01 # If no output we are good, if there are out put assertion failure.
    
    # You can do the same with other examples inside.
```

### Testing the encoder.nim and decoder.nim ###
```sh
    $ nim c nimexample/encoder.nim
    $ nim c nimexample/decoder.nim
    
    # Watch for sucessful compilation.
    ./encoder  /path/for/file/to/encoding 3  2 reed_sol_van 8 0 0
    
    ./decoder /path/for/file/to/encoding
    # NOTE you may need to follow the examples in the C based.
    
    # A directory call Coding will be created
```

NOTE: When running ./init.sh you will see where our module is installed.
so you may use that path when compiling as demostrated.
TODO: Just for kicks we could have made our examples take commandline input like:
```sh
    ./jerasure_01 2 4 12 # INFO r=2 c=3 w=14
    # The above won't work with our examples because we didn't make it take commandline option.
```
### Possible Bugs ###
```py
    # If this binding of timing raises and error let me know
    # for for the whole testing on Ubuntu had no error seen.
    # but for testing in Debian there was an error.
    import jerasure.src.timing 
```
### Enjoy! ###
