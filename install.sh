#!/bin/bash

BASE_FOLDER=
# Determine log directory
if [ -d /mnt/containerTmp ]; then
    BASE_FOLDER=/mnt/containerTmp
else
    BASE_FOLDER=`pwd`
fi

IDEMPOTENT_MARKER_FILE="${BASE_FOLDER}/idempotent.marker"
if [ -f ${IDEMPOTENT_MARKER_FILE} ]; then
    echo "Configuration has been run at least once before on this host!  Welcome back!"
else
    echo "This is the first time configuration has been run on this host. Welcome!"
fi
touch $IDEMPOTENT_MARKER_FILE

METADATA_FILE="`date +%H:%M:%S`-vm-configuration-metadata.env.marker"
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

