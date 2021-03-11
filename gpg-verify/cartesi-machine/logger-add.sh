#!/bin/bash

if [ ! $3 ]; then
  echo "3 parameters required: file, tree size and destination directory"
  exit 1
fi

merkle=$(./merkle.sh $1 $2)

cp $1 $3/$merkle
echo $merkle
