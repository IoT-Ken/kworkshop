#!/bin/bash
#     _______. __    __  .______            ______   .______        _______     __  .__   __.  _______   ______   
#    /       ||  |  |  | |   _  \          /  __  \  |   _  \      /  _____|   |  | |  \ |  | |   ____| /  __  \  
#   |   (----`|  |  |  | |  |_)  |  ______|  |  |  | |  |_)  |    |  |  __     |  | |   \|  | |  |__   |  |  |  | 
#    \   \    |  |  |  | |   _  <  |______|  |  |  | |      /     |  | |_ |    |  | |  . `  | |   __|  |  |  |  | 
#.----)   |   |  `--'  | |  |_)  |        |  `--'  | |  |\  \----.|  |__| |    |  | |  |\   | |  |     |  `--'  | 
#|_______/     \______/  |______/          \______/  | _| `._____| \______|    |__| |__| \__| |__|      \______/  
                                                                                                                                                                                                                          
# Author: Ken Osborn (kosborn@vmware.com)
# Version: 1.0
# Last Update: 13-Sep-19
# Purpose: Code Snippet to illustrate retrieval of OrgId and Org specific info
#          (Name, Date Created, etc.)
# Requires: jq to manipulate json via Bash (sudo apt-get install jq)
#           httpie (sudo apt-get install httpie)

################################################################################
## Set Variables
################################################################################
PULSEINSTANCE=[Replace with pulse address, e.g. iotc00#.vmware.com]
SubrOrgID=[Indicate SubOrg ID]
read -s -p "User: " USER
read -s -p "Password: " PASSWORD

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
BearerToken=$(curl --user $USER:$PASSWORD --request GET \
--url https://$PULSEINSTANCE:443/api/tokens \
--header "Accept: application/json;api-version=$APIVersion" \
--header 'Cache-Control: no-cache' \
--header 'Connection: keep-alive' \
--header 'Content-Type: application/json' \
--header "'Host: $PULSEINSTANCE:443'" \
--header 'accept-encoding: gzip, deflate' \
--header 'cache-control: no-cache' \
| grep accessToken | awk -F ':' '{print $2}' | awk -F ',' '{print $1}' | sed -e 's/"//g' | tr -d '\n')

# Retrieve All Sub-Org's
SubOrgs=$(http GET "https://$PULSEINSTANCE:443/api/organizations/" \
  Accept:"application/json;api-version=$APIVersion" \
  Accept-Encoding:'gzip, deflate' \
  Authorization:"Bearer $BearerToken" \
  Cache-Control:no-cache \
  Connection:keep-alive \
  Content-Type:application/json \
  Host:$PULSEINSTANCE:443)

echo $SubOrgs

# Retrieve specific Sub-Org
SubOrgDetails=$(http GET https://$PULSEINSTANCE:443/api/organizations/$SubOrgID\
  Accept:'application/json;api-version=1.0' \
  Accept-Encoding:'gzip, deflate' \
  Authorization:"Bearer $BearerToken" \
  Cache-Control:no-cache \
  Connection:keep-alive \
  Content-Type:application/json \
  Host:$PULSEINSTANCE:443)

echo $SubOrgDetails
