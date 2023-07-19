#!/bin/bash

iloID=test
iloPW=test1234

help()
{
    echo “Usage : $0 [options]
        -h : system health
        -c : cpu
        -m : memory
        -d : disk
        -p : power supply
        -f : fan
        -t : temperature
        -b : battery
        -a : all”
}

HPONCFG=hponcfg
CHECK_XML=/root/hw_check.xml
HW_CHECK_LOG=/root/hw_check_log
HW_CHECK_NOW=/root/hw_now

if [[ ! “$1” == “-”* ]]; then
    help
    exit 1
fi

cat << EOF > $CHECK_XML
<RIBCL VERSION=“2.0>
<LOGIN USER_LOGIN=“$iloID” PASSWORD=“$iloPW”>
<SERVER_INFO MODE=“read”>
<GET_EMBEDDED_HEALTH>
  <GET_ALL_HEALTH_STATUS/>
</GET_EMBEDDED_HEALTH>
</SERVER_INFO>
</LOGIN>
</RIBCL>
EOF

$HPONCFG -f $CHECK_XML > $HW_CKECK_LOG

BIOS_HW_FLAG=$(grep BIOS_HARDWARE $HW_CHECK_LOG | awk -F\” ‘{ print $2 }’)
CPU_FLAG=$(grep “PROCESSOR STATUS” $HW_CHECK_LOG | awk -F\” ‘{ print $2 }’)
MEM_FLAG=$(grep “MEMORY STATUS” $HW_CHECK_LOG | awk -F\” ‘{ print $2 }’)
DISK_FLAG=$(grep “STORAGE STATUS” $HW_CHECK_LOG | awk -F\” ‘{ print $2 }’)
POWER_FLAG=$(grep “POWER_SUPPLIES STATUS” $HW_CHECK_LOG | awk -F\” ‘{ print $2 }’)
FAN_FLAG=$(grep “FANS STATUS” $HW_CHECK_LOG | awk -F\” ‘{ print $2 }’)
TEMP_FLAG=$(grep “TEMPERATURE STATUS” $HW_CHECK_LOG | awk -F\” ‘{ print $2 }’)
BATTERY_FLAG=$(grep “BATTERY STATUS” $HW_CHECK_LOG | awk -F\” ‘{ print $2 }’)

while getopts hacmdpftb opt
do
    case $opt in
        h)
            HEALTH_CHECK=`grep -iv Network $HW_CHECK_LOG | grep -iv Redundant | egrep 
‘(Failed|Degraded)’`
            if [ ! -z “$HEALTH_CHECK” ]; then
                echo “HW_LED:NOK”
            else
                echo “HW_LED:OK”
            fi
        ;;
        a)
            echo BIOS_HW:$BIOS_HW_FLAG
            echo CPU:$CPU_FLAG
            echo MEM:$MEM_FLAG
            echo DISK:$DISK_FLAG
            echo POWER:$POWER_FLAG
            echo FAN:$FAN_FLAG
            echo TEMP:$TEMP_FLAG
            echo BATTERY:$BATTERY_FLAG
            ;;
        c) echo CPU:$CPU_FLAG;;
        m) echo MEM:$MEM_FLAG;;
        d) echo DISK:$DISK_FLAG;;
        p) echo POWER:$POWER_FLAG;;
        f) echo FAN:$FAN_FLAG;;
        t) echo TEMP:$TEMP_FLAG;;
        b) echo BATTERY:$BATTERY_FLAG;;
        *)
            help
            exit 1
            ;;
    esac
done
