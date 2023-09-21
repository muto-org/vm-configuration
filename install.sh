#!/bin/bash

echo "INSTALLING VM CONFIGURATION"

touch "/tmp/vm-monitoring-startup-`date +%s`.marker"

# Copy scripts to /usr/local/bin
cp vm-monitoring.sh /usr/local/bin/vm-monitoring.sh
# Install systemd service and timer
cp vm-monitoring.service /etc/systemd/system/vm-monitoring.service
cp vm-monitoring.timer /etc/systemd/system/vm-monitoring.timer
# Enable systemd service and timer
systemctl enable vm-monitoring.service
systemctl enable vm-monitoring.timer
# Start systemd service and timer
systemctl start vm-monitoring.service
systemctl start vm-monitoring.timer

# List systemd services and timers
systemctl list-timers

echo "DONE INSTALLING VM CONFIGURATION"