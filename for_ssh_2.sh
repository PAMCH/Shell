#!/bin/sh

CMD=$(pwd)
logfile=$CMD/for_ssh_2.log
command=$1

> $logfile

if [ $2 ]; then
    list=$2
else
    list=$CMD/worklist.txt
fi

for i in `grep -v ^# $list`
do
    result=$(/usr/bin/ssh -o connectTimeout=4 $i $command)
    echo “$i:$result”
    echo “$i:$result” >> $logfile
done
