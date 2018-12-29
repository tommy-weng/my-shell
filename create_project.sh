#!/bin/bash

git clone -o mirror ssh://sweng@hztddgit.china.nsn-net.net:29418/tddps .
git config --local --add remote.mirror.fetch +refs/tags/*:refs/tags/*
curl -o .git/hooks/commit-msg http://hztddgit.china.nsn-net.net/gerrit/tools/hooks/commit-msg
chmod u+x ./.git/hooks/commit-msg
echo "* -text"> .git/info/attributes
