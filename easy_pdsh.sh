#!/bin/sh

CMD=$(pwd)
timestamp=$(date +'%F %T')
logfile=$CMD/easy_pdsh.log
command=“$1”
> $logfile

if [ $2 ]; then
    list=$2
else
    list=&CMD/worklist.txt
fi

com=$(/usr/bin/pdsh -t 20 -u 200 -w ^$list “$command” 2> com >&2)
result=$(cat com)
echo “$result”
echo “$result” >> $logfile
