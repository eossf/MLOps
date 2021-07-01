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
plan="vc2-1c-2gb"
osid="362"
region="cdg"

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

# verify 
curl -s "https://api.vultr.com/v2/instances" -X GET -H "Authorization: Bearer ${VULTR_API_KEY}"
echo 

# create 6 nodes (3 masters + 3 workers)
# we need regions, plans, OS, private network, ssh key

# list region, get the best one, french cdg for my case
#curl -s "https://api.vultr.com/v2/regions" -X GET -H "Authorization: Bearer ${VULTR_API_KEY}"

# plans, for my case : vc2-1c-2gb
#curl -s "https://api.vultr.com/v2/plans" -X GET -H "Authorization: Bearer ${VULTR_API_KEY}"

# OS list, centos for K3s id=362
#curl -s "https://api.vultr.com/v2/os" \
#  -X GET \
#  -H "Authorization: Bearer ${VULTR_API_KEY}"

# private network, list
APN=`curl -s "https://api.vultr.com/v2/private-networks" -X GET -H "Authorization: Bearer ${VULTR_API_KEY}" | jq '.networks[].id' | tr -d '"'`

if [[ $APN == "" ]]; then 
    # create one private network
    APN=`curl -s "https://api.vultr.com/v2/private-networks" \
    -X POST \
    -H "Authorization: Bearer ${VULTR_API_KEY}" \
    -H "Content-Type: application/json" \
    --data '{
        "region" : "'$region'",
        "description" : "K3s Private Network",
        "v4_subnet" : "192.168.0.0",
        "v4_subnet_mask" : 16
    }' | jq '.network.id' | tr -d '"'`
fi

# create SSH key
#curl -s "https://api.vultr.com/v2/ssh-keys" \
#  -X POST \
#  -H "Authorization: Bearer ${VULTR_API_KEY}" \
#  -H "Content-Type: application/json" \
#  --data '{
#    "name" : "Example SSH Key",
#    "ssh_key" : "ssh-rsa AA... user@example.com"
#  }'

# get SSH key for accessing servers later
SSHKEY_ID=`curl -s "https://api.vultr.com/v2/ssh-keys"   -X GET   -H "Authorization: Bearer ${VULTR_API_KEY}" | jq '.ssh_keys[].id' | tr -d '"'`

# create masters and workers
for node in MASTER01 MASTER02 MASTER03 NODE01 NODE02 NODE03
do
  DATA='{ "region" : "'$region'",
  "plan" : "'$plan'",
  "label" : "'$node'",
  "hostname" : "'$node'",
  "os_id" : '$osid',
  "attach_private_network" : ["'$APN'"],
  "sshkey_id" : ["'$SSHKEY_ID'"]
  }'
  echo "Create node:"$node
  curl "https://api.vultr.com/v2/instances" -X POST -H "Authorization: Bearer ${VULTR_API_KEY}" -H "Content-Type: application/json" --data "$DATA"
  echo
done

echo "Wait provisionning finishes"
sleep 120


echo "set internal interface "
# get info back for ansible provisionning
NODES=`curl "https://api.vultr.com/v2/instances"   -X GET   -H "Authorization: Bearer ${VULTR_API_KEY}" | jq '.'`
NODE_LABEL=`echo $NODES | jq '.instances[].label' | tr -d '"'`
NODE_MAIN_IP=`echo $NODES | jq '.instances[].main_ip' | tr -d '"'`
NODE_INTERNAL_IP=`echo $NODES | jq '.instances[].internal_ip' | tr -d '"'`

HOSTNAME=()
i=0
for t in ${NODE_LABEL[@]}; do
  HOSTNAME[$i]=$t
  ((i=i+1))
done

PRIVATE=()
i=0
for t in ${NODE_INTERNAL_IP[@]}; do
  PRIVATE[$i]=$t
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
            if [[ ${HOSTNAME[$i]}  =~ "MASTER" || ${HOSTNAME[$i]}  =~ "NODE" ]]; then
              cp -f enp6s0.tmpl ifcfg-enp6s0
              echo ${HOSTNAME[$i]}" status is "$stat" and main ip="$ip
              echo "setup private interface "${PRIVATE[$i]}
              sed -i 's/#IPADDR/'${PRIVATE[$i]}'/g' ifcfg-enp6s0
              scp -i ~/.ssh/id_rsa -o "StrictHostKeyChecking=no" ifcfg-enp6s0 root@"$ip":/etc/sysconfig/network-scripts/ifcfg-enp6s0
              ssh -i ~/.ssh/id_rsa -o "StrictHostKeyChecking=no" root@"$ip" "nmcli con load /etc/sysconfig/network-scripts/ifcfg-enp6s0"
              ssh -i ~/.ssh/id_rsa -o "StrictHostKeyChecking=no" root@"$ip" "nmcli con up 'System enp6s0'"
            fi
        fi
    else
        stat='bad';
    fi

    ((i=i+1))
done