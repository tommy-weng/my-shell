#!/bin/bash

PROJECT_DIR=`pwd` 

commit="HEAD"
while :; do
    echo $commit
    if [ -n "`git branch -r --contains $commit`" ]; then
        break
    fi
    commit=${commit}"^"
done

echo $commit

shalId=`git log $commit -1 | grep commit | awk -F ' ' '{print$2}'`
echo $shalId
if [ "update" == "$1" ]; then
    ssh sweng@hzling39.china.nsn-net.net "cd $PROJECT_DIR; git fetch mirror; git checkout -f -B temp $shalId; make $1"
else 
    git diff $shalId > modified.patch
    scp modified.patch sweng@hzling39.china.nsn-net.net:$PROJECT_DIR
    ssh sweng@hzling39.china.nsn-net.net "cd $PROJECT_DIR; git checkout -f -B temp $shalId; git status | grep -E '\.hpp|\.cpp|\.c|\.h' | xargs rm; patch -p1 <modified.patch; rm modified.patch; make $1"
    #rm modified.patch
fi
    
