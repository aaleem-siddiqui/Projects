#!/bin/bash

GRAY='\033[1;30m';RED='\033[1;31m';GREEN='\033[1;32m';YELLOW='\033[1;33m';BLUE='\033[1;34m';PURPLE='\033[1;35m';NC='\033[0m'
END="${GRAY}.\n.\n${PURPLE}------------------------------------------------------------------------------------"

while getopts ":i:c:n:" option; do
  case $option in
    i)
      IMEI="$OPTARG"
      ;;
    c)
      CLUSTER_NAME="$OPTARG"
      ;;
    n)
      INSTANCE_NAME="$OPTARG"
      ;;
    *)
      echo -e "${RED}\nMISSING ARGUMENT!\n${END}"
      exit 1
      ;;
  esac
done

#flag failsafes 
if [[ $IMEI == "" ]];
then
	echo -e "${RED}\nMISSING ARGUMENT!\nIMEI NOT PROVIDED..${END}"
	exit 1
elif [[ $CLUSTER_NAME == "" ]];
then
	echo -e "${RED}\nMISSING ARGUMENT!\nCLUSTER NAME NOT PROVIDED.${END}"
	exit 1
elif [[ $INSTANCE_NAME == "" ]];
then
	echo -e "${RED}\nMISSING ARGUMENT!\nINSTANCE_NAME NOT PROVIDED.${END}"
	exit 1
fi

##################################################################################################################
#Intro

echo -e "${PURPLE}------------------------------------------------------------------------------------${GRAY}\n.\n.${YELLOW}\n\t\tSTEP: DELETE IoT DEVICE FROM INSTANCE\n${GRAY}.${NC}"

##################################################################################################################

#Retrieves an admin token
echo "RETRIEVING ADMIN TOKEN..."
GET_ADMIN_TOKEN=$(curl -s --location "https://random.com/authorizationprovider/connect/token" \
--header 'Content-Type: application/x-www-form-urlencoded' \
--data-urlencode 'grant_type=client_credentials' \
--data-urlencode "client_id={{CLIENT_ID}}" \
--data-urlencode 'client_secret={{CLIENT_SECRET}}' \
--data-urlencode 'response_type=token')

ADMIN_TOKEN=$(echo $GET_ADMIN_TOKEN | cut -d '"' -f 4)
if [[ $ADMIN_TOKEN == "" ]]; 
then
    echo -e "${RED}FAILED TO RETRIEVE ADMIN TOKEN."
    echo -e "${YELLOW}STEP STATUS: ${RED}FAILED!${END}"
    exit 1
else
    echo -e "ADMIN TOKEN RETRIEVED!\n"
fi

##################################################################################################################

#Get device by external ID
echo "RETRIEVING EXTERNAL DEVICE ID..."
GET_EXTERNAL_ID=$(curl -s --location "https://random.com/devicemanagement/api/v1/device/lookup/${IMEI}" --header "Authorization: Bearer ${ADMIN_TOKEN}")

EXTERNAL_ID=$(echo $GET_EXTERNAL_ID | cut -d '"' -f 4)
if [[ $EXTERNAL_ID == "" ]];
then
    echo -e "${RED}FAILED TO RETRIEVE EXTERNAL DEVICE ID."
    echo -e "${YELLOW}STEP STATUS: ${RED}FAILED!${END}"
    exit 1
else
    echo "EXTERNAL DEVICE ID RETRIEVED!"
    echo -e "${BLUE}THE EXTERNAL DEVICE ID IS:${NC} $EXTERNAL_ID\n"
fi

##################################################################################################################

#Delete IoT DEVICE from INSTANCE
echo "SENDING API REQUEST TO DELETE THE IoT DEVICE FROM THE INSTANCE..."
RETRIES=60 #wait / retry times in seconds

while [ "$RETRIES" -gt 0 ]; 
do
  DELETE_REQUEST=$(curl -s --location --request DELETE "https://random.com/devicemanagement/api/v1/device/${EXTERNAL_ID}" --header 'x-requestid: {{REQUEST_ID}}' --header "Authorization: Bearer ${ADMIN_TOKEN}")
  sleep 1
  if [[ $DELETE_REQUEST == "No device with ID ${EXTERNAL_ID} found." ]];
  then
    echo "IoT DEVICE SUCCESSFULLY DELETED FROM INSTANCE!"
    echo -e "${YELLOW}STEP STATUS: ${GREEN}SUCCESS!"
    break
  fi
  echo "WAITING..."
  RETRIES=$(( RETRIES - 1 ))
done

if [[ "$RETRIES" -eq 0 ]];
then
  echo -e "${YELLOW}STEP STATUS: ${RED}FAILED!"
fi

sleep 10
echo -e "${END}"