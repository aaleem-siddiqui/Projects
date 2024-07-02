#!/bin/bash

ORANGE='\033[0;33m';GRAY='\033[1;30m';RED='\033[1;31m';GREEN='\033[1;32m';YELLOW='\033[1;33m';BLUE='\033[1;36m';PURPLE='\033[1;35m';NC='\033[0m'
END="${GRAY}\n.\n.\n${PURPLE}------------------------------------------------------------------------------------"
OL="${GRAY}\n.\n.\n${ORANGE}------------------------$NC$GRAY\n.\n.$NC"
RL="${GRAY}\n.\n.\n${NC}"
###########################################################################################################################################################
##-------------------vars passed from pipeline-------------------------#
while getopts ":c:n:y:x:b:d:s:" option; do
  case $option in
    c)
      CLUSTER_NAME="$OPTARG"
      ;;
    n)
      INSTANCE_NAME="$OPTARG"
      ;;
    y)
      ADMIN_TOKEN_SECRET="$OPTARG"
      ;;
    x)
      ADMIN_TOKEN_ENTITLEMENT_SECRET="$OPTARG"
      ;;
    b)
      PATCH_AUTH_TOKEN_SECRET="$OPTARG"
      ;;
    d)
      ACTIVATION_ID="$OPTARG"
      ;;                                                  
    s)
      USER_EMAIL="$OPTARG"
      ;;
    *)
      echo -e "${RED}\nMISSING ARGUMENTS! EXITING SCRIPT...${END}"
      exit 1
      ;;
  esac
done

#---------------------------------
FIRST_NAME="Support"
LAST_NAME="User"
PASSWORD=""
GROUP_ASSIGNMENT="Administrator" 
#---------------------------------

##-----------------flag failsafes---------------------#
if [[ -z "$CLUSTER_NAME" ]];
then
	echo -e "${RED}\nMISSING ARGUMENT!\CLUSTER NAME NOT PROVIDED.${END}"
	exit 1
elif [[ -z "$INSTANCE_NAME" ]];
then
	echo -e "${RED}\nMISSING ARGUMENT!\nINSTANCE NAME NOT PROVIDED.${END}"
	exit 1 
elif [[ -z "$ADMIN_TOKEN_SECRET" ]];
then
	echo -e "${RED}\nMISSING ARGUMENT!\nADMIN OR AUTH TOKEN SECRETS NOT PULLED FROM CI/CD VARIABLES.\nPLEASE NAVIGATE TO SETTINGS > CI/CD > VARIABLES AND MAKE SURE THEY EXIST.${END}"
	exit 1
elif [[ -z "$ADMIN_TOKEN_ENTITLEMENT_SECRET" ]];
then
	echo -e "${RED}\nMISSING ARGUMENT!\nADMIN OR AUTH TOKEN SECRETS NOT PULLED FROM CI/CD VARIABLES.\nPLEASE NAVIGATE TO SETTINGS > CI/CD > VARIABLES AND MAKE SURE THEY EXIST.${END}"
	exit 1
elif [[ -z "$PATCH_AUTH_TOKEN_SECRET" ]];
then
	echo -e "${RED}\nMISSING ARGUMENT!\nADMIN OR AUTH TOKEN SECRETS NOT PULLED FROM CI/CD VARIABLES.\nPLEASE NAVIGATE TO SETTINGS > CI/CD > VARIABLES AND MAKE SURE THEY EXIST.${END}"
	exit 1
elif [[ -z "$ACTIVATION_ID" ]];
then
	echo -e "${RED}\nMISSING ARGUMENT!\nACTIVATION ID NOT PROVIDED.${END}"
	exit 1
elif [[ -z "$USER_EMAIL" ]];
then
	echo -e "${RED}\nMISSING ARGUMENT!\nUSER EMAIL NOT PROVIDED.${END}"
	exit 1
elif [[ -z "$FIRST_NAME" ]];
then
	echo -e "${RED}\nMISSING ARGUMENT!\nFIRST NAME NOT PROVIDED.${END}"
	exit 1
elif [[ -z "$LAST_NAME" ]];
then
	echo -e "${RED}\nMISSING ARGUMENT!\nLAST NAME NOT PROVIDED.${END}"
	exit 1
elif [[ -z "$GROUP_ASSIGNMENT" ]];
then
	echo -e "${RED}\nMISSING ARGUMENT!\nGROUP ASSIGNMENT NOT PROVIDED.${END}"
	exit 1
fi


###########################################################################################################################################################
##-----------------------------PIPELINE PARAMETERS----------------------------##
echo -e "${PURPLE}------------------------------------------------------------------------------------${GRAY}\n.\n.\n\t\t${YELLOW}CREATE INSTANCE${GRAY}\n.${NC}"
echo -e "${OL}${GRAY}\n.\n${NC}PIPELINE PARAMETERS:${GRAY}\n."
echo -e "${BLUE}ROOT INSTANCE:$NC $INSTANCE_NAME"
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
echo -e "${BLUE}ACTIVATION ID:$NC $ACTIVATION_ID"
echo -e "${BLUE}CLUSTER NAME:$NC $CLUSTER_NAME"
echo -e "${BLUE}GROUP ASSIGNMENT:$NC $GROUP_ASSIGNMENT"
echo -e "${OL}${GRAY}\n.${NC}"

###########################################################################################################################################################
##-------------------- Get Admin Token For INSTANCE Creation--------------------#
echo "RETRIEVING ADMIN TOKEN"
GET_ADMIN_TOKEN=$(curl -s --location "https://${CLUSTER_NAME}../servicename/connect/token" \
--header 'Content-Type: application/x-www-form-urlencoded' \
--data-urlencode 'grant_type=client_credentials' \
--data-urlencode "client_id=systemadmin@system" \
--data-urlencode "client_secret=$ADMIN_TOKEN_SECRET" \
--data-urlencode 'response_type=token')

##-----------------Filter and Validate Token------------------#
ADMIN_TOKEN=$(echo $GET_ADMIN_TOKEN | cut -d '"' -f 4)
if echo $GET_ADMIN_TOKEN | grep -q "access_token";
then
    echo -e "${GREEN}SUCCESS!${NC} ADMIN TOKEN RETRIEVED!"
else
    echo -e "${RED}FAILED TO RETRIEVE ADMIN TOKEN.${NC}\nDOUBLE CHECK THE CLUSTER NAME VARIABLE. MAKE SURE IT EXISTS."
    echo -e "${YELLOW}STEP STATUS: ${RED}FAILED!"
    echo -e "${RL}\tTROUBLESHOOTING\n${RED}ADMIN TOKEN REQUEST RESPONSE:${NC}\n${GET_ADMIN_TOKEN}${END}"
    exit 1
fi

###########################################################################################################################################################
##-------------------- Create INSTANCE Request--------------------#
echo -e "${ORANGE}INSTANCE CREATION STARTED${NC}"

INSTANCE_CREATE=$(curl -s -w "%{http_code}" --location "https://${CLUSTER_NAME}../INSTANCEmanagement/api/INSTANCEs" \
--header 'Content-Type: application/json' \
--header "Authorization: Bearer $ADMIN_TOKEN" \
--data '{
  "name": "'$INSTANCE_NAME'",
  "INSTANCEType": "SPECIAL",
  "shortName": "'$INSTANCE_NAME'",
  "INSTANCEIdentifier": "'$INSTANCE_NAME'",
  "active": true,
  "licenseTermsAccepted": true
}')

STATUS_INSTANCE_CREATE="${INSTANCE_CREATE: -3}"
INSTANCE_ID=$(echo "$INSTANCE_CREATE" | grep -o '"id":"[^"]*' | cut -d '"' -f 4)

echo "INSTANCE ID: $INSTANCE_ID"


if [[ $STATUS_INSTANCE_CREATE == "200" ]];
then
    echo -e "THE CREATE INSTANCE API CALL IN ${CLUSTER_NAME} RETURNED A STATUS ${GREEN}200 OK$NC!"
                                                                                                       #ADD DOUBLE CHECK FEATURE 
else
    echo -e "${RED}FAILED TO CREATE INSTANCE IN $CLUSTER_NAME.${NC}."
    echo -e "THE CREATE INSTANCE API CALL RETURNED A STATUS: $STATUS_INSTANCE_CREATE"
    echo -e "STEP STATUS: ${RED}FAILED!${NC}"
fi

echo -e "${ORANGE}INSTANCE CREATION DONE${NC}"

###########################################################################################################################################################
##-------------------- Get admin token for the ENTITLEMENT--------------------#
echo "RETRIEVING ENTITLEMENT ADMIN TOKEN"
GET_ADMIN_TOKEN_ENTITLEMENT=$(curl -s --location "https://${CLUSTER_NAME}../servicename/connect/token" \
--header 'Content-Type: application/x-www-form-urlencoded' \
--data-urlencode 'grant_type=client_credentials' \
--data-urlencode 'client_id=-management@system' \
--data-urlencode "client_secret=$ADMIN_TOKEN_ENTITLEMENT_SECRET" \
--data-urlencode 'response_type=token')



##-----------------Filter and Validate Token------------------#
ADMIN_TOKEN_ENTITLEMENT=$(echo $GET_ADMIN_TOKEN_ENTITLEMENT | cut -d '"' -f 4)
if echo $GET_ADMIN_TOKEN_ENTITLEMENT | grep -q "access_token";
then
    echo -e "${GREEN}SUCCESS!${NC} ENTITLEMENT ADMIN TOKEN RETRIEVED!"
else
    echo -e "${RED}FAILED TO RETRIEVE ADMIN TOKEN.${NC}\nDOUBLE CHECK THE CLUSTER NAME VARIABLE. MAKE SURE IT EXISTS."
    echo -e "${YELLOW}STEP STATUS: ${RED}FAILED!"
    echo -e "${RL}\tTROUBLESHOOTING\n${RED}ENTITLEMENT ADMIN TOKEN REQUEST RESPONSE:${NC}\n${GET_ADMIN_TOKEN_ENTITLEMENT}${END}"
    exit 1
fi

#-----SLEEP TIME-----
echo -e "WAITING FOR ${PURPLE}30 SECONDS ${NC}BEFORE CONTINUING"
sleep 30

###########################################################################################################################################################
##-------------------- Entitlement Put Request--------------------#
echo -e "${ORANGE}ASSIGNING OF LAC PROCESS STARTED${NC}"
ENTITLEMENT_PUT=$(curl -s -w "%{http_code}" --location --request PUT "https://${CLUSTER_NAME}../servicename/api/Entitlements" \
--header 'Content-Type: application/json' \
--header "Authorization: Bearer $ADMIN_TOKEN_ENTITLEMENT" \
--data '{
    "INSTANCEId": "'$INSTANCE_ID'",
    "activationIds": [
        "'$ACTIVATION_ID'" 
    ]
}')

STATUS_ENTITLEMENT_PUT="${ENTITLEMENT_PUT: -3}"

if [[ $STATUS_ENTITLEMENT_PUT == "202" ]];
then
    echo -e "THE ENTITLEMENT PUT API CALL IN ${CLUSTER_NAME} RETURNED A STATUS ${GREEN}202 ACCEPTED$NC!"
                                                                                                          #ADD DOUBLE CHECK FEATURE 
else
    echo -e "${RED}FAILED TO ADD LAC TO $INSTANCE_NAME.${NC}."
    echo -e "THE ENTITLEMENT PUT API CALL RETURNED A STATUS: $STATUS_ENTITLEMENT_PUT"
    echo -e "${RED}CHECK ACTIVATION ID OF THE LAC"
    echo -e "STEP STATUS: ${RED}FAILED!${NC}"
    echo -e "${RL}\tTROUBLESHOOTING\n${RED}ENTITLEMENT PUT REQUEST RESPONSE:${NC}\n${ENTITLEMENT_PUT}${END}"
fi

echo -e "${ORANGE}ASSIGNING OF LAC PROCESS FINISHED${NC}"
echo -e "${ORANGE}INSTANCE ${INSTANCE_NAME} CREATED: ${NC}"


###########################################################################################################################################################
#-------------------- Get admin token for the ROOT INSTANCE --------------------#

echo -e "RETRIEVING ADMIN TOKEN FOR INSTANCE..."
GET_USER_ADMIN_TOKEN=$(curl -s --location "https://${CLUSTER_NAME}../servicename/connect/token" \
--header 'Content-Type: application/x-www-form-urlencoded' \
--data-urlencode 'grant_type=client_credentials' \
--data-urlencode "client_id=systemadmin@${INSTANCE_NAME}" \
--data-urlencode "client_secret=$ADMIN_TOKEN_SECRET" \
--data-urlencode 'response_type=token')

USER_ADMIN_TOKEN=$(echo $GET_USER_ADMIN_TOKEN | cut -d '"' -f 4)
if echo $GET_USER_ADMIN_TOKEN | grep -q "access_token";
then
    echo -e "${GREEN}SUCCESS!${NC} INSTANCE ADMIN TOKEN RETRIEVED!"
else
    echo -e "${RED}FAILED TO RETRIEVE ADMIN TOKEN.${NC}\nDOUBLE CHECK THE CLUSTER NAME OR ROOT INSTANCE NAME VARIABLES. MAKE SURE THEY EXIST."
    echo -e "${YELLOW}STEP STATUS: ${RED}FAILED!"
    echo -e "${RL}\tTROUBLESHOOTING\n${RED}ADMIN TOKEN REQUEST RESPONSE:${NC}\n${GET_USER_ADMIN_TOKEN}${END}"
    exit 1
fi

###########################################################################################################################################################
#-------------------- Add user --------------------#
echo -e "ADDING USER TO INSTANCE..."
ADD_USER=$(curl -s --location "https://${CLUSTER_NAME}../usermanagement/api/v5/Users" \
--header 'Content-Type: application/json' \
--header "Authorization: Bearer $USER_ADMIN_TOKEN" \
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
    echo -e "${RED}FAILED TO ADD USER.${NC}\nTHE USER MAY ALREADY EXIST IN THE INSTANCE."
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
#-------------------- Get user ID from the ROOT INSTANCE --------------------#

GET_USER_INFO_FROM_INSTANCE=$(curl -s --location "https://${CLUSTER_NAME}../usermanagement/api/Users/" \
--header "Authorization: Bearer ${USER_ADMIN_TOKEN}")

USER_ID=$(echo ${GET_USER_INFO_FROM_INSTANCE} | grep -oEi ".{0,150}$(sed 's/[^a-zA-Z0-9]/\\&/g' <<< "${USER_EMAIL}").{0,50}" | grep -oP '"id"\s*:\s*"\K[^"]*')
if [[ -z "$USER_ID" ]];
then
    echo -e "${RED}FAILED TO GET USER ID.${NC}"
    echo -e "${YELLOW}STEP STATUS: ${RED}FAILED!${END}"
    exit 1
else
    echo -e "${GREEN}SUCCESS!${NC} USER ID RETRIEVED FOR ROOT INSTANCE!"
    echo -e "${BLUE}THE USER ID IS:${NC} ${USER_ID}"
fi

###########################################################################################################################################################
#-------------------- Get group assignment ID --------------------#

echo -e "SELECTED GROUP ASSIGNMENT: ${YELLOW}${GROUP_ASSIGNMENT}${NC}"
echo -e "RETRIEVING GROUP ASSIGNMENT ID..."
GET_GROUP_ASSIGNMENT_ID=$(curl -s --location "https://${CLUSTER_NAME}../usermanagement/api/Groups" \
--header "Authorization: Bearer ${USER_ADMIN_TOKEN}")

GROUP_ASSIGNMENT_ID=$(echo ${GET_GROUP_ASSIGNMENT_ID} | grep -oE ".{0,55}${GROUP_ASSIGNMENT}.{0,5}" | grep -oP '"id"\s*:\s*"\K[^"]*')

if [[ -z "$GROUP_ASSIGNMENT_ID" ]];
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

echo -e "UPDATING GROUP ASSIGNMENT IN INSTANCE: ${YELLOW}${ROOT_INSTANCE}${NC}"
POST_GROUP_ASSIGNMENT=$(curl -s --location "https://${CLUSTER_NAME}../usermanagement/api/UserGroups" \
--header 'Content-Type: application/json' \
--header "Authorization: Bearer ${USER_ADMIN_TOKEN}" \
--data '{
    "userId": "'${USER_ID}'",
    "groupId": "'${GROUP_ASSIGNMENT_ID}'"
}')

GET_USER_INFO_FROM_INSTANCE=$(curl -s --location "https://${CLUSTER_NAME}../usermanagement/api/Users/" \
--header "Authorization: Bearer ${USER_ADMIN_TOKEN}")

echo -e "VALIDATING SUCCESS..."
GET_GROUPS=$(echo ${GET_USER_INFO_FROM_INSTANCE} | grep -oEi ".{0,10}$(sed 's/[^a-zA-Z0-9]/\\&/g' <<< "${USER_EMAIL}").{0,300}" | grep -oP '"groups"\s*:\s*\[\K[^]]*')
if echo $GET_GROUPS | grep -q "${GROUP_ASSIGNMENT}";
then
    echo -e "${GREEN}SUCCESS!${NC} GROUP ASSIGNMENT UPDATED!"
else
    echo -e "${RED}FAILED TO UPDATE GROUP ASSIGNMENT.${NC}\nDURING VALIDATION THE CHOSEN GROUP ASSIGNMENT WAS NOT FOUND UNDER THE USER IN THE ROOT INSTANCE."
    echo -e "${YELLOW}STEP STATUS: ${RED}FAILED!"
    echo -e "${RL}\tTROUBLESHOOTING\n${RED}USER INFO FROM INSTANCE:${NC}\n${GET_USER_INFO_FROM_INSTANCE}${RED}\nGROUPS PARSED:${NC}\n${GET_GROUPS}${END}"
    exit 1
fi

###########################################################################################################################################################
#-------------------- Get PATCH Auth token --------------------#

echo -e "RETRIEVING AUTHORIZATION TOKEN..."
GET_PATCH_AUTH_TOKEN=$(curl -s --location "https://${CLUSTER_NAME}../servicename/connect/token" \
--header 'Content-Type: application/x-www-form-urlencoded' \
--data-urlencode 'grant_type=client_credentials' \
--data-urlencode "client_id=.suite.services.servicename@${INSTANCE_NAME}" \
--data-urlencode "client_secret=$PATCH_AUTH_TOKEN_SECRET" \
--data-urlencode 'response_type=token')

PATCH_AUTH_TOKEN=$(echo $GET_PATCH_AUTH_TOKEN | cut -d '"' -f 4)
if [[ $PATCH_AUTH_TOKEN == "" ]]; 
then
    echo -e "${RED}FAILED TO RETRIEVE AUTHORIZATION TOKEN.${NC}"
    echo -e "${YELLOW}STEP STATUS: ${RED}FAILED!${END}"
    exit 1
else
    echo -e "${GREEN}SUCCESS!${NC} PATCH AUTHORIZATION TOKEN RETRIEVED!"
fi

###########################################################################################################################################################
#-------------------- Patch password --------------------#

if [[ $PASSWORD == "-" || -z "$PASSWORD" ]];
then
    echo -e "${RED}PASSWORD NOT PROVIDED.${NC}"
fi

while true; do
    if [[ $PASSWORD == "-" || -z "$PASSWORD" ]];
    then
        echo -e "DEFAULTING PASSWORD TO:$BLUE Firststart#123$NC"
        PASSWORD='Firststart#123'
    fi

    echo -e "PATCHING PASSWORD..."

    USER_IDENTITY_ID=$(echo "${GET_USER_INFO_FROM_INSTANCE}" | grep -oEi ".{0,75}$(sed 's/[^a-zA-Z0-9]/\\&/g' <<< "${USER_EMAIL}").{0,350}" | grep -oP '"identityId"\s*:\s*"\K[^"]*')
    PATCH_PASSWORD=$(curl -s -w "%{http_code}" --location --request PATCH "https://${CLUSTER_NAME}../servicename/api/Identities/${USER_IDENTITY_ID}/UpdatePassword" \
    --header 'Content-Type: application/json' \
    --header "Authorization: Bearer $PATCH_AUTH_TOKEN" \
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
