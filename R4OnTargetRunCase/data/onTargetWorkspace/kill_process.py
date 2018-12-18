#! /usr/bin/python
# -*- coding: utf-8 -*-

import os
import sys
import signal

def kill(pid):
    try:
        result = os.kill(pid, signal.SIGKILL)
        if result == None:
            print 'Kill:%s.' % (pid)
    except OSError, e:
        print 'Kill:%s, failed!!! ' % (pid)

def excute():
    content = os.popen('ps -ef | grep -E "nc -ulp 51000|LteMacClient" | grep -v "grep"').read()
    vector = content.split("\n")
    for line in vector:
        if line == '':
           continue
        line = ' '.join(line.split())
        print line
        process = line.split(' ')
        kill(int(process[1]))

if __name__ == '__main__':
    excute()
    