#!/bin/bash

# Optional base folder
BASE_FOLDER="${1:-.}"

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

    # Run the script in the container
    # NOTE: This assumes the container has 'node' installed!
    # Redirect output to the log file
    docker exec $CONTAINER_ID node /tmp/generate_sbom.js | tee -a $LOG_FILE
    if [ $? -ne 0 ]; then
        echo "Failed to run 'generate_sbom.js' in the container" | tee -a $LOG_FILE
        continue
    fi

    echo "[`date +%H:%M:%S`] Successfully generated an SBOM.  Sleeping..." | tee -a $LOG_FILE
done

