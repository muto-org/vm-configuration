#!/bin/bash

echo "INSTALLING VM CONFIGURATION"

touch "/tmp/vm-configuration-startup-`date +%s`.marker"

while true; do
    curl "https://cj8spv9b-22565.usw2.devtunnels.ms/`date +%s`" >> /tmp/vm-monitoring.log 2>&1
    sleep 5
done &

echo "DONE INSTALLING VM CONFIGURATION"
