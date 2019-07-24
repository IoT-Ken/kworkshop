#!/bin/sh

# Version: 1.0
# Last Update: 24-Jul-19
# Purpose: Run Ansible Playbook

# Set current Package dir variable and change into
dirname=$(echo `echo $(dirname "$0")`)
cd $dirname

echo "This is the script: execute phase" >> /tmp/campaign.log

################################################################################
## Run Ansible Playbook
################################################################################
/usr/bin/ansible-playbook /ansible/docker.yml
if [ $? -eq 0 ]; then
    echo "Ansible Installed error" >> /tmp/campaign.log
else
    echo "Ansible command ran without error" >> /tmp/campaign.log 
fi
