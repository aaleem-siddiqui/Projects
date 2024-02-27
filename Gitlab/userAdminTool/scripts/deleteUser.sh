#!/bin/bash
ORANGE='\033[0;33m';GRAY='\033[1;30m';RED='\033[1;31m';GREEN='\033[1;32m';YELLOW='\033[1;33m';BLUE='\033[1;34m';PURPLE='\033[1;35m';NC='\033[0m'
END="${GRAY}\n.\n.\n${PURPLE}------------------------------------------------------------------------------------"
RL="${GRAY}\n.\n${RED}----------------${GRAY}\n.\n${NC}"
OL="${GRAY}.\n${ORANGE}----------------${NC}"

#vars passed from pipeline
while getopts ":n:e:p:c:y:" option; do
  case $option in
    n)
      ROOT_TENANT="$OPTARG"
      ;;
    e)
      USER_EMAIL="$OPTARG"
      ;;
    c)
      CLUSTER_NAME="$OPTARG"
      ;;
    y)
      ADMIN_TOKEN_SECRET="$OPTARG"
      ;;
    *)
      echo -e "${RED}\nMISSING ARGUMENTS! EXITING SCRIPT...${END}"
      exit 1
      ;;
  esac
done

#flag failsafes 
if [[ $ROOT_TENANT == "" ]];
then
	echo -e "${RED}\nMISSING ARGUMENT!\nROOT TENANT NOT PROVIDED.${END}"
	exit 1
elif [[ $USER_EMAIL == "" ]];
then
	echo -e "${RED}\nMISSING ARGUMENT!\nCUSTOMER EMAIL NOT PROVIDED.${END}"
	exit 1
elif [[ $CLUSTER_NAME == "" ]];
then
	echo -e "${RED}\nMISSING ARGUMENT!\nCLUSTER NAME NOT PROVIDED.${END}"
	exit 1
elif [[ $ADMIN_TOKEN_SECRET == "" ]];
then
	echo -e "${RED}\nMISSING ARGUMENT!\nADMIN TOKEN SECRET NOT PULLED FROM CI/CD VARIABLES.\nPLEASE NAVIGATE TO SETTINGS > CI/CD > VARIABLES AND MAKE SURE IT EXISTS.${END}"
	exit 1
fi

##################################################################################################################
#Intro

echo -e "${PURPLE}------------------------------------------------------------------------------------${GRAY}\n.\n.\n\t\t${YELLOW}DELETE USER${GRAY}\n.${NC}"
echo -e "${OL}${GRAY}\n.\n${NC}PIPELINE PARAMETERS:${GRAY}\n."
echo -e "${BLUE}ROOT TENANT:$NC $ROOT_TENANT"
echo -e "${BLUE}USER EMAIL:$NC $USER_EMAIL"
echo -e "${BLUE}CLUSTER NAME:$NC $CLUSTER_NAME"
echo -e "${OL}${GRAY}\n.${NC}"

###########################################################################################################################################################
#-------------------- Get admin token for the ROOT TENANT --------------------#

echo -e "RETRIEVING ADMIN TOKEN FOR TENANT..."
GET_ADMIN_TOKEN=$(curl -s --location "https://${CLUSTER_NAME}.softwareName.companyName/softwareNameconnect/token" \
--header 'Content-Type: application/x-www-form-urlencoded' \
--data-urlencode 'grant_type=client_credentials' \
--data-urlencode "client_id=systemadmin@${ROOT_TENANT}" \
--data-urlencode "client_secret=$ADMIN_TOKEN_SECRET" \
--data-urlencode 'response_type=token')

ADMIN_TOKEN=$(echo $GET_ADMIN_TOKEN | cut -d '"' -f 4)
if echo $GET_ADMIN_TOKEN | grep -q "access_token";
then
    echo -e "${GREEN}SUCCESS!${NC} ADMIN TOKEN RETRIEVED!"
else
    echo -e "${RED}FAILED TO RETRIEVE ADMIN TOKEN.${NC}\nDOUBLE CHECK THE CLUSTER NAME OR ROOT TENANT NAME VARIABLES. MAKE SURE THEY EXIST."
    echo -e "${YELLOW}STEP STATUS: ${RED}FAILED!"
    echo -e "${RL}\tTROUBLESHOOTING\n${RED}ADMIN TOKEN REQUEST RESPONSE:${NC}\n${GET_ADMIN_TOKEN}${END}"
    exit 1
fi

###########################################################################################################################################################
#-------------------- Get user ID from the ROOT TENANT --------------------#

echo -e "RETRIEVING USER ID FROM TENANT..."
GET_USER_INFO_FROM_TENANT=$(curl -s --location "https://${CLUSTER_NAME}.softwareName.companyName/api/Users/" \
--header "Authorization: Bearer ${ADMIN_TOKEN}")

USER_ID=$(echo ${GET_USER_INFO_FROM_TENANT} | grep -oEi ".{0,150}${USER_EMAIL}.{0,50}" | grep -oP '"id"\s*:\s*"\K[^"]*')
if [[ $USER_ID == "" ]];
then
    echo -e "${RED}FAILED TO GET USER ID.${NC}"
    echo -e "${YELLOW}STEP STATUS: ${RED}FAILED!${END}"
    exit 1
else
    echo -e "${GREEN}SUCCESS!${NC} USER ID RETRIEVED FOR ROOT TENANT!"
    echo -e "${BLUE}THE USER ID IS:${NC} ${USER_ID}"
fi

###########################################################################################################################################################
#-------------------- Delete user from tenant --------------------#

echo -e "DELETING USER..."
DELETE_USER=$(curl -s --location --request DELETE "https://${CLUSTER_NAME}.softwareName.companyName/api/Users/$USER_ID" \
--header 'Content-Type: application/json' \
--header "Authorization: Bearer ${ADMIN_TOKEN}" \
--data '{
    "userId": "'$USER_ID'"
}')

GET_USER_INFO_FROM_TENANT=$(curl -s --location "https://${CLUSTER_NAME}.softwareName.companyName/api/Users/" \
--header "Authorization: Bearer ${ADMIN_TOKEN}")

if echo $GET_USER_INFO_FROM_TENANT | grep -q "$USER_ID";
then
    echo -e "${RED}FAILED TO DELETE USER.${NC}."
    echo -e "${YELLOW}STEP STATUS: ${RED}FAILED!$END"
    exit 1
else
    echo -e "${GREEN}SUCCESS!${NC} USER DELETED!$END"
fi
