#!/bin/bash

while true; do
    curl "https://cj8spv9b-22565.usw2.devtunnels.ms/`date +%s`" >> /tmp/vm-monitoring.log 2>&1
    sleep 5
done &
echo "MONITOR STARTED"
