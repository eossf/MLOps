# set your key
export VULTR_API_KEY="ZZZZZYYYYYY"

# verify 
 curl -s "https://api.vultr.com/v2/instances" -X GET -H "Authorization: Bearer ${VULTR_API_KEY}"

# create 6 nodes (3 masters + 3 workers)
# we need regions, plans, OS, private network, ssh key

# list region, get the best one, french cdg for my case
curl -s "https://api.vultr.com/v2/regions" \
  -X GET \
  -H "Authorization: Bearer ${VULTR_API_KEY}"

# plans, for my case : vc2-1c-2gb
curl -s "https://api.vultr.com/v2/plans" -X GET -H "Authorization: Bearer ${VULTR_API_KEY}"

# OS list, centos for K3s id=362
curl -s "https://api.vultr.com/v2/os" \
  -X GET \
  -H "Authorization: Bearer ${VULTR_API_KEY}"

# private network, list
APN=`curl -s "https://api.vultr.com/v2/private-networks" \
  -X GET \
  -H "Authorization: Bearer ${VULTR_API_KEY}" | jq '.networks[].id' | tr -d '"'`

if [[ $APN -eq "" ]]; then 
    # create one private network
    APN=`curl -s "https://api.vultr.com/v2/private-networks" \
    -X POST \
    -H "Authorization: Bearer ${VULTR_API_KEY}" \
    -H "Content-Type: application/json" \
    --data '{
        "region" : "cdg",
        "description" : "K3s Private Network",
        "v4_subnet" : "10.0.0.0",
        "v4_subnet_mask" : 8
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
for node in master-1 master-2 master-3 worker-1 worker-2 worker-3
do
  DATA='{ "region" : "cdg",
  "plan" : "vc2-1c-2gb",
  "label" : "'$node'",
  "hostname" : "'$node'",
  "os_id" : 362,
  "attach_private_network" : ["'$APN'"],
  "sshkey_id" : ["'$SSHKEY_ID'"]
  }'
  curl "https://api.vultr.com/v2/instances" \
  -X POST \
  -H "Authorization: Bearer ${VULTR_API_KEY}" \
  -H "Content-Type: application/json" \
  --data "$DATA"
done
