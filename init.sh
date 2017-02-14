#!/bin/bash
#  init.sh
#  
#  Copyright 2017 s8software <s8software@s8.dev.com>
#  2017-02-14 
#
# This is an initialization script
# during the installation helping us determine
# enviroment variables needed for our shared library

WORKING_DIR=$(pwd)
SHARED_LIB_PATH="/usr/local/lib"

if [ "$LD_LIBRARY_PATH" = "" ]
then
    printf "Missing Shared Library Enviroment variable Attempting to export sharedlibrary directory.\n\n"
    export LD_LIBRARY_PATH="/usr/local/lib:$LD_LIBRARY_PATH"
    
else
    printf "Found shared library path at $LD_LIBRARY_PATH\n"
fi


function bash_instruction(){
    echo ""
    echo "The project depends on shared libJerasure.so.2 or higher."
    echo "If this library does not exists then there is an option."
    echo "of downloading the required c dependency files that is,"
    echo "<gf_complete.h> and <jerasure.h> and then adding them,"
    echo "in the include directory for them to be compiled during, project build."
}


# Begin dependency configurations
function dependency_config(){
    libraries=$(ls $SHARED_LIB_PATH | grep libJera.*.*so)
    
    if [ "$(ls $SHARED_LIB_PATH | grep wangolo.*.*so)" ]
    then
        echo "Required shared library exists ensure nim has access to it."
        for lib in $libraries
        do
            printf "$SHARED_LIB_PATH/$lib\n"
        done 
        
    else
        echo "No jerasure shared library found."
        
        # Get user input for download
        echo "We can download the c header files required by the project, instead of using shared library."
        echo "Would you like us to download required library for you (yes/no)?"
        
        read yes_no
    fi
    
}

dependency_config
