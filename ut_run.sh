#!/bin/bash


cd ./lteDo/exec/nativelinux/debug
var=$1
if [ -n "$var" ];then
  if [ "gdb" == "$var" ]; then
    gdb MacPsTdd_tests
  else
    echo "Plesae input correct pramater, eg. gdb"
  fi
else 
  ./MacPsTdd_tests
fi
