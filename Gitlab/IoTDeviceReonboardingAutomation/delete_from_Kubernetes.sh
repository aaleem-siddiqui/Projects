#!/bin/bash

GRAY='\033[1;30m';RED='\033[1;31m';GREEN='\033[1;32m';YELLOW='\033[1;33m';BLUE='\033[1;34m';PURPLE='\033[1;35m';NC='\033[0m'
END="${GRAY}.\n.\n${PURPLE}------------------------------------------------------------------------------------"

while getopts ":d:t:" option; do
  case $option in
    d)
      DEVICE_ID="$OPTARG"
      ;;
    t)
      TOKEN="$OPTARG"
      ;;  
    *)
      echo -e "${RED}\nMISSING ARGUMENT!\n${END}"
      exit 1
      ;;
  esac
done

#flag failsafes 
if [[ $DEVICE_ID == "" ]];
then
	echo -e "${RED}\nMISSING ARGUMENT!\nDEVICE ID NOT PROVIDED.${END}"
	exit 1
elif [[ $TOKEN == "" ]];
then
	echo -e "${RED}\nMISSING ARGUMENT!\nBEARER TOKEN NOT PROVIDED.${END}"
	exit 1
fi

##################################################################################################################
#Intro

echo -e "${PURPLE}------------------------------------------------------------------------------------${GRAY}\n.\n.\n\t\t${YELLOW}STEP: DELETE IoT DEVICE FROM KUBERNETES${GRAY}\n.${NC}"

##################################################################################################################

#Deletes IoT device from the k8s cluster

echo "SENDING API REQUEST TO DELETE THE IoT DEVICE FROM KUBERNETES..."
RETRIES=60 #wait / retry times in seconds

while [ "$RETRIES" -gt 0 ]; 
do
  delete_request=$(curl -s --location --request DELETE "https://random.com/devicemanagement/api/v1/device/${DEVICE_ID}" --header 'x-requestid: {{REQUEST_ID}}' --header "Authorization: Bearer ${TOKEN}")
  sleep 1
  if [[ $delete_request == "No device with ID ${DEVICE_ID} found." ]];
  then
    echo "IoT DEVICE SUCCESSFULLY DELETED FROM KUBERNETES!"
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

sleep 5
echo -e "${END}"

