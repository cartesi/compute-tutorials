#!/bin/bash

if [ ! $1 ]; then
  echo "1 parameter required: file to submit"
  exit 1
fi

output=$(curl -X POST -s -F file=@$1 "https://ipfs.infura.io:5001/api/v0/add?pin=true")

# searches for string 'Hash":"', after which comes the desired value
output=${output#*Hash\":\"}

# IPFS path is retrieved by '/ipfs/' followed by the 46-character hash
ipfs_path="/ipfs/${output:0:46}"
echo $ipfs_path > $1.ipfs

echo $ipfs_path
