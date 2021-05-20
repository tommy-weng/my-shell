#!/bin/bash

FILE="/home/`whoami`/script/5G/config.sh"

switch_component()
{
    component=`sed -n '4p' ${FILE} | awk -F'=' '{print $2}' | tr -dc 'A-Z0-9'`

    if [ "${component}" == "L2LO" ]; then
        sed -i 's/COMPONENT="L2LO"/COMPONENT="L2PS"/g' ${FILE}
    else
        sed -i 's/COMPONENT="L2PS"/COMPONENT="L2LO"/g' ${FILE}
    fi

    current_component=`sed -n '4p' ${FILE} | awk -F'=' '{print $2}' | tr -dc 'A-Z0-9'`
    echo "Switch to component ${current_component}"
}

switch_dbglog()
{
    flag=`sed -n '7p' ${FILE} | awk -F'=' '{print $2}' | tr -dc 'a-z'`

    if [ "${flag}" == "off" ]; then
        sed -i 's/DBGLOG=off/DBGLOG=on/g' ${FILE}
    else
        sed -i 's/DBGLOG=on/DBGLOG=off/g' ${FILE}
    fi

    current_flag=`sed -n '7p' ${FILE} | awk -F'=' '{print $2}' | tr -dc 'a-z'`
    echo "Switch DBG log to ${current_flag}"
}

show()
{
    gawk 'NR == 4 || NR == 7' ${FILE}  # gawk: gnu awk
    #sed -n '4p;7p' ${FILE}
}

show_prompt()
{
    echo "Use option:"
    echo "    component"
    echo "    dbg"
    echo "    show"
}

case "$1" in
    "component")
        switch_component
        ;;
    "dbg")
        switch_dbglog
        ;;
    "show")
        show
        ;;
    *)
        show_prompt
        ;;
esac