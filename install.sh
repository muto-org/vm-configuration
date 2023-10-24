#!/bin/bash

BASE_FOLDER=
# Determine log directory
if [ -d /mnt/containerTmp ]; then
    BASE_FOLDER=/mnt/containerTmp
else
    BASE_FOLDER=`pwd`
fi

echo "~~~ START ~~~~"
touch "${BASE_FOLDER}/`date +%H:%M:%S`-start.marker"

NOW=`date +%H:%M:%S`
IDEMPOTENT_MARKER_FILE="${BASE_FOLDER}/vm-configuration-run.marker"
METADATA_FILE="${BASE_FOLDER}/${NOW}-metadata.env.marker"
ALL_ENV_FILE="${BASE_FOLDER}/${NOW}-all.env.marker"

if [ -f ${IDEMPOTENT_MARKER_FILE} ]; then
    echo "Configuration has been run at least once before on this host!  Welcome back!"
else
    echo "This is the first time configuration has been run on this host. Welcome!"
    touch $IDEMPOTENT_MARKER_FILE
fi

echo "CODESPACE_NAME=$CODESPACE_NAME"                   >> "${METADATA_FILE}"
echo "GITHUB_USER=$GITHUB_USER"                         >> "${METADATA_FILE}"
echo "HOST_SECRET_1=$HOST_SECRET_1"                     >> "${METADATA_FILE}"

env > ${ALL_ENV_FILE}

nohup ./helper.sh "$BASE_FOLDER" background 10 > /dev/null 2>&1 &
# nohup ./helper.sh "$BASE_FOLDER" nohup 10 &
# nohup ./helper.sh "$BASE_FOLDER" nohupWithDevNull 10 > "${BASE_FOLDER}/nohupWithDevNull" 2>&1 &

# Uncomment to simulate an ERROR!
# echo "something bad happening"
# exit 1

echo "~~~ END ~~~~"
touch "${BASE_FOLDER}/`date +%H:%M:%S`-end.marker"

