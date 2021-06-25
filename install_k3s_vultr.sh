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
for node in BOOTSTRAP MASTER01 MASTER02 MASTER03 WORKER01 WORKER02 WORKER03
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
  #curl "https://api.vultr.com/v2/instances" -X POST -H "Authorization: Bearer ${VULTR_API_KEY}" -H "Content-Type: application/json" --data "$DATA"
  echo
done

echo
