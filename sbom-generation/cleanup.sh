#!/bin/bash

BASE_FOLDER=
# Determine log directory
if [ -d /mnt/containerTmp ]; then
    BASE_FOLDER=/mnt/containerTmp
else
    BASE_FOLDER=`pwd`
fi

echo "Base Folder: $BASE_FOLDER"

pushd $BASE_FOLDER
rm -f *.marker
rm -f nohup.out