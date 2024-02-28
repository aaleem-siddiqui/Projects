#!/bin/bash
ORANGE='\033[0;33m';GRAY='\033[1;30m';RED='\033[1;31m';GREEN='\033[1;32m';YELLOW='\033[1;33m';BLUE='\033[1;34m';PURPLE='\033[1;35m';NC='\033[0m'
END="${GRAY}\n.\n.\n${PURPLE}------------------------------------------------------------------------------------"
RL="${GRAY}\n.\n${RED}----------------${GRAY}\n.\n${NC}"
OL="${GRAY}.\n${ORANGE}----------------${NC}"


#vars passed from pipeline
while getopts ":n:e:f:l:p:c:g:y:z:" option; do
  case $option in
    n)
      ROOT_TENANT="$OPTARG"
      ;;
    e)
      USER_EMAIL="$OPTARG"
      ;;
    f)
      FIRST_NAME="$OPTARG"
      ;;
    l)
      LAST_NAME="$OPTARG"
      ;;
    p)
      PASSWORD="$OPTARG"
      ;;
    c)
      CLUSTER_NAME="$OPTARG"
      ;;
    g)
      GROUP_ASSIGNMENT="$OPTARG"
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
if [[ $ROOT_TENANT == "" ]];
then
	echo -e "${RED}\nMISSING ARGUMENT!\ROOT TENANT NOT PROVIDED.${END}"
	exit 1
elif [[ $USER_EMAIL == "" ]];
then
	echo -e "${RED}\nMISSING ARGUMENT!\nCUSTOMER EMAIL NOT PROVIDED.${END}"
	exit 1
elif [[ $FIRST_NAME == "" ]];
then
	echo -e "${RED}\nMISSING ARGUMENT!\nFIRST NAME NOT PROVIDED.${END}"
    exit 1
elif [[ $LAST_NAME == "" ]];
then
	echo -e "${RED}\nMISSING ARGUMENT!\nLAST NAME NOT PROVIDED.${END}"
	exit 1
elif [[ $CLUSTER_NAME == "" ]];
then
	echo -e "${RED}\nMISSING ARGUMENT!\nCLUSTER NAME NOT PROVIDED.${END}"
	exit 1
elif [[ $GROUP_ASSIGNMENT == "" ]];
then
	echo -e "${RED}\nMISSING ARGUMENT!\nGROUP ASSIGNMENT NOT PROVIDED.${END}"
	exit 1
elif [[ $ADMIN_TOKEN_SECRET == "" || $AUTH_TOKEN_SECRET == "" ]];
then
	echo -e "${RED}\nMISSING ARGUMENT!\nADMIN OR AUTH TOKEN SECRETS NOT PULLED FROM CI/CD VARIABLES.\nPLEASE NAVIGATE TO SETTINGS > CI/CD > VARIABLES AND MAKE SURE THEY EXIST.${END}"
	exit 1
fi

##################################################################################################################
#Intro

echo -e "${PURPLE}------------------------------------------------------------------------------------${GRAY}\n.\n.\n\t\t${YELLOW}SINGLE-TENANT USER CREATION${GRAY}\n.${NC}"
echo -e "${OL}${GRAY}\n.\n${NC}PIPELINE PARAMETERS:${GRAY}\n."
echo -e "${BLUE}ROOT TENANT:$NC $ROOT_TENANT"
echo -e "${BLUE}USER EMAIL:$NC $USER_EMAIL"
echo -e "${BLUE}FIRST NAME:$NC $FIRST_NAME"
echo -e "${BLUE}LAST NAME:$NC $LAST_NAME"
if [[ $PASSWORD != "-" || $PASSWORD != "" ]];
then
    DISPLAY_PASSWORD=''
    for (( i = 0; i < ${#PASSWORD}; i++ )); do
        DISPLAY_PASSWORD+="*"
    done
    echo -e "${BLUE}PASSWORD:$NC $DISPLAY_PASSWORD"
else
    echo -e "${BLUE}PASSWORD:$RED NULL$NC"
fi
echo -e "${BLUE}CLUSTER NAME:$NC $CLUSTER_NAME"
echo -e "${BLUE}GROUP ASSIGNMENT:$NC $GROUP_ASSIGNMENT"
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
#-------------------- Add user --------------------#
echo -e "ADDING USER TO TENANT..."
ADD_USER=$(curl -s --location "https://${CLUSTER_NAME}.softwareName.companyName/api/v5/Users" \
--header 'Content-Type: application/json' \
--header "Authorization: Bearer $ADMIN_TOKEN" \
--data-raw '{
  "firstName": "'$FIRST_NAME'",
  "lastName": "'$LAST_NAME'",
  "userName": "'$USER_EMAIL'",
  "email": "'$USER_EMAIL'",
  "sendConfirmationEmail": "false",
  "status": 1,
  "description": ""
}')

if echo $ADD_USER | grep -q "emailConfirmed";
then
    echo -e "${GREEN}SUCCESS!${NC} USER ADDED!"
elif echo $ADD_USER | grep -q "UserNameNotUnique" || echo $ADD_USER | grep -q "EmailNotUnique";
then
    echo -e "${RED}FAILED TO ADD USER.${NC}\nTHE USER MAY ALREADY EXIST IN THE TENANT."
    echo -e "${YELLOW}STEP STATUS: ${RED}FAILED!"
    echo -e "${RL}\tTROUBLESHOOTING\n${RED}ADD USER RESPONSE:${NC}\n${ADD_USER}${END}"
    exit 1
else 
    echo -e "${RED}FAILED TO ADD USER.${NC}\n"
    echo -e "${YELLOW}STEP STATUS: ${RED}FAILED!"
    echo -e "${RL}\tTROUBLESHOOTING\n${RED}ADD USER RESPONSE:${NC}\n${ADD_USER}${END}"
    exit 1
fi

###########################################################################################################################################################
#-------------------- Get user ID from the ROOT TENANT --------------------#

GET_USER_INFO_FROM_TENANT=$(curl -s --location "https://${CLUSTER_NAME}.softwareName.companyName/api/Users/" \
--header "Authorization: Bearer ${ADMIN_TOKEN}")

USER_ID=$(echo ${GET_USER_INFO_FROM_TENANT} | grep -oEi ".{0,150}$(sed 's/[^a-zA-Z0-9]/\\&/g' <<< "${USER_EMAIL}").{0,50}" | grep -oP '"id"\s*:\s*"\K[^"]*')
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
#-------------------- Get group assignment ID --------------------#

echo -e "SELECTED GROUP ASSIGNMENT: ${YELLOW}${GROUP_ASSIGNMENT}${NC}"
echo -e "RETRIEVING GROUP ASSIGNMENT ID..."
GET_GROUP_ASSIGNMENT_ID=$(curl -s --location "https://${CLUSTER_NAME}.softwareName.companyName/api/Groups" \
--header "Authorization: Bearer ${ADMIN_TOKEN}")

GROUP_ASSIGNMENT_ID=$(echo ${GET_GROUP_ASSIGNMENT_ID} | grep -oE ".{0,55}${GROUP_ASSIGNMENT}.{0,5}" | grep -oP '"id"\s*:\s*"\K[^"]*')

if [[ $GROUP_ASSIGNMENT_ID == "" ]];
then
    echo -e "${RED}FAILED TO GET GROUP ASSIGNMENT ID.${NC}\nMAKE SURE THE GROUP ASSIGNMENT VARIABLE IS ONE OF THE FOLLOWING: ${GREEN}Administrator${NC} | ${GREEN}User${NC} | ${GREEN}Visitor${NC}"
    echo -e "${YELLOW}STEP STATUS: ${RED}FAILED!${END}"
    exit 1
else
    echo -e "${GREEN}SUCCESS!${NC} GROUP ASSIGNMENT ID RETRIEVED!"
    echo -e "${BLUE}THE GROUP ASSIGNMENT ID IS:${NC} ${GROUP_ASSIGNMENT_ID}"
fi

###########################################################################################################################################################
#-------------------- Update group assignment --------------------#

echo -e "UPDATING GROUP ASSIGNMENT IN TENANT: ${YELLOW}${ROOT_TENANT}${NC}"
POST_GROUP_ASSIGNMENT=$(curl -s --location "https://${CLUSTER_NAME}.softwareName.companyName/api/UserGroups" \
--header 'Content-Type: application/json' \
--header "Authorization: Bearer ${ADMIN_TOKEN}" \
--data '{
    "userId": "'${USER_ID}'",
    "groupId": "'${GROUP_ASSIGNMENT_ID}'"
}')

GET_USER_INFO_FROM_TENANT=$(curl -s --location "https://${CLUSTER_NAME}.softwareName.companyName/api/Users/" \
--header "Authorization: Bearer ${ADMIN_TOKEN}")

echo -e "VALIDATING SUCCESS..."
GET_GROUPS=$(echo ${GET_USER_INFO_FROM_TENANT} | grep -oEi ".{0,10}$(sed 's/[^a-zA-Z0-9]/\\&/g' <<< "${USER_EMAIL}").{0,300}" | grep -oP '"groups"\s*:\s*\[\K[^]]*')
if echo $GET_GROUPS | grep -q "${GROUP_ASSIGNMENT}";
then
    echo -e "${GREEN}SUCCESS!${NC} GROUP ASSIGNMENT UPDATED!"
else
    echo -e "${RED}FAILED TO UPDATE GROUP ASSIGNMENT.${NC}\nDURING VALIDATION THE CHOSEN GROUP ASSIGNMENT WAS NOT FOUND UNDER THE USER IN THE ROOT TENANT."
    echo -e "${YELLOW}STEP STATUS: ${RED}FAILED!"
    echo -e "${RL}\tTROUBLESHOOTING\n${RED}USER INFO FROM TENANT:${NC}\n${GET_USER_INFO_FROM_TENANT}${RED}\nGROUPS PARSED:${NC}\n${GET_GROUPS}${END}"
    exit 1
fi

###########################################################################################################################################################
#-------------------- Get Auth token --------------------#

echo -e "RETRIEVING AUTHORIZATION TOKEN..."
GET_AUTH_TOKEN=$(curl -s --location "https://${CLUSTER_NAME}.softwareName.companyName/softwareNameconnect/token" \
--header 'Content-Type: application/x-www-form-urlencoded' \
--data-urlencode 'grant_type=client_credentials' \
--data-urlencode "client_id=companyName.suite.services@${ROOT_TENANT}" \
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

###########################################################################################################################################################
#-------------------- Patch password --------------------#

if [[ $PASSWORD == "-" || $PASSWORD == "" ]];
then
    echo -e "${RED}PASSWORD NOT PROVIDED.${NC}"
fi

while true; do
    if [[ $PASSWORD == "-" || $PASSWORD == "" ]];
    then
        echo -e "DEFAULTING PASSWORD TO:$BLUE Firststart#123$NC"
        PASSWORD='Firststart#123'
    fi

    echo -e "PATCHING PASSWORD..."

    USER_IDENTITY_ID=$(echo ${GET_USER_INFO_FROM_TENANT} | grep -oEi ".{0,100}$(sed 's/[^a-zA-Z0-9]/\\&/g' <<< "${USER_EMAIL}").{0,300}" | grep -oP '"identityId"\s*:\s*"\K[^"]*')
    PATCH_PASSWORD=$(curl -s -w "%{http_code}" --location --request PATCH "https://${CLUSTER_NAME}.softwareName.companyName/softwareNameapi/Identities/${USER_IDENTITY_ID}/UpdatePassword" \
    --header 'Content-Type: application/json' \
    --header "Authorization: Bearer $AUTH_TOKEN" \
    --data ' {
        "id": "'$USER_IDENTITY_ID'",
        "password":"'$PASSWORD'",
        "confirmPassword":"'$PASSWORD'"
    }')

    STATUS_CODE="${PATCH_PASSWORD##*]}"

    if [[ $PATCH_PASSWORD == "202" ]]; 
    then
        echo -e "${GREEN}SUCCESS!${NC} PASSWORD PATCHED!"
        echo -e "${GREEN}SCRIPT COMPLETE.${END}"
        exit 0
    elif [[ $STATUS_CODE == "400" ]];
    then
        PASSWORD_REQUIREMENTS=$(echo "$PATCH_PASSWORD" | grep -oP '"description":"\K[^"]+' | tr '\n' ' ' | sed 's/\.\s*/.\\n/g')
        echo -e "\n${RED}THE PROVIDED PASSWORD $NC\"$PASSWORD\"$RED DOES NOT MEET REQUIREMENTS:$NC\n$PASSWORD_REQUIREMENTS"
        PASSWORD=''
    else
        echo -e "${RED}FAILED TO PATCH PASSWORD.${NC}"
        echo -e "${YELLOW}STEP STATUS: ${RED}FAILED!${END}"
        exit 1
    fi
done
