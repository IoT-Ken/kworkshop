#!/bin/bash
# .______    __    __   __          _______. _______
# |   _  \  |  |  |  | |  |        /       ||   ____|
# |  |_)  | |  |  |  | |  |       |   (----`|  |__
# |   ___/  |  |  |  | |  |        \   \    |   __|
# |  |      |  `--'  | |  `----.----)   |   |  |____
# | _|       \______/  |_______|_______/    |_______|

# Author: Ken Osborn (kosborn@vmware.com)
# Version: 1.0
# Last Update: 21-Jul-19
# Purpose: Sends Gateways and/or Metrics to Pulse Server

# Set Pulse Agent Variables
AGENTBINPATH="/opt/vmware/iotc-agent/bin/"
AGENTDATAPATH="/opt/vmware/iotc-agent/data/data/"

# Multiple Ways to retrieve Gateway Unique ID (as registered in Pulse Server)
# 1) Retrieve IoT Sensor Device ID from /opt/vmware/iotc-agent/data/data/deviceIDs.data 
GATEWAYID=$(cat -v ${AGENTDATAPATH}deviceIds.data | awk -F '^' '{print $2}' | awk -F '@' '{print $2}')
# 2) Retrieve Gateway ID by Calling Pulse Server
# GATEWAYID=$(${AGENTBINPATH}DefaultClient get-devices | head -n1 | awk ‘{print $1}’)

# Set uptime variable via bash command in -p 'pretty format' | sed strips out whitespace
# and occurences of ',-' and replaces with '-'
UP=$(uptime -p | sed -e 's/ /-/g' | sed -e 's/,-/,/g')

# Send System Properties to Pulse
sudo ${AGENTBINPATH}DefaultClient send-properties --device-id=$GATEWAYID --key=uptime --value=$UP

# Send Metrics to Pulse
