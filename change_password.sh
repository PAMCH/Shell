#!/bin/bash

hostname=$1
passwd=test1234

logfile=“result/change_root_passwd.res.$(date +’%Y%m%d’)”
ssh_timeout=60
ssh_cmd=“ssh -o connecttimeout=$ssh_timeout $hostname”

function usage() {
    echo “Usage. $0 [hostname]”
    exit 1
}

function prev() {
    if [ “$hostname” == “”]; then
        usage
    fi
}

function todo() {
    local buf=$($ssh_cmd “setenv LANG C; export LANG=C; echo ‘$passwd’ | passwd —stdin root; df -h / | tail -n 1” 2>&1)

    local chk=$(echo “$buf” | grep ‘successfully.’ | wc -l)

    if [ $chk -gt 0 ]; then
        echo “$hostname change passwd ok” >> $logfile
    else
        local errstr=“$(echo “$buf” | tail -n 1)”
        local disk_use=“$(echo “$buf” | grep ‘/dev/‘ | awk ‘{print $5}’)”
        echo “$hostname change passwd fail ($errstr / disk $disk_use Use)” >> $logfile
    fi
}


prev
todo
