#!/bin/bash

##############################################################################
#
#    file                 : robotgen
#    created              : Mon Jul 29 21:01:37 CEST 2002
#    copyright            : (C) 2002 by Eric Espié                        
#    email                : Eric.Espie@torcs.org   
#    version              : $Id: robotgen,v 1.4.2.1 2013/01/12 14:36:45 berniw Exp $                                  
#
##############################################################################
#
#   This program is free software; you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation; either version 2 of the License, or
#   (at your option) any later version.
#
##############################################################################


function usage() {
    echo "usage: compile_driver -i <input>"
    exit 1
}

while [ $# -ne 0 ]
do
    case "$1" in
    "-i")
	INPUT=$2
    ;;
    esac
    shift
done

if [ -z "$INPUT" ]
then
    usage
fi
ROOT=`pwd`
COMPILER='./compiler'
DRIVER='./driver/enseirbot'

if [ ! -f "$COMPILER/bin/parse" ]
then
    echo  "Parser Compilation..."  
    cd $COMPILER
    pwd
    make
    cd $ROOT
fi
if [ ! -d "$DRIVER" ]
then
    echo "Driver directory must exist"
    exit 2
fi

echo "Parsing $INPUT..."
$COMPILER/bin/parse $INPUT $DRIVER/drive.ll 
if [ $? -ne 0 ]
then 
    echo -e "FAILED"
    exit 2
fi

echo -e "SUCCEEDED"
cd $DRIVER
if [ -z $TORCS_BASE ] || [ -z $MAKE_DEFAULT ]
then
    echo  "" 
    echo "export TORCS_BASE to your Torcs installation directory"
    echo "export MAKE_DEFAULT to TORCS_BASE/Make-default.mk"
    exit 2
fi
make && make install && echo "You can now run torcs and select enseirbot player. Enjoy"
cd -

