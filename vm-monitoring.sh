#!/bin/bash
 
echo "ping!"

name=$(cat /root/.codespaces/shared/environment-variables.json | jq -r .CODESPACE_NAME)
curl "https://3k9nvmsm-25565.usw2.devtunnels.ms/$name" >> /tmp/vm-monitoring.log 2>&1