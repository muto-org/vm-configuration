#!/bin/bash

BASE_FOLDER=$1
MARKER=$2
SLEEP=$3

echo "[$MARKER] Begin"
touch "${BASE_FOLDER}/`date +%H:%M:%S`-begin-$MARKER.marker"

sleep $SLEEP

echo "[$MARKER] End"
touch "${BASE_FOLDER}/`date +%H:%M:%S`-end-$MARKER.marker"
