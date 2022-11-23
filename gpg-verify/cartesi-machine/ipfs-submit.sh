#!/bin/bash

if [ ! $1 ]; then
  echo "1 parameter required: file to submit"
  exit 1
fi

output=$(curl -X POST -s -F file=@$1 "http://localhost:5008/api/v0/add?pin=true")

# searches for string 'Hash":"', after which comes the desired 46-char IPFS hash value
output=${output#*Hash\":\"}
ipfs_hash=${output:0:46}

echo $ipfs_hash
printf $ipfs_hash > $1.ipfs
