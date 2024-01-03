#!/bin/bash
GRAY='\033[1;30m';RED='\033[1;31m';GREEN='\033[1;32m';YELLOW='\033[1;33m';BLUE='\033[1;34m';PURPLE='\033[1;35m';NC='\033[0m'
END="${GRAY}\n.\n.\n${PURPLE}------------------------------------------------------------------------------------"

while getopts ":e:c:t:" option; do
  case $option in
    e)
      CLIENT_EMAIL="$OPTARG"
      ;;
    c)
      CLUSTER_NAME="$OPTARG"
      ;;
    t)
      INSTANCE_NAME="$OPTARG"
      ;;
    *)
      echo -e "${RED}\nMISSING ARGUMENTS! EXITING SCRIPT...${END}"
      exit 1
      ;;
  esac
done

#flag failsafes 
if [[ $CLUSTER_NAME == "" ]];
then
	echo -e "${RED}\nMISSING ARGUMENT!\nCLUSTER NAME NOT PROVIDED.${END}"
	exit 1
elif [[ $INSTANCE_NAME == "" ]];
then
	echo -e "${RED}\nMISSING ARGUMENT!\nINSTANCE NAME NOT PROVIDED.${END}"
	exit 1
elif [[ $CLIENT_EMAIL == "" ]];
then
	echo -e "${RED}\nMISSING ARGUMENT!\nCLIENT EMAIL NOT PROVIDED.${END}"
	exit 1
fi

##################################################################################################################
#Intro

echo -e "${PURPLE}------------------------------------------------------------------------------------${GRAY}\n.\n.\n\t\t${YELLOW}CLOUD PLATFORM INITIAL SIGNUP${GRAY}\n.${NC}"

##################################################################################################################

#Retrieves an admin token
echo "RETRIEVING ADMIN TOKEN..."
GET_ADMIN_TOKEN=$(curl -s --location "https://${CLUSTER_NAME}.generic.web/micro-service/connect/token" \
--header 'Content-Type: application/x-www-form-urlencoded' \
--data-urlencode 'grant_type=client_credentials' \
--data-urlencode "client_id=systemadmin@${INSTANCE_NAME}" \
--data-urlencode 'client_secret={{SECRET}}' \
--data-urlencode 'response_type=token')

ADMIN_TOKEN=$(echo $GET_ADMIN_TOKEN | cut -d '"' -f 4)
if echo $GET_ADMIN_TOKEN | grep -q "access_token";
then
    echo -e "${GREEN}SUCCESS!${NC} ADMIN TOKEN RETRIEVED!"
else
    echo -e "${RED}FAILED TO RETRIEVE ADMIN TOKEN.${NC}\nDOUBLE CHECK THE CLUSTER NAME OR INSTANCE NAME VARIABLES. MAKE SURE THEY EXIST."
    echo -e "${YELLOW}STEP STATUS: ${RED}FAILED!${END}"
    exit 1
fi

##################################################################################################################

#Gets INSTANCE ID and identifier 
echo "RETRIEVING INSTANCE INFO..."
GET_INSTANCE_INFO=$(curl -s --location "https://${CLUSTER_NAME}.generic.web/micro-service/api/INSTANCEs" \
--header "Authorization: Bearer ${ADMIN_TOKEN}")

INSTANCE_ID=$(echo ${GET_INSTANCE_INFO} | grep -oE ".{0,300}${CLIENT_EMAIL}.{0,200}" | grep -oP '"id"\s*:\s*"\K[^"]*')
INSTANCE_IDENTIFIER=$(echo ${GET_INSTANCE_INFO} | grep -oE ".{0,300}${CLIENT_EMAIL}.{0,200}" | grep -oP '"INSTANCEIdentifier"\s*:\s*"\K[^"]*')
INSTANCE_ID_COUNT=$(echo -n "$INSTANCE_ID" | wc -c)

if [[ $INSTANCE_ID_COUNT -lt 30 || $INSTANCE_ID_COUNT -gt 40 ]];
then
    echo -e "${RED}FAILED TO RETRIEVE INSTANCE ID!${NC}\nTHE EMAIL PROVIDED MAY NOT BE THE INSTANCE OWNER.\nTRYING TO SEARCH USING THE INSTANCE NAME INSTEAD OF THE EMAIL PROVIDED..."
    INSTANCE_ID=$(echo ${GET_INSTANCE_INFO} | grep -oE ".{0,300}${INSTANCE_NAME}.{0,200}" | grep -oP '"id"\s*:\s*"\K[^"]*')
    INSTANCE_IDENTIFIER=$(echo ${GET_INSTANCE_INFO} | grep -oE ".{0,300}${INSTANCE_NAME}.{0,200}" | grep -oP '"INSTANCEIdentifier"\s*:\s*"\K[^"]*')
    INSTANCE_ID_COUNT=$(echo -n "$INSTANCE_ID" | wc -c)
    if [[ $INSTANCE_ID_COUNT -lt 30 || $INSTANCE_ID_COUNT -gt 40 ]];
    then
       echo -e "${RED}FAILED TO RETRIEVE INSTANCE ID AGAIN!${NC} THE USER MAY ALREADY EXIST IN THE INSTANCE.\n${YELLOW}STEP STATUS: ${RED}FAILED!${END}"
       exit 1
    elif [[ $INSTANCE_IDENTIFIER == "" ]];
    then
        echo -e "${RED}FAILED TO RETRIEVE INSTANCE IDENTIFIER!${NC} THE USER MAY ALREADY EXIST IN THE INSTANCE.\n${YELLOW}STEP STATUS: ${RED}FAILED!${END}"
        exit 1
    fi
fi

if [[ $INSTANCE_IDENTIFIER == "" ]];
then
    echo -e "${RED}FAILED TO RETRIEVE INSTANCE IDENTIFIER!${NC} I DON'T KNOW WHATS WRONG :(\n${YELLOW}STEP STATUS: ${RED}FAILED!${END}"
    exit 1
else
    echo -e "${GREEN}SUCCESS!${NC} INSTANCE ID AND IDENTIFIER RETRIEVED!"
    echo -e "${BLUE}THE INSTANCE ID IS:${NC} ${INSTANCE_ID}"
    echo -e "${BLUE}THE INSTANCE IDENTIFIER IS:${NC} ${INSTANCE_IDENTIFIER}"
fi

##################################################################################################################

#Gets auth token
echo "RETRIEVING AUTHORIZATION TOKEN..."
GET_AUTH_TOKEN=$(curl -s --location "https://${CLUSTER_NAME}.generic.web/micro-service/connect/token" \
--header 'Content-Type: application/x-www-form-urlencoded' \
--data-urlencode 'grant_type=client_credentials' \
--data-urlencode "client_id=user@${INSTANCE_IDENTIFIER}" \
--data-urlencode 'client_secret={{SECRET}}' \
--data-urlencode 'response_type=token')

AUTH_TOKEN=$(echo $GET_AUTH_TOKEN | cut -d '"' -f 4)
if [[ $AUTH_TOKEN == "" ]]; 
then
    echo -e "${RED}FAILED TO RETRIEVE AUTHORIZATION TOKEN.${NC}"
    echo -e "${YELLOW}STEP STATUS: ${RED}FAILED!${END}"
    exit 1
else
    echo -e "${GREEN}SUCCESS!${NC} AUTHORIZATION TOKEN RETRIEVED!"
fi

##################################################################################################################

#generates invite link
echo "GENERATING INVITATION LINK..."
GET_INVITE_LINK=$(curl -s --location "https://${CLUSTER_NAME}.generic.web/micro-service/api/Identities/RequestInvitationLink" \
--header 'Content-Type: application/json' \
--header "Authorization: Bearer ${AUTH_TOKEN}" \
--data-raw '{
  "email": "'${CLIENT_EMAIL}'",
  "INSTANCEId": "'${INSTANCE_ID}'"
}')

INVITE_LINK=$(echo $GET_INVITE_LINK | cut -d '"' -f 4)
if echo $INVITE_LINK | grep -q "https://";
then
    echo -e "${GREEN}SUCCESS!${NC} INVITATION LINK CREATED.\nSEND THIS TO THE CLIENT:${GRAY}\n.\n${YELLOW}${INVITE_LINK}${END}"
else
    echo -e "${RED}FAILED TO CREATE INVITATION LINK.${NC}"
    echo -e "${YELLOW}STEP STATUS: ${RED}FAILED!${END}"
    exit 1
fi

##################################################################################################################