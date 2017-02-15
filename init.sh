#!/bin/bash
#  init.sh
#  
#  Copyright 2017 s8software <s8software@s8.dev.com>
#  2017-02-14 
#  Author: Wangolo Joel
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
    
    if [ "$(ls $SHARED_LIB_PATH | grep libJera.*.*so)" ]
    then
        echo "Required shared library exists ensure nim has access to it."
        for lib in $libraries
        do
            printf "$SHARED_LIB_PATH/$lib\n"
        done 
        echo
        echo "Now run the script with install command!"
        
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

if [ "$1" = "install" ]
then
    if [ $(which nim) > /dev/null ]
    then
        echo "Nim compiler found at $(which nim)"
    else
        echo "Unable to find nim compiler ensure you have installed it at /usr/bin/nim"
    fi
    
    # Directory to move our development files
    NIM_LIB_DIR="/usr/lib/nim"
    CMD="cp -rf $WORKING_DIR $NIM_LIB_DIR"
     
    if [ -d $NIM_LIB_DIR ]
    then
        echo "Copying Jerasure nim binding to directory $NIM_LIB_DIR"
        
        if [ $EUID -eq 0 ]
        then
            
            echo "Copying dev files $WORKING_DIR to $NIM_LIB_DIR"
            
            if [[ $WORKING_DIR == *"-master"* ]]
            then
                echo "You got from github"
                # Just create the jerasure folder in
                JDIR="$NIM_LIB_DIR/jerasure"
                
                create_dir="mkdir -p $JDIR"
                
                $create_dir
                
                CMD="cp -rf $WORKING_DIR/* $JDIR"
                echo "We are working on it"
                # Run the command
                $CMD
                
            else
                # Run the command 
                $CMD
            fi
            
        else
            echo "Your not running as root!"
        fi
        
    else
        echo "Directory $NIM_LIB_DIR not found have you installed nim?"
        echo ""
        sleep 2 # A little nap won't hurt
        
        if [ $EUID -eq 0 ]
        then
            echo "Give us nim path or of leave blank:"
            read nim_path
            y_n=""
            
            if [ -z "${nim_path// }"  ]
            then                
                echo "Creating directory $NIM_LIB_DIR"
                mkdir_cmd="mkdir -p $NIM_LIB_DIR"
                
                # Run the command to create directory
                $mkdir_cmd
                
                if [[ $WORKING_DIR == *"-master"* ]]
                then
                    echo "You got from github"
                    # Just create the jerasure folder in
                    JDIR="$NIM_LIB_DIR/jerasure"
                    
                    create_dir="mkdir -p $JDIR"
                    
                    # Create the directory for jerasure
                    $create_dir
                    
                    CMD="cp -rf $WORKING_DIR/* $JDIR"
                    echo "We are working on it Second hand!"
                    # Run the command
                    $CMD
                    
                else
                    # Run the command 
                    CP_CMD="cp -rf $WORKING_DIR $NIM_LIB_DIR"
                    
                    # Run the command to move files
                    echo "Created directory $LIB_NIM_DIR copying jerasure binding"
                    $CP_CMD
                    sleep 1 # Rest user eyes!
                    
                    if [ $? -eq 0 ]
                    then
                        echo "Successful"
                    else
                        echo "Unsuccessful command executed!"
                    fi
                fi
                
            else
                echo "If the binding fails with the path you have given!"
                echo "reinstall with the path pointing to /usr/lib/nim"
                
                if [[ $WORKING_DIR == *"-master"* ]]
                then
                    echo "You got from github"
                    # Just create the jerasure folder in
                    JDIR="$NIM_LIB_DIR/jerasure"
                    
                    create_dir="mkdir -p $JDIR"
                    
                    $create_dir
                    
                    CMD="cp -rf $WORKING_DIR/* $JDIR"
                    echo "We are working on it"
                    # Run the command
                    $CMD
                    
                else
                    # Run the command                 
                    CP_CMD="cp -rf $WORKING_DIR $nim_path"
                    
                    echo "Installing library to $nim_path"
                    $CP_CMD
                    
                    if [ $? -eq 0 ]
                    then
                        echo "Successful"
                    else
                        echo "Unsuccessful command executed!"
                    fi
                fi
            fi # End attempt to get user nim path
            
        else
            echo "Could not create the directory $LIB_NIM_DIR"
            echo "Your not root! the next action required root previledges!"
        fi
        
    fi
    
elif [ "$1" = "purge" ]
then
    NIM_LIB_DIR="/usr/lib/nim"

    package="jerasure"
    CMD="rm -rf  $NIM_LIB_DIR/$package"

    if [ -d $NIM_LIB_DIR ]
    then
        echo "Removing Jerasure nim binding from directory $NIM_LIB_DIR/$package"
        
        if [ $EUID -eq 0 ]
        then
            
            echo "Removing dev files to $NIM_LIB_DIR/$package"
            $CMD
        else
            echo "Your not running as root!"
        fi
        
    else
        echo "Directory $NIM_LIB_DIR not found have you installed nim?"
    fi
        
elif [ "$1" = "depends" ]
then
    if [ -d $JERASURE_DIR ]
    then
        echo -e "Looks like you have jerasure already installed. If there is any problem with jerasure.nim,"
        echo -e "Please try uninstalling libjerasure-dev and re-installing again!"
    else
        if [ "$LD_LIBRARY_PATH" = "" ]
        then
            printf "Missing Shared Library Enviroment variable Attempting to export shared library directory.\n\n"
            sleep 1
            export LD_LIBRARY_PATH="/usr/local/lib:$LD_LIBRARY_PATH"
        fi
        
        dependency_config
    fi

else
    echo $1
fi
