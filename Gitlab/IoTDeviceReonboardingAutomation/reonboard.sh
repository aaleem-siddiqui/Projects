#!/bin/bash

GRAY='\033[1;30m';RED='\033[1;31m';GREEN='\033[1;32m';YELLOW='\033[1;33m';BLUE='\033[1;34m';PURPLE='\033[1;35m';NC='\033[0m'
END="${GRAY}.\n.\n${PURPLE}------------------------------------------------------------------------------------"

while getopts ":i:z:t:c:n:v:" option; do
  case $option in
    i)
      IMEI="$OPTARG"
      ;;
    z)
      ICCID="$OPTARG"
      ;;
    t)
      TOKEN="$OPTARG"
      ;;  
    c)
      CLUSTER_NAME="$OPTARG"
      ;;
    n)
      INSTANCE_NAME="$OPTARG"
      ;;
    v)
      NEW_INSTANCE_NAME="$OPTARG"
      ;;
    *)
      echo -e "\nMISSING ARGUMENT!\n${END}"
      exit 1
      ;;
  esac
done

#flag failsafes 
if [[ $IMEI == "" ]];
then
	echo -e "${RED}\nMISSING ARGUMENT!\nIMEI NOT PROVIDED.${END}"
	exit 1
elif [[ $TOKEN == "" ]];
then
	echo -e "${RED}\nMISSING ARGUMENT!\nBEARER TOKEN NOT PROVIDED.${END}"
	exit 1
elif [[ $CLUSTER_NAME == "" ]];
then
	echo -e "${RED}\nMISSING ARGUMENT!\nCLUSTER NAME NOT PROVIDED.${END}"
	exit 1
elif [[ $ICCID == "" ]];
then
	echo -e "${RED}\nMISSING ARGUMENT!\nICCID NOT PROVIDED.${END}"
	exit 1
elif [[ $INSTANCE_NAME == "" ]];
then
	echo -e "${RED}\nMISSING ARGUMENT!\nINSTANCE_NAME NOT PROVIDED.${END}"
	exit 1
elif [[ $NEW_INSTANCE_NAME != "" ]];
then
  INSTANCE_NAME="$NEW_INSTANCE_NAME"
fi

##################################################################################################################
#Intro

echo -e "${PURPLE}------------------------------------------------------------------------------------${GRAY}\n.\n.\n${YELLOW}\t\tSTEP: RE-ONBOARD IoT DEVICE\n${GRAY}.${NC}"


##################################################################################################################

#Reonboards IoT DEVICE

echo "SENDING API CALL TO RE-ONBOARD THE IoT DEVICE... PLEASE WAIT..."
echo -e "${BLUE}IoT DEVICE IMEI:${NC} ${IMEI}"
echo -e "${BLUE}IoT DEVICE ICCID:${NC} ${ICCID}"
echo -e "${BLUE}CLUSTER NAME:${NC} ${CLUSTER_NAME}"
echo -e "${BLUE}INSTANCE NAME:${NC} ${INSTANCE_NAME}"

RETRIES=120 #wait / retry times in seconds
sleep 30

while [ "$RETRIES" -gt 0 ]; 
do
  POST_REONBOARD=$(curl -s --location 'https://random.com/hubadapterhttp/v1/device' \
  --header 'Content-Type: application/json' \
  --header "Authorization: Bearer ${TOKEN}" \
  --data '{
      "externalDeviceId": "'${IMEI}'",
      "iccid": "'${ICCID}'",
      "tenantId": "'${INSTANCE_NAME}'",
      "requireCertificate": true,
      "MeasurementDataConnectionEnabled": true,
      "sendingInterval": 15
  }')
  REONBOARD_STATUS=$(echo $POST_REONBOARD | cut -d '"' -f 3)
  NEW_DEVICE_ID=$(echo $POST_REONBOARD | cut -d '"' -f 6)
  if [[ $REONBOARD_STATUS == ":true," ]];
  then
    echo "IoT DEVICE SUCCESSFULLY RE-ONBOARDED!"
    echo -e "${BLUE}THE NEW DEVICE ID IS:${NC} ${NEW_DEVICE_ID}"
    echo -e "${YELLOW}STEP STATUS: ${GREEN}SUCCESS!"
    break
  fi
  echo "WAITING..."
  sleep 10
  RETRIES=$(( RETRIES - 1 ))
done

if [[ "$RETRIES" -eq 0 ]];
then
  echo -e "${YELLOW}STEP STATUS: ${RED}FAILED!"
fi

echo -e "${END}"