#!/bin/bash

VULTR_API_KEY=$1
if [[ $VULTR_API_KEY == "" ]] ; then
	echo "Please enter the VULTR_API_KEY parameter"
	exit;
fi

function valid_ip()
{
    local  ip=$1
    local  stat=1
    if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        OIFS=$IFS
        IFS='.'
        ip=($ip)
        IFS=$OIFS
        [[ ${ip[0]} -le 255 && ${ip[1]} -le 255 && ${ip[2]} -le 255 && ${ip[3]} -le 255 ]]
        stat=$?
    fi
    return $stat
}


# get info back for ansible provisionning
NODE=`curl "https://api.vultr.com/v2/instances"   -X GET   -H "Authorization: Bearer ${VULTR_API_KEY}" | jq '.instances[].main_ip' | tr -d '"'`
for ip in $NODE
do
    if valid_ip $ip; then 
        if [[ $ip == "0.0.0.0" ]]; then
            stat='bad'
        else
            stat='good'
        fi
    else
        stat='bad';
    fi
    printf "%-20s: %s\n" "$ip" "$stat"
done
