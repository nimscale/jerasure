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
yes="yes"
no="no"

y="y"
n="n"

JERASURE_DIR='/usr/local/include/jerasures'


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
        
        COMMAND="sudo apt-get install libjerasure-dev -y"
        echo "Do you want to install libjerasure-dev (yes/y. no/n)"
        
        read yes_no
        
        if [ $yes_no = $yes ]
        then
            # Script must run as root
            if [ $EUID -eq 0 ]
            then
                $COMMAND
            else
                echo "Your not running as root! Please input your password."
                read -s PASSWD
                
                APT_CMD="echo $PASSWD | sudo -S $COMMAND"
                
                eval $APT_CMD
            fi
            
        elif [ $yes_no = $no ]
        then
            exit 
        
        elif [ $yes_no = $n ]
        then
            exit 
            
        elif [ $yes_no = $y ]
        then
            # Script must run as root
            if [ $EUID -eq 0 ]
            then
                $COMMAND
            else
                echo "Your not running as root! Please input your password."
                read -s PASSWD
                
                APT_CMD="echo $PASSWD | sudo -S $COMMAND"
                
                eval $APT_CMD
            fi
        else
            exit 
        fi
            
    fi
}

if [ -d $JERASURE_DIR ]
then
    echo -e "Looks like you have jerasure already installed. If there is any problem with jerasure.nim,"
    echo -e "Please try uninstalling libjerasure-dev and re-installing again!"
else
    if [ "$LD_LIBRARY_PATH" = "" ]
    then
        printf "Missing Shared Library Enviroment variable Attempting to export sharedlibrary directory.\n\n"
        export LD_LIBRARY_PATH="/usr/local/lib:$LD_LIBRARY_PATH"
    fi
    
    dependency_config
fi
