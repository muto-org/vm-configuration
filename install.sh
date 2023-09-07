#!/bin/bash

echo "INSTALLING VM CONFIGURATION"

touch "/tmp/vm-configuration-startup-`date +%s`.marker"

bash monitor.sh &

echo "DONE INSTALLING VM CONFIGURATION"
