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

# get info back for ansible provisionning
NODE=`curl "https://api.vultr.com/v2/instances"   -X GET   -H "Authorization: Bearer ${VULTR_API_KEY}" | jq '.instances[].id' | tr -d '"'`
for node in $NODE
do
  echo "delete node: "$node
  curl "https://api.vultr.com/v2/instances/$node" -X DELETE -H "Authorization: Bearer ${VULTR_API_KEY}"
done