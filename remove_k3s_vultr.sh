#!/bin/bash

VULTR_API_KEY=$1
if [[ $VULTR_API_KEY == "" ]] ; then
	echo "Please enter the VULTR_API_KEY parameter"
	exit;
fi

# get info back for ansible provisionning
NODE=`curl "https://api.vultr.com/v2/instances"   -X GET   -H "Authorization: Bearer ${VULTR_API_KEY}" | jq '.instances[].id' | tr -d '"'`
for node in $NODE
do
  echo "delete node: "$node
  curl "https://api.vultr.com/v2/instances/$node" -X DELETE -H "Authorization: Bearer ${VULTR_API_KEY}"
done