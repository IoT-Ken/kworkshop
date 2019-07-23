#!/bin/bash
#.___________. _______ .___  ___. .______    __          ___   .___________. _______      ______  __        ______   .__   __.  _______ 
#|           ||   ____||   \/   | |   _  \  |  |        /   \  |           ||   ____|    /      ||  |      /  __  \  |  \ |  | |   ____|
#`---|  |----`|  |__   |  \  /  | |  |_)  | |  |       /  ^  \ `---|  |----`|  |__      |  ,----'|  |     |  |  |  | |   \|  | |  |__   
#    |  |     |   __|  |  |\/|  | |   ___/  |  |      /  /_\  \    |  |     |   __|     |  |     |  |     |  |  |  | |  . `  | |   __|  
#    |  |     |  |____ |  |  |  | |  |      |  `----./  _____  \   |  |     |  |____    |  `----.|  `----.|  `--'  | |  |\   | |  |____ 
#    |__|     |_______||__|  |__| | _|      |_______/__/     \__\  |__|     |_______|    \______||_______| \______/  |__| \__| |_______|

# Author: Ken Osborn (kosborn@vmware.com)
# Version: 1.0
# Last Update: 21-Jul-19
# Purpose: Takes a Parent Org Template and Clones (Creates) the template to a
#          Sub-Org of your choice (or Modifies if template already exists)
# Requires: jq to manipulate json via Bash (sudo apt-get install jq)
#           httpie (sudo apt-get install httpie)

################################################################################
## Set Variables
################################################################################
MasterTemplateName=Master-Gateway-Template
PULSEINSTANCE=iotc009.vmware.com
SubOrgID=7ef420af-2e9e-4a53-8658-b0efcae98cde
SubOrgTemplateName=Invista-Gateway-Template

################################################################################
## Rest API Calls to Create Pulse Templates
################################################################################

# Identify current Pulse API version
APIVersion=$(curl --request GET \
  --url https://$PULSEINSTANCE:443/api/versions \
  --header 'Accept: application/json;api-version=1.0' \
  --header 'Cache-Control: no-cache' \
  --header 'Connection: keep-alive' \
  --header 'Content-Type: application/json' \
  --header "'Host: $PULSEINSTANCE:443'" \
  --header 'accept-encoding: gzip, deflate' \
| awk -F ':' '{print $2'} | awk -F ',' '{print $1}' | sed -e 's/"//g')

# Use Basic Auth to retrieve Bearer Token
BearerToken=$(curl --user [username]:[password] --request GET \
--url https://$PULSEINSTANCE:443/api/tokens \
--header "Accept: application/json;api-version=$APIVersion" \
--header 'Cache-Control: no-cache' \
--header 'Connection: keep-alive' \
--header 'Content-Type: application/json' \
--header "'Host: $PULSEINSTANCE:443'" \
--header 'accept-encoding: gzip, deflate' \
--header 'cache-control: no-cache' \
| grep accessToken | awk -F ':' '{print $2}' | awk -F ',' '{print $1}' | sed -e 's/"//g' | tr -d '\n')

# Retrieve Master Template (ParentOrg)
MasterTemplate=$(http GET "https://$PULSEINSTANCE:443/api/device-templates?name=$MasterTemplateName" \
  Accept:"application/json;api-version=$APIVersion" \
  Accept-Encoding:'gzip, deflate' \
  Authorization:"Bearer $BearerToken" \
  Cache-Control:no-cache \
  Connection:keep-alive \
  Content-Type:application/json \
  |  jq '.templates' | tail -n +2 | head -n -1 | sed -e "s/$MasterTemplateName/$SubOrgTemplateName/g")
  # tail and head commands on previous line remove first line '[' and last line ']'
  # this is done so that the json output can be properly formed for Clone (Create) device template
  # sed command changes the sub-org name to value indicate in $SubOrgTemplateName variable

# Check to see if Sub-Org Template already exists
CheckExist=$(http GET "https://$PULSEINSTANCE:443/api/device-templates?name=$SubOrgTemplateName" \
  Accept:'application/json;api-version=1.0' \
  Accept-Encoding:'gzip, deflate' \
  Authorization:"Bearer $BearerToken" \
  Cache-Control:no-cache \
  Connection:keep-alive \
  Content-Type:application/json \
  Host:$PULSEINSTANCE:443 \
  x-current-org-id:$SubOrgID \
  | jq .templates)

if [[ $CheckExist == *"$SubOrgTemplateName"* ]]; then
  echo "It's there!"
  # Clone (Update) Sub-Org Template with Master changes
   TemplateID=$(echo $CheckExist | jq '.[] | {id}' | jq -r .id)
   echo $MasterTemplate |  \
    http PUT https://$PULSEINSTANCE:443/api/device-templates/$TemplateID \
    Accept:"application/json;api-version=$APIVersion" \
    Accept-Encoding:'gzip, deflate' \
    Authorization:"Bearer $BearerToken" \
    Cache-Control:no-cache \
    Connection:keep-alive \
    Content-Type:application/json \
    Host:$PULSEINSTANCE:443 \
    x-current-org-id:$SubOrgID
else
  echo "It's not there!"
  # Clone (Create) Master Template to Sub-Org
  echo $MasterTemplate |  \
    http POST https://$PULSEINSTANCE:443/api/device-templates/ \
    Accept:"application/json;api-version=$APIVersion" \
    Accept-Encoding:'gzip, deflate' \
    Authorization:"Bearer $BearerToken" \
    Cache-Control:no-cache \
    Connection:keep-alive \
    Content-Type:application/json \
    Host:$PULSEINSTANCE:443 \
    x-current-org-id:$SubOrgID
fi


  
