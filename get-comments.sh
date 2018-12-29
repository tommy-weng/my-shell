#!/bin/bash

start_time=$1
end_time=$2

echo $start_time > start-time.txt
echo $end_time > end-time.txt
expect login.expect
rm start-time.txt end-time.txt


