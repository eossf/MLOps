#!/bin/bash

tmpapi="$1"
if [[ $tmpapi == "" ]] ; then
	tmpapi=`env | grep "VULTR_API_KEY" | cut -d"=" -f2`
  if [[ $tmpapi == "" ]] ; then
    echo "Please enter the VULTR_API_KEY parameter or exported env var"
    exit;
  fi
fi

VULTR_API_KEY=$tmpapi

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
#NODES=`curl "https://api.vultr.com/v2/instances"   -X GET   -H "Authorization: Bearer ${VULTR_API_KEY}" | jq '.'`
#NODE_LABEL=`echo $NODES | jq '.instances[].label'`
#NODE_MAIN_IP=`echo $NODES | jq '.instances[].main_ip' | tr -d '"'`
#NODE_INTERNAL_IP=`echo $NODES | jq '.instances[].internal_ip' | tr -d '"'`

##
NODE_MAIN_IP="1.0.0.0 2.0.0.0 3.0.0.0 4.0.0.0 5.0.0.0 6.0.0.0 7.0.0.0"
NODE_LABEL="BOOTSTRAP MASTER01 MASTER02 MASTER03 WORKER01 WORKER02 WORKER03"
##

for ip in $NODE_MAIN_IP
do
    if valid_ip $ip; then 
        if [[ $ip == "0.0.0.0" ]]; then
            stat='bad'
        else
            stat='good'
            sed -i 's/#/REPLACEMENT/g' 
            printf "Configuration in inventory for %-20s: %s\n" "$ip" " done"
        fi
    else
        stat='bad';
    fi
    printf "%-20s: %s\n" "$ip" " $stat"
    echo
done

for t in ${NODE_LABEL[@]}; do
  echo $t
done