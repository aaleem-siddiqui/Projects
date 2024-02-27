#!/bin/bash
ORANGE='\033[0;33m';GRAY='\033[1;30m';RED='\033[1;31m';GREEN='\033[1;32m';YELLOW='\033[1;33m';BLUE='\033[1;34m';PURPLE='\033[1;35m';NC='\033[0m'
END="${GRAY}\n.\n.\n${PURPLE}------------------------------------------------------------------------------------"
OL="${GRAY}.\n${ORANGE}----------------${NC}"


while getopts ":e:c:t:y:z:" option; do
  case $option in
    e)
      CLIENT_EMAIL="$OPTARG"
      ;;
    c)
      CLUSTER_NAME="$OPTARG"
      ;;
    t)
      TENANT_NAME="$OPTARG"
      ;;
    y)
      ADMIN_TOKEN_SECRET="$OPTARG"
      ;;
    z)
      AUTH_TOKEN_SECRET="$OPTARG"
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
elif [[ $TENANT_NAME == "" ]];
then
	echo -e "${RED}\nMISSING ARGUMENT!\nTENANT NAME NOT PROVIDED.${END}"
	exit 1
elif [[ $CLIENT_EMAIL == "" ]];
then
	echo -e "${RED}\nMISSING ARGUMENT!\nCLIENT EMAIL NOT PROVIDED.${END}"
	exit 1
elif [[ $ADMIN_TOKEN_SECRET == "" || $AUTH_TOKEN_SECRET == "" ]];
then
	echo -e "${RED}\nMISSING ARGUMENT!\nADMIN OR AUTH TOKEN SECRETS NOT PULLED FROM CI/CD VARIABLES.\nPLEASE NAVIGATE TO SETTINGS > CI/CD > VARIABLES AND MAKE SURE THEY EXIST.${END}"
	exit 1
fi


##################################################################################################################
#Intro

echo -e "${PURPLE}------------------------------------------------------------------------------------${GRAY}\n.\n.\n\t\t${YELLOW}GENERATE INITIAL SIGNUP LINK${GRAY}\n.${NC}"
echo -e "${OL}${GRAY}\n.\n${NC}PIPELINE PARAMETERS:${GRAY}\n."
echo -e "${BLUE}ROOT TENANT:$NC $TENANT_NAME"
echo -e "${BLUE}USER EMAIL:$NC $CLIENT_EMAIL"
echo -e "${BLUE}CLUSTER NAME:$NC $CLUSTER_NAME"
echo -e "${OL}${GRAY}\n.${NC}"

##################################################################################################################

#Retrieves an admin token
echo "RETRIEVING ADMIN TOKEN..."
GET_ADMIN_TOKEN=$(curl -s --location "https://${CLUSTER_NAME}.softwareName.companyName/softwareNameconnect/token" \
--header 'Content-Type: application/x-www-form-urlencoded' \
--data-urlencode 'grant_type=client_credentials' \
--data-urlencode "client_id=systemadmin@${TENANT_NAME}" \
--data-urlencode "client_secret=$ADMIN_TOKEN_SECRET" \
--data-urlencode 'response_type=token')

ADMIN_TOKEN=$(echo $GET_ADMIN_TOKEN | cut -d '"' -f 4)
if echo $GET_ADMIN_TOKEN | grep -q "access_token";
then
    echo -e "${GREEN}SUCCESS!${NC} ADMIN TOKEN RETRIEVED!"
else
    echo -e "${RED}FAILED TO RETRIEVE ADMIN TOKEN.${NC}\nDOUBLE CHECK THE CLUSTER NAME OR TENANT NAME VARIABLES. MAKE SURE THEY EXIST."
    echo -e "${YELLOW}STEP STATUS: ${RED}FAILED!${END}"
    exit 1
fi

##################################################################################################################

#Gets tenant ID and identifier 
echo "RETRIEVING TENANT INFO..."
GET_TENANT_INFO=$(curl -s --location "https://${CLUSTER_NAME}.softwareName.companyName/api/tenants" \
--header "Authorization: Bearer ${ADMIN_TOKEN}")

TENANT_ID=$(echo ${GET_TENANT_INFO} | grep -oE ".{0,300}${CLIENT_EMAIL}.{0,200}" | grep -oP '"id"\s*:\s*"\K[^"]*')
TENANT_IDENTIFIER=$(echo ${GET_TENANT_INFO} | grep -oE ".{0,300}${CLIENT_EMAIL}.{0,200}" | grep -oP '"tenantIdentifier"\s*:\s*"\K[^"]*')
TENANT_ID_COUNT=$(echo -n "$TENANT_ID" | wc -c)

if [[ $TENANT_ID_COUNT -lt 30 || $TENANT_ID_COUNT -gt 40 ]];
then
    echo -e "${RED}FAILED TO RETRIEVE TENANT ID!${NC}\nTHE EMAIL PROVIDED MAY NOT BE THE TENANT OWNER.\nTRYING TO SEARCH USING THE TENANT NAME INSTEAD OF THE EMAIL PROVIDED..."
    TENANT_ID=$(echo ${GET_TENANT_INFO} | grep -oP ".{0,350}\"tenantIdentifier\":\"${TENANT_NAME}\".{0,50}" | grep -oP '"id"\s*:\s*"\K[^"]*')
    TENANT_IDENTIFIER=$(echo ${GET_TENANT_INFO} | grep -oE ".{0,300}${TENANT_NAME}.{0,200}" | grep -oP '"tenantIdentifier"\s*:\s*"\K[^"]*')
    TENANT_ID_COUNT=$(echo -n "$TENANT_ID" | wc -c)
    if [[ $TENANT_ID_COUNT -lt 30 || $TENANT_ID_COUNT -gt 40 ]];
    then
       echo -e "${RED}FAILED TO RETRIEVE TENANT ID AGAIN!${NC} THE USER MAY ALREADY EXIST IN THE TENANT.\n${YELLOW}STEP STATUS: ${RED}FAILED!${END}"
       exit 1
    elif [[ $TENANT_IDENTIFIER == "" ]];
    then
        echo -e "${RED}FAILED TO RETRIEVE TENANT IDENTIFIER!${NC} THE USER MAY ALREADY EXIST IN THE TENANT.\n${YELLOW}STEP STATUS: ${RED}FAILED!${END}"
        exit 1
    fi
fi

if [[ $TENANT_IDENTIFIER == "" ]];
then
    echo -e "${RED}FAILED TO RETRIEVE TENANT IDENTIFIER!${NC} I DON'T KNOW WHATS WRONG :(\n${YELLOW}STEP STATUS: ${RED}FAILED!${END}"
    exit 1
else
    echo -e "${GREEN}SUCCESS!${NC} TENANT ID AND IDENTIFIER RETRIEVED!"
    echo -e "${BLUE}THE TENANT ID IS:${NC} ${TENANT_ID}"
    echo -e "${BLUE}THE TENANT IDENTIFIER IS:${NC} ${TENANT_IDENTIFIER}"
fi



##################################################################################################################

#Gets auth token
echo "RETRIEVING AUTHORIZATION TOKEN..."
GET_AUTH_TOKEN=$(curl -s --location "https://${CLUSTER_NAME}.softwareName.companyName/softwareNameconnect/token" \
--header 'Content-Type: application/x-www-form-urlencoded' \
--data-urlencode 'grant_type=client_credentials' \
--data-urlencode "client_id=companyName.suite.services@${TENANT_IDENTIFIER}" \
--data-urlencode "client_secret=$AUTH_TOKEN_SECRET" \
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
GET_INVITE_LINK=$(curl -s --location "https://${CLUSTER_NAME}.softwareName.companyName/softwareNameapi/Identities/RequestInvitationLink" \
--header 'Content-Type: application/json' \
--header "Authorization: Bearer ${AUTH_TOKEN}" \
--data-raw '{
  "email": "'${CLIENT_EMAIL}'",
  "tenantId": "'${TENANT_ID}'"
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
