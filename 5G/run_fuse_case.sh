#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "$0"  )" && pwd  )"
. $SCRIPT_DIR/config.sh

if [ "$COMPONENT" == "L2PS" ]; then
    COMPONENT_FLAG="--l2ps"
else
    COMPONENT_FLAG="--l2lo"
fi

if [ "$DBGLOG" == "on" ]; then
    DBG_FLAG="-d"
fi

if [ -n "$1" ]; then
    if [ -n "$2" ]; then
        cd uplane && sct/run_on_asik/execute_one_sct_host.sh $COMPONENT_FLAG $DBG_FLAG --test-type fuse --test $1 --run_ids $2
    else
        cd uplane && sct/run_on_asik/execute_one_sct_host.sh $COMPONENT_FLAG $DBG_FLAG --test-type fuse --test $1
    fi
else
    echo "Please input case name"
fi
