#!/bin/bash

BASE_FOLDER=
# Determine log directory
if [ -d /mnt/containerTmp ]; then
    BASE_FOLDER=/mnt/containerTmp
elif [ -d /tmp ]; then
    BASE_FOLDER=/tmp
else
    BASE_FOLDER=.
fi
INSTALL_LOG=${BASE_FOLDER}/install.log
echo "INSTALL_LOG=${INSTALL_LOG}"

touch ${INSTALL_LOG}
chmod a+rw ${INSTALL_LOG}
echo `date +%s` >> /tmp/vm-configuration-startup.marker
echo "Installing in a background process ..."
/usr/bin/nohup ./worker.sh -o ./onboard.py --base-folder ${BASE_FOLDER} &
echo $! > /tmp/vm-configuration.pid
