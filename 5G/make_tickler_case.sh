#!/bin/bash

if [ -n "$1" ]; then
    cd uplane && source L2-PS/setup.sh --target=asik-x86_64-ps_lfs-dynamic-linker-on-gcc9 && cd build_bbp/tickler && ninja -j $PARALLEL_BUILD_JOBS $1 && cd ../../../
else
    echo "Please input case name"
fi
