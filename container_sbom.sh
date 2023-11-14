#!/bin/bash

BASE_FOLDER="$1"
if [ -z "$BASE_FOLDER" ]; then
    echo "BASE_FOLDER is required"
    exit 1
fi

LOG_FILE="${BASE_FOLDER}/sbom.log"

echo "[`date +%H:%M:%S`] Starting container monitor..." | tee -a $LOG_FILE

# NOTE: Assumes the target container has 'node' installed!
while true; do
    echo "[`date +%H:%M:%S`] Waiting for next check..." | tee -a $LOG_FILE
    # sleep
    sleep 20
    echo "[`date +%H:%M:%S`] Done waiting for next check." | tee -a $LOG_FILE

    # Get the codespace container by ID
    CONTAINER_ID=$(docker ps -aq --filter label=Type=codespaces)
    # If the container is not running, continue to the next iteration
    if [ -z "$CONTAINER_ID" ]; then
        echo "Codespace container not found (yet)" | tee -a $LOG_FILE
        continue
    fi
    
    # Copy 'generate_sbom.js' to the container
    docker cp generate_sbom.js $CONTAINER_ID:/tmp/generate_sbom.js
    if [ $? -ne 0 ]; then
        echo "Failed to copy 'generate_sbom.js' to the container" | tee -a $LOG_FILE
        continue
    fi

    # Run the script in the container, seeing the 'SBOM_BASE_PATH' environment variable
    docker exec -e SBOM_BASE_PATH=$BASE_PATH $CONTAINER_ID node /tmp/generate_sbom.js
    if [ $? -ne 0 ]; then
        echo "Failed to run 'generate_sbom.js' in the container" | tee -a $LOG_FILE
        continue
    fi

    echo "Successfully generated an SBOM.  Sleeping..." | tee -a $LOG_FILE
done

