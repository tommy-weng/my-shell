#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "$0"  )" && pwd  )"
. $SCRIPT_DIR/config.sh

if [ -n "$1" ]; then
    source uplane/L2-PS/setup.sh --target=asik-x86_64-ps_lfs-dynamic-linker-on-gcc10 && cd uplane/build/tickler && ninja -j $PARALLEL_BUILD_JOBS $1 && cd ../../../
else
    if [ "$COMPONENT" == "L2LO" ]; then
        cd uplane && source L2-PS/setup.sh --target=asik-x86_64-ps_lfs-dynamic-linker-on-gcc10 && buildscript/L2-LO/run sct_build --for-fuse-host && cd ../
    else
        cd uplane && source L2-PS/setup.sh --target=asik-x86_64-ps_lfs-dynamic-linker-on-gcc10 && buildscript/L2-PS/run sct_build --for-fuse-host
    fi
fi
