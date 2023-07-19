#!/bin/bash

cd /root/HP_MONIT/Scripts/

for IpList in `cat /root/HP_MONIT/cray/cray_list|awk -F “|” ‘{print$2}’`
do
HOST=`cat /root/HP_MONIT/cray/cray_list|grep $IpList|awk -F “|” ‘{print$1}’`

PID=`curl —silent —insecure -k -u admin:hpinvent “https://$IpList/redfish/v1/System/” | ./jq-linux32 “.Members” | grep “odata.id” | cut -d “/” -f5 | cut -d ‘“’ -f1`

AllHEALTH=`curl —silent —insecure -k -u admin:hpinvent “https://$IpList/redfish/v1/System/$PID” | ./jq-linux32 “.Status.Health”`

if [[ $AllHealth != ‘“OK”’ ]]; then
    ProcHEALTH=`curl —silent —insecure -k -u admin:hpinvent “https://$IpList/redfish/v1/System/$PID” | ./jq-linux32 “.ProcessorSummary.Status.Health”`

    MemHEALTH=`curl —silent —insecure -k -u admin:hpinvent “https://$IpList/redfish/v1/System/$PID” | ./jq-linux32 “.MemorySummary.Status.Health”`

echo “$HOST Health:$AllHEALTH CPU:$ProcHEALTH MEM:$MemHEALTH” > /root/HP_MONIT/cray/res.log

cat /root/HP_MONIT/cray/res.log

fi

done
