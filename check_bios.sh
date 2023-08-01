#!/bin/bash

CONREP=$(which conrep)  # 'conrep' 명령어의 경로를 'CONREP' 변수에 저장
RESULT=/root/conrep_$(date +'%Y%m%d').log  # 현재 날짜를 이용하여 로그 파일 경로를 생성

# 'conrep' 패키지의 유무와 실행 가능 여부를 확인
function check_conrep() {
    if [ "$CONREP" == "" ]; then
        echo "ERROR:/> Requires conrep package"
        exit  # 'conrep'가 PATH에 없으면 스크립트를 오류로 종료
    fi
    if [ ! -f "$CONREP" ]; then
        echo "ERROR:/> Requires conrep package"
        exit  # 'conrep'가 파일이 아니면 스크립트를 오류로 종료.
    fi
}

# 시스템이 지원되는지 (Gen10보다 낮은지) 확인
function chk_system() {
    check_conrep  # 'check_conrep' 함수를 호출

    # 'dmidecode'를 이용하여 시스템 제품 정보를 추출, 'Gen10'을 포함하는지 확인
    local buf=$(dmidecode -t system | grep -i Product | awk '{print $4" "$5}')
    local chk=$(echo "$buf" | grep -i 'Gen10' | wc -l)

    if [ $chk -gt 0 ]; then
        echo "ERROR:/> Not supported. $buf (target: Less than Gen10)"
        exit  # 시스템이 Gen10 이상이면 스크립트를 오류로 종료
    fi
}

function post()
{
    return
}

# 'conrep' 설정을 수행하는 함수
function core() {
    # '-s' 옵션을 사용하여 'conrep'를 실행하고 지정된 로그 파일에 설정을 저장
    local buf=$(conrep -s -f $RESULT 2>&1)

    # 'conrep' 출력으로부터 반환 코드를 추출, 성공인지 확인 (반환 코드 0).
    local return_code=$(echo "$buf" | grep -i 'Conrep Return Code: ' | cut -d ':' -f 2)
    local chk=$(echo "$buf" | grep -i 'Conrep Return Code: 0' | wc -l)

    if [ $chk -eq 0 ]; then
        echo "ERROR:/> Failed conrep (Return Code: $return_code)"
        return  # 'conrep'가 0이 아닌 코드를 반환하면 'core' 함수를 종료
    fi

    # 'conrep' 로그에서 특정 섹션을 추출, 처리하는 부분
    local datas=$(cat $RESULT | egrep 'Section name="Thermal_Shutdown"|Section name="CPU_Virtualization"|Section name="Hyperthreading"|Section name="Intel_Hyperthreading"')
    local count=$(echo "$datas" | grep Section | wc -l)
    local idx=1
    local keys=$(echo "$datas" | cut -d '"' -f 2)
    local value=$(echo "$datas" | sed -e 's/<Line0>//g' | cut -d '>' -f 2 | cut -d '<' -f 1)

    while [ $idx -le $count ]; do
        local key=$(echo "$keys" | head -n $idx | tail -n 1)
        local value=$(echo "$values" | head -n $idx | tail -n 1)
        ((idx += 1))
    done
}

# 'chk_system' 함수를 호출하여 시스템 호환성을 확인
chk_system

# 'core' 함수를 호출하여 'conrep' 설정을 수행
core

post

exit
