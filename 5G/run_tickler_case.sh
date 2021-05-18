#!/bin/bash

if [ -n "$1" ]; then
    ./uplane/sct/run_on_asik/execute_one_sct_host.sh --l2ps --test $1
else
    echo "Please input case name"
fi
