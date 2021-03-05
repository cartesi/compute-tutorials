#!/bin/bash

if [ ! $1 ]; then
  echo "1 parameter required: file to submit"
  exit 1
fi

curl -X POST -F file=@$1 "https://ipfs.infura.io:5001/api/v0/add?pin=true"
