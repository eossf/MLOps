#!/bin/bash

tmpapi="$1"
if [[ $tmpapi == "" ]] ; then
	tmpapi=`env | grep "VULTR_API_KEY" | cut -d"=" -f2`
  if [[ $tmpapi == "" ]] ; then
    echo "Please enter the VULTR_API_KEY parameter or exported env var"
    exit;
  fi
fi

cp -f inventory-k3s.yml inventory.yml

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
NODES=`curl "https://api.vultr.com/v2/instances"   -X GET   -H "Authorization: Bearer ${VULTR_API_KEY}" | jq '.'`
NODE_LABEL=`echo $NODES | jq '.instances[].label' | tr -d '"'`
NODE_MAIN_IP=`echo $NODES | jq '.instances[].main_ip' | tr -d '"'`
NODE_INTERNAL_IP=`echo $NODES | jq '.instances[].internal_ip' | tr -d '"'`

echo $NODE_MAIN_IP
echo $NODE_LABEL    

#NODE_MAIN_IP="95.179.217.210 95.179.222.25 45.63.114.46 217.69.2.107 108.61.176.206 104.238.191.60 95.179.217.140"
#NODE_LABEL="BOOTSTRAP MASTER01 MASTER02 MASTER03 WORKER01 WORKER02 WORKER03"

HOSTNAME=()
i=0
for t in ${NODE_LABEL[@]}; do
  HOSTNAME[$i]=$t
  ((i=i+1))
done

i=0
for ip in $NODE_MAIN_IP
do
    if valid_ip $ip; then 
        if [[ $ip == "0.0.0.0" ]]; then
            stat='bad'
        else
            stat='good'
            sed -i 's/#'${HOSTNAME[$i]}_MAIN_IP'/"'$ip'"/g' inventory.yml
            sed -i 's/#'${HOSTNAME[$i]}_HOSTNAME'/'${HOSTNAME[$i]}'/g' inventory.yml
            printf "%-20s: %s\n" "$ip" " done"
        fi
    else
        stat='bad';
    fi
    printf "%-20s: %s\n" "$ip" " $stat"
    echo
    ((i=i+1))
done