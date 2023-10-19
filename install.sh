#!/bin/bash

BASE_FOLDER=
# Determine log directory
if [ -d /mnt/containerTmp ]; then
    BASE_FOLDER=/mnt/containerTmp
else
    BASE_FOLDER=`pwd`
fi

METADATA_FILE="`date +%H:%M:%S`-vm-configuration-metadata.env"
echo "CODESPACE_NAME=$CODESPACE_NAME"                   >> "${BASE_FOLDER}/${METADATA_FILE}"
echo "GITHUB_USER=$GITHUB_USER"                         >> "${BASE_FOLDER}/${METADATA_FILE}"

echo "~~ Printing env ~~"
env
echo "~~~~~~~~~~~~~~~~~~"

# Silently remove all makers from base folder before starting
pushd $BASE_FOLDER
rm -f *.marker
popd

echo "[install.sh] Begin"
touch "${BASE_FOLDER}/`date +%H:%M:%S`-vm-configuration-startup.marker"

# nohup ./helper.sh "$BASE_FOLDER" nohup 10 &
nohup ./helper.sh "$BASE_FOLDER" nohupWithDevNull 10 > /dev/null 2>&1 &
# nohup ./helper.sh "$BASE_FOLDER" nohupWithDevNull 10 > "${BASE_FOLDER}/nohupWithDevNull" 2>&1 &

# Uncomment to simulate an ERROR!
# echo "something bad happening"
# exit 1

echo "[install.sh] End"
touch "${BASE_FOLDER}/`date +%H:%M:%S`-vm-configuration-shutdown.marker"

