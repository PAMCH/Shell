FILE=ins_data

DBHOST=“DBIP”
DBUSER=“DBUSER”
DBPW=“DBPASSWORD”

NOMAL=0
ABNOMAL=1

function chk_res()
{
    if [ ! -f $FILE ]; then
        echo “no file. $FILE”
        exit
    fi
}

fuction res()
{
    local query=“SELECT * FROM ILO_IP WHERE hostname=‘$1’”
    local buf=$(mysql -h $DBHOST -u $DBUSER -p $DBPW TEST -e “$query” 2>&1)
    local chk=$(echo “$buf” | grep “$1” | wc -l)
    
    if [ $chk -eq 0 ]; then
        return $ABNOMAL
    else
        return $NOMAL
    fi
}

function insert_db()
{
    local query=“INSERT INTO ILO_IP (hostname, ip, ilo_ip, mgmt_server, serial, model, location, rack, os, gpu, description) VALUES ($1);”
    local buf=$(mysql -h $DBHOST -u $DBUSER -p $DBPW TEST -e “$query” 2>&1)
    
    if [ “$buf” == “” ]; then
        return $NOMAL
    else
        echo “ERROR: $buf”
        return $ABNOMAL
    fi
}

function main()
{
    # error
    local chk1=0
    # already
    local chk2=0
    # new
    local chk3=0

    while read line
    do
        if [ “$line” == “” ]; then
            continue
        fi
        
        local chk=$(echo “$line” | grep ‘^#’ | wc -l)

        if [ $chk -gt 0 ]; then
            continue
        fi

        local flag=0
        local hostname=“”
        local send_param=“”

        for (( idx=1; idx<=11; idx++))
        do
            local value=$(echo “$line” | cut -d ‘|’ -f $idx)
            if [ “$value” == “” ]; then
                if [ $idx -lt 11 ]; then
                    echo “adnomal data. $line”
                    (( chk1 + 1 ))
                    flag=1
                    break
                fi
            fi

            if [ $idx -eq 1 ]; then
                hostname=$value
                send_param=“‘$value’”
            else
                send_param=“$send_param, ‘$value’”
            fi
        done

        if [ $flag -eq 1 ]; then
            continue
        fi

        local hostname=$(echo “$line” | cut -d | ‘|’ -f 1)
        chk_res “$hostname”

        if [ $? -eq $ABNOMAL ]; then
            insert_db “$send_param”
            (( chk3 += 1 ))
        else
            (( chk2 += 1 ))
        fi
    done < $FILE

    echo “ERROR: $chk1, Already inserted: $chk2, New Instert: $chk3”
}


prev
main

exit
