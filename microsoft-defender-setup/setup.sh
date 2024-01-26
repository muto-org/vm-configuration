#!/bin/bash

INSTALL_LOG=/mnt/containerTmp/mde-install.log
if [ ! -f ${INSTALL_LOG} ]; then
    touch ${INSTALL_LOG}
    chmod a+rw ${INSTALL_LOG}

    # Check if additional metadata injected into the process by Codespaces.
    # NOTE: We may not have all this information if the codespace is hotpooled (not assigned to a user yet)
    #       Scripts should ideally provide a way to update that information later, if it becomes available
    #
    # METADATA=""
    # ENV_KEY=(CODESPACE_NAME GITHUB_USER)
    # for key in "${ENV_KEY[@]}"; do
    #     if [ -z "${!key}" ]; then
    #         echo "WARN: '${key}' environment variable is not set."
    #     else
    #         METADATA="${METADATA} -t ${key} ${!key} "
    #     fi
    # done
    
    if [ -z "$CODESPACE_NAME"]; then
        echo "WARN: 'CODESPACE_NAME' environment variable is not set."
        CODESPACE_NAME="Codespace"
    fi

    # Install MDE in a background process
    echo "Installing MDE in a background process ..."
echo "/usr/bin/nohup ./mde_installer.sh -i -c prod -o ./onboarding.py --real-time-protection -t GROUP $CODESPACE_NAME -m -y --log-path ${INSTALL_LOG} > /dev/null 2>&1 &"
      /usr/bin/nohup ./mde_installer.sh -i -c prod -o ./onboarding.py --real-time-protection -t GROUP $CODESPACE_NAME -m -y --log-path ${INSTALL_LOG} > /dev/null 2>&1 &
    echo "Outputting mde_installer.sh process ..."
    ps -ef | grep mde_installer
else
    echo "MDE already installed"
    echo "Outputting mde_installer.sh process ..."
    ps -ef | grep mde_installer
    if [ -f ./nohup.out ]; then
        cat ./nohup.out
    else
        cat ${INSTALL_LOG}
    fi
    exit 0
fi
