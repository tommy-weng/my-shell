#!/bin/bash

. ./my_shell.sh

targetCase=`cat ./package/case.txt`

case "$1" in
    "r")
        flashCase
        restBTS
        runCase
        ;;
    "c")
        flashCase
        runCase
        ;;
    "d")
        syncBin
        flashBts
        restBTS
        ;;
    *)
        syncBin
        flashBts
        restBTS
        runCase
        ;;
esac
