#!/bin/bash

if [[ $1 = "" || $2 = "" ]]; then
    echo "Usage: ./config_env.sh <user> <IP address>"
    exit
fi

echo "Start config local env..."
if [ ! -d  logs ]; then
    mkdir logs
fi

cd data

echo $1 $2 > config.dat

echo "Start config target env..."

host_name=$1@$2
awk -F '[ ]' '{print $1}' config.dat
awk -F '[ ]' '{print $2}' config.dat

ssh-copy-id $1@$2 > /dev/null 2>&1
ssh $host_name 'cd .ssh; sort authorized_keys | uniq > temp_keys; mv temp_keys authorized_keys'

ssh $host_name 'ls onTargetWorkspace > /dev/null 2>&1'
if [ $? -ne 0 ]; then
  scp -r onTargetWorkspace $host_name:~/
fi

ssh $host_name 'cd ~/onTargetWorkspace; bash config.sh'

echo "Config finished..."
#awk 'NR==2 {print}' config.dat