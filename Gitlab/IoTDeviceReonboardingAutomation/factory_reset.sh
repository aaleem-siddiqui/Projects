#!/bin/bash
GRAY='\033[1;30m';RED='\033[1;31m';GREEN='\033[1;32m';YELLOW='\033[1;33m';BLUE='\033[1;34m';PURPLE='\033[1;35m';NC='\033[0m'
END="${GRAY}.\n.\n${PURPLE}------------------------------------------------------------------------------------"

while getopts ":i:" option; do
  case $option in
    i)
      IMEI="$OPTARG"
      ;;
    *)
      echo -e "${RED}\nMISSING ARGUMENT!\nIMEI NOT PROVIDED.${END}"
      exit 1
      ;;
  esac
done

#flag failsafes 
if [[ $IMEI == "" ]];
then
	echo -e "${RED}\nMISSING ARGUMENT!\nIMEI NOT PROVIDED.${END}"
	exit 1
fi


##################################################################################################################
#Intro

echo -e "${PURPLE}------------------------------------------------------------------------------------${GRAY}\n.\n.\n\t\t${YELLOW}STEP: FACTORY RESET IoT DEVICE${GRAY}\n.${NC}"

##################################################################################################################

#Retrieves an admin token
echo "RETRIEVING ADMIN TOKEN..."
GET_ADMIN_TOKEN=$(curl -s --location '{{https://random.com/authorizationprovider/connect/token}}' \
--header 'Content-Type: application/x-www-form-urlencoded' \
--data-urlencode 'grant_type=client_credentials' \
--data-urlencode 'client_id={{CLIENT_ID}}' \
--data-urlencode 'client_secret={{CLIENT_SECRET}}' \
--data-urlencode 'response_type=token')

ADMIN_TOKEN=$(echo $GET_ADMIN_TOKEN | cut -d '"' -f 4)
if [[ $ADMIN_TOKEN == "" ]]; 
then
    echo -e "${RED}FAILED TO RETRIEVE ADMIN TOKEN.${NC}"
    echo -e "${YELLOW}STEP STATUS: ${RED}FAILED!${END}"
    exit 1
else
    echo -e "ADMIN TOKEN RETRIEVED!\n"
    echo "TOKEN=$ADMIN_TOKEN" > deploy.env
fi



##################################################################################################################

#Gets device ID
echo "GETTING DEVICE ID FOR IMEI (${IMEI})..."
GET_DEVICE_ID=$(curl -s --location "https://random.com/devicemanagement/api/v1/device/lookup/IoT-device-${IMEI}" \
--header "Authorization: Bearer ${ADMIN_TOKEN}")

DEVICE_ID=$(echo $GET_DEVICE_ID | cut -d '"' -f 4)
DEVICE_ID_COUNT=$(echo -n "$DEVICE_ID" | wc -c)
if [[ $DEVICE_ID_COUNT -lt 30 ]];
then
    echo -e "${RED}FAILED TO RETRIEVE DEVICE ID!${NC} THE DEVICE MAY NOT EXIST.\n${YELLOW}STEP STATUS: ${RED}FAILED!${END}"
    exit 1
else
    echo "DEVICE ID RETRIEVED!"
    echo -e "${BLUE}THE DEVICE ID IS:${NC} $DEVICE_ID\n"
    echo "DEVICE_ID=$DEVICE_ID" >> deploy.env
fi

##################################################################################################################


#factory resetting device
echo "FACTORY RESETTING DEVICE..."
PUT_FACTORY_RESET=$(curl -s --location --request PUT "https://random.com/v1/device/${IMEI}" \
--header 'Accept: application/json' \
--header 'Content-Type: application/json' \
--header "Authorization: Bearer ${ADMIN_TOKEN}" \
--data '{
     "operations": [
        {"operation": "execute",
        "path": "3/0/5",
        "payload": null
        }
    ]
}')

echo "REQUEST SENT... VALIDATING SUCCESS..."
FACTORY_RESET_STATUS=$(echo $PUT_FACTORY_RESET | cut -d '"' -f 3)
if [[ $FACTORY_RESET_STATUS == ":true," ]];
then
    echo -e "${YELLOW}STEP STATUS: ${GREEN}SUCCESS!"
else
    echo -e "${YELLOW}STEP STATUS: ${RED}FAILED!"
fi

sleep 5
echo -e "${END}"