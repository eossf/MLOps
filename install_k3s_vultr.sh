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
    if [[ $NODE_MAIN_IP =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        OIFS=$IFS
        IFS='.'
        ip=($NODE_MAIN_IP)
        IFS=$OIFS
        [[ ${ip[0]} -le 255 && ${ip[1]} -le 255 && ${ip[2]} -le 255 && ${ip[3]} -le 255 ]]
        stat=$?
    fi
    return $stat
}

echo "verify connection to vultr" 
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

echo "Get private network list"
APN=`curl -s "https://api.vultr.com/v2/private-networks" -X GET -H "Authorization: Bearer ${VULTR_API_KEY}" | jq '.networks[].id' | tr -d '"'`

if [[ $APN == "" ]]; then 
    echo "Create one private network"
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

echo "Get SSH key for accessing servers"
SSHKEY_ID=`curl -s "https://api.vultr.com/v2/ssh-keys"   -X GET   -H "Authorization: Bearer ${VULTR_API_KEY}" | jq '.ssh_keys[].id' | tr -d '"'`

echo "Create masters and workers"
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

echo "Wait provisionning finishes ..."
sleep 120
echo

echo "Set internal interface "
echo "  get info back for ansible provisionning"
NODES=`curl "https://api.vultr.com/v2/instances" -X GET -H "Authorization: Bearer ${VULTR_API_KEY}" | jq '.'`
NODES_COUNT=`echo $NODES | jq '.instances' | grep -i '"id"' | tr -d "," | cut -d ":" -f2 | tr -d " " | tr -d '"'`
for t in ${NODES_COUNT[@]}; do
  NODE=`curl "https://api.vultr.com/v2/instances/${t}" -X GET -H "Authorization: Bearer ${VULTR_API_KEY}" | jq '.'`
  NODE_LABEL=`echo $NODE | jq '.instance.label' | tr -d '"'`
  if [[ $NODE_LABEL =~ "MASTER" || $NODE_LABEL =~ "NODE" ]]; then
    NODE_INTERNAL_IP=`echo $NODE | jq '.instance.internal_ip' | tr -d '"'`
    NODE_MAIN_IP=`echo $NODE | jq '.instance.main_ip' | tr -d '"'`
    ssh -i ~/.ssh/id_rsa -o "StrictHostKeyChecking=no" root@"$NODE_MAIN_IP" "nmcli | grep 'disconnected' | cut -d':' -f1 > /tmp/ITF"
    scp -i ~/.ssh/id_rsa -o "StrictHostKeyChecking=no" root@"$NODE_MAIN_IP":/tmp/ITF /tmp/ITF
    ITF=`cat /tmp/ITF`
    rm /tmp/ITF
    echo "Capture itf name :"$ITF
    cp -f ifcfg.tmpl ifcfg-$ITF
    echo ${NODE_LABEL}" ip="$NODE_MAIN_IP" setup private interface "${NODE_INTERNAL_IP}
    sed -i 's/#IPV4#/'${NODE_INTERNAL_IP}'/g' ifcfg-$ITF
    sed -i 's/#ITF#/'$ITF'/g' ifcfg-$ITF
    scp -i ~/.ssh/id_rsa -o "StrictHostKeyChecking=no" ./ifcfg-$ITF root@"$NODE_MAIN_IP":/etc/sysconfig/network-scripts/ifcfg-$ITF
    ssh -i ~/.ssh/id_rsa -o "StrictHostKeyChecking=no" root@"$NODE_MAIN_IP" "nmcli con load /etc/sysconfig/network-scripts/ifcfg-"$ITF
    ssh -i ~/.ssh/id_rsa -o "StrictHostKeyChecking=no" root@"$NODE_MAIN_IP" "nmcli con up 'System "$ITF"'"
  fi
done
