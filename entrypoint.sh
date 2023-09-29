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

# if [ ! -f ${INSTALL_LOG} ]; then
    touch ${INSTALL_LOG}
    chmod a+rw ${INSTALL_LOG}
    echo `date +%s` >> /tmp/vm-configuration-startup.marker
    echo "Installing in a background process ..."
    /usr/bin/nohup ./worker.sh -o ./onboard.py --base-folder ${BASE_FOLDER} &
    echo $! > /tmp/vm-configuration.pid
# else
#     echo "already installed"
#     if [ -f ./nohup.out ]; then
#         cat ./nohup.out
#     else
#         cat ${INSTALL_LOG}
#     fi
#     exit 0
# fi