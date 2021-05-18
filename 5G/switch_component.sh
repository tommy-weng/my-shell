#!/bin/bash

FILE="/home/`whoami`/script/5G/config.sh"

component=`sed -n '4p' ${FILE} | awk -F '=' '{print $2}' | tr -dc 'A-Z0-9'`

if [ "${component}" == "L2LO" ]; then
    sed -i 's/COMPONENT="L2LO"/COMPONENT="L2PS"/g' ${FILE}
else
    sed -i 's/COMPONENT="L2PS"/COMPONENT="L2LO"/g' ${FILE}
fi

current_component=`sed -n '4p' ${FILE} | awk -F '=' '{print $2}' | tr -dc 'A-Z0-9'`
echo "Switch to component ${current_component}"
