#!/bin/bash

IP=0.0.0.0
ID=test
PASSWORD=test1234

for i in (1..10)
do

curl -o /dev/null -s -w %{time_total}\\n —silent —insecure -k -u $ID:$PASSWORD “https://$IP/redfish/v1/Systems/1/“ >> ./query_time_Systems.txt

done

awk ‘{sum+=1}END{print sum/NR}’ query_time_Systems.txt >> query_time_Systems.txt

date >> query_time_Systems.txt
