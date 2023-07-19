#!/bin/bash

svr_list=($(cat $1))

for svr in “${svr_list[@]}”
do
echo “——- ${svr} ——-“
    ssh ${svr} $2
done
