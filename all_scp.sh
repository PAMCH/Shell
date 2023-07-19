#!/bin/bash

CMD=$(pwd)
checklog=$CMD/checkall.log
logfile=$CMD/all_scp.log
> $checklog
> $logfile

function help() {
    echo “Usage : $0 [file][path(ex:/root)][list]”
}

if [ $1 ]; then
    file=$1
else
    help
    exit
fi

if [ $2 ]; then
    path=$2
else
    help
    exit
fi

if [ $3 ]; then
    list=$3
else
    help
    exit
fi

function copyall
{
    for i in `grep -v ^# $list`
    do
        `scp -r $file $i:$path`
    done
}

function checkall
{
    for i in `grep -v ^# $list`
    do
        com=$(/usr/bin/ssh -o ConnectTimeout=4 $i ls -l $path/$file)
        result=$com
        echo “$i:$result”
        echo “$i:$result” >> $checklog
    done
}

function report
{
    echo “—————report————“
    for i in `grep -v ^# $list`
    do
        com=$(grep -w $path/$file $checklog | grep $i | wc -l )
        if [ $com -ge 1 ]; then
            echo $i:OK
            echo $i:OK >> $logfile
        else
            echo $i:NOK
            echo $i:NOK >> $logfile
        fi
    done
}


copyall
checkall
report
