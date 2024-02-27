#!/bin/bash
ORANGE='\033[0;33m';GRAY='\033[1;30m';RED='\033[1;31m';GREEN='\033[1;32m';YELLOW='\033[1;33m';BLUE='\033[1;34m';PURPLE='\033[1;35m';NC='\033[0m'
END="${GRAY}\n.\n.\n${PURPLE}------------------------------------------------------------------------------------"
RL="${GRAY}\n.\n${RED}----------------${GRAY}\n.\n${NC}"
OL="${GRAY}.\n${ORANGE}----------------${NC}"

#vars passed from pipeline
while getopts ":t:n:e:c:g:y:z:" option; do
  case $option in
    t)
      EXISTING_TENANTS="$OPTARG"
      ;;
    n)
      ROOT_TENANT="$OPTARG"
      ;;
    e)
      USER_EMAIL="$OPTARG"
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
if [[ $EXISTING_TENANTS == "" ]];
then
	echo -e "${RED}\nMISSING ARGUMENT!\nEXISTING TENANTS NOT PROVIDED.${END}"
	exit 1
elif [[ $ROOT_TENANT == "" ]];
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

echo -e "${PURPLE}------------------------------------------------------------------------------------${GRAY}\n.\n.\n\t\t${YELLOW}MULTI-TENANT USER CREATION${GRAY}\n.${NC}"
echo -e "${OL}${GRAY}\n.\n${NC}PIPELINE PARAMETERS:${GRAY}\n."
echo -e "${BLUE}EXISTING TENANTS:$NC $EXISTING_TENANTS"
echo -e "${BLUE}ROOT TENANT:$NC $ROOT_TENANT"
echo -e "${BLUE}USER EMAIL:$NC $USER_EMAIL"
echo -e "${BLUE}CLUSTER NAME:$NC $CLUSTER_NAME"
echo -e "${BLUE}GROUP ASSIGNMENT:$NC $GROUP_ASSIGNMENT"
echo -e "${OL}${GRAY}\n.${NC}"

FIRST_TENANT=$(echo "$EXISTING_TENANTS" | cut -d ',' -f 1)

###########################################################################################################################################################
#--------------------------------------Getting Multi collection admin token----------------------------------

echo "RETRIEVING ADMIN TOKEN FOR AN EXISTING TENANT..."
GET_ADMIN_TOKEN=$(curl -s --location "https://${CLUSTER_NAME}.softwareName.companyName/softwareNameconnect/token" \
--header 'Content-Type: application/x-www-form-urlencoded' \
--data-urlencode 'grant_type=client_credentials' \
--data-urlencode "client_id=systemadmin@${FIRST_TENANT}" \
--data-urlencode "client_secret=$ADMIN_TOKEN_SECRET" \
--data-urlencode 'response_type=token')

ADMIN_TOKEN=$(echo $GET_ADMIN_TOKEN | cut -d '"' -f 4)
if echo $GET_ADMIN_TOKEN | grep -q "access_token";
then
    echo -e "${GREEN}SUCCESS!${NC} ADMIN TOKEN RETRIEVED!"
else
    echo -e "${RED}FAILED TO RETRIEVE ADMIN TOKEN.${NC}\nDOUBLE CHECK THE CLUSTER NAME OR TENANT NAME VARIABLES. MAKE SURE THEY EXIST."
    echo -e "${YELLOW}STEP STATUS: ${RED}FAILED!"
    echo -e "${RL}\tTROUBLESHOOTING\n${RED}ADMIN TOKEN REQUEST RESPONSE:${NC}\n${GET_ADMIN_TOKEN}${END}"
    exit 1
fi

###########################################################################################################################################################
#----------------------------------------------Getting User ID------------------------------------------------

echo -e "RETRIEVING USER IDENTITY ID FOR ${YELLOW}${USER_EMAIL}${NC}..."
GET_USER_IDENTITY_ID=$(curl -s --location "https://${CLUSTER_NAME}.softwareName.companyName/api/Users/" \
--header "Authorization: Bearer $ADMIN_TOKEN")

USER_IDENTITY_ID=$(echo ${GET_USER_IDENTITY_ID} | grep -oEi ".{0,10}${USER_EMAIL}.{0,375}" | grep -oP '"identityId"\s*:\s*"\K[^"]*')
USER_ID=$(echo ${GET_USER_IDENTITY_ID} | grep -oEi ".{0,150}${USER_EMAIL}.{0,50}" | grep -oP '"id"\s*:\s*"\K[^"]*')

if [[ $USER_IDENTITY_ID == "" ]]; 
then
    echo -e "${RED}FAILED TO GET USER IDENTITY ID.${NC}\nTHE E-MAIL MAY BE WRONG."
    echo -e "${YELLOW}STEP STATUS: ${RED}FAILED!${END}"
    exit 1
elif [[ $USER_ID == "" ]];
then
    echo -e "${RED}FAILED TO GET USER ID.${NC}"
    echo -e "${YELLOW}STEP STATUS: ${RED}FAILED!${END}"
    exit 1
else
    echo -e "${GREEN}SUCCESS!${NC} USER ID AND IDENTITY ID RETRIEVED!"
    echo -e "${BLUE}THE USER ID IS:${NC} ${USER_ID}"
    echo -e "${BLUE}THE USER IDENTITY ID IS:${NC} ${USER_IDENTITY_ID}"
fi


###########################################################################################################################################################
#-------------------------------------List All Tenants------------------------------------------------

echo "GETTING TENANT IDs..."
GET_ALL_TENANTS=$(curl -s --location "https://${CLUSTER_NAME}.softwareName.companyName/api/Tenants" \
--header "Authorization: Bearer $ADMIN_TOKEN")

IFS=','
EXISTING_TENANTS="${EXISTING_TENANTS},${ROOT_TENANT}"
read -a TENANTS <<< "$EXISTING_TENANTS"
TENANT_IDS="["

while [ ${#TENANTS[@]} -gt 0 ]; do
    CURRENT_TENANT="${TENANTS[0]}" # Pop the first element from the array
    echo -e "PROCESSING $CURRENT_TENANT..."
    TENANT_ID=$(echo "${GET_ALL_TENANTS}" | grep -oP ".{0,350}\"tenantIdentifier\":\"${CURRENT_TENANT}\".{0,50}" | grep -oP '"id"\s*:\s*"\K[^"]*')
    if [[ $TENANT_ID == "" ]]; 
    then
        echo -e "${RED}FAILED TO RETRIEVE TENANT ID FOR: ${NC}${CURRENT_TENANT}\nDOUBLE CHECK THE TENANT NAME FOR ANY SPELLING ERRORS!"
        echo -e "${YELLOW}STEP STATUS: ${RED}FAILED!${END}"
        exit 1
    fi
    TENANT_IDS+="\"$TENANT_ID\""
    [ ${#TENANTS[@]} -gt 1 ] && TENANT_IDS+="," # Add a comma if there are more tenants
    TENANTS=("${TENANTS[@]:1}") # Remove the processed tenant from the array
done

ROOT_TENANT_IDS="$TENANT_IDS]"
echo -e "${BLUE}THE TENANT IDs ARRAY IS AS FOLLOWS:${NC} $ROOT_TENANT_IDS"

###########################################################################################################################################################
#-------------auth token request--------------------#

echo "RETRIEVING AUTHORIZATION TOKEN..."
GET_AUTH_TOKEN=$(curl -s --location "https://${CLUSTER_NAME}.softwareName.companyName/softwareNameconnect/token" \
--header 'Content-Type: application/x-www-form-urlencoded' \
--data-urlencode 'grant_type=client_credentials' \
--data-urlencode "client_id=companyName.suite.services@${FIRST_TENANT}" \
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
#-------------------- Patch Users request --------------------#

echo "PATCHING USER..."
PATCH_USER=$(curl -s --location --request PATCH "https://${CLUSTER_NAME}.softwareName.companyName/softwareNameapi/Identities/${USER_IDENTITY_ID}/Tenants" \
--header 'Content-Type: application/json' \
--header "Authorization: Bearer ${AUTH_TOKEN}" \
--data "{
    "tenants": $ROOT_TENANT_IDS
}") 

if [[ $PATCH_USER != "" ]]; 
then
    echo -e "${RED}FAILED TO PATCH USER.${NC}"
    echo -e ""
    echo -e "${YELLOW}STEP STATUS: ${RED}FAILED!"
    echo -e "${RL}\tTROUBLESHOOTING\n${RED}THE PATCH USER API REQUEST SHOULD RETURN A NULL RESPONSE.\nINSTEAD IT RETURNED:\n${NC}${PATCH_USER}${END}"
    exit 1
fi

###########################################################################################################################################################
#-------------------- Patch Users GET request --------------------#

echo "USER PATCHED... VALIDATING SUCCESS..."
PATCH_USERS_COPY=$(curl -s --location "https://${CLUSTER_NAME}.softwareName.companyName/softwareNameapi/Identities/${USER_IDENTITY_ID}" \
--header "Authorization: Bearer ${AUTH_TOKEN}" \ --header \ --data '')
 
TENANT_IDENTIFIERS_PARSED=$(echo "$PATCH_USERS_COPY" | grep -o '"tenantIdentifier":"[^"]*' | awk -F '"' '{print $4}')
TENANT_IDENTIFIERS_SORTED=$(echo "$TENANT_IDENTIFIERS_PARSED" | tr '\n' ',' | tr -s ',' | tr ',' '\n' | sort | tr '\n' ',' | grep -v ',')
ORIGINAL_TENANTS_PROVIDED_SORTED=$(echo "$EXISTING_TENANTS" | tr ',' '\n' | sort | tr '\n' ',' | grep -v ',')


if [ "$TENANT_IDENTIFIERS_SORTED" = "$ORIGINAL_TENANTS_PROVIDED_SORTED" ]; then
    echo -e "${GREEN}SUCCESS!${NC} MULTI-TENANT USER CREATED!"
else
    echo -e "${RED}SOMETHING WENT WRONG!${NC}"
    echo "$TENANT_IDENTIFIERS_SORTED" > TENANT_IDENTIFIERS_SORTED.txt
    echo "$ORIGINAL_TENANTS_PROVIDED_SORTED" > ORIGINAL_TENANTS_PROVIDED_SORTED.txt
    DIFFERENCE=$(diff TENANT_IDENTIFIERS_SORTED.txt ORIGINAL_TENANTS_PROVIDED_SORTED.txt)
    echo -e "THIS TENANT WAS NOT ADDED TO THE USER:\n${DIFFERENCE}${END}"
    rm TENANT_IDENTIFIERS_SORTED.txt ORIGINAL_TENANTS_PROVIDED_SORTED.txt
    exit 1
fi

###########################################################################################################################################################
#-------------------- Get admin token for the ROOT TENANT --------------------#

echo -e "RETRIEVING ADMIN TOKEN FOR ROOT TENANT..."
GET_NEW_ADMIN_TOKEN=$(curl -s --location "https://${CLUSTER_NAME}.softwareName.companyName/softwareNameconnect/token" \
--header 'Content-Type: application/x-www-form-urlencoded' \
--data-urlencode 'grant_type=client_credentials' \
--data-urlencode "client_id=systemadmin@${ROOT_TENANT}" \
--data-urlencode "client_secret=$ADMIN_TOKEN_SECRET" \
--data-urlencode 'response_type=token')

NEW_ADMIN_TOKEN=$(echo $GET_NEW_ADMIN_TOKEN | cut -d '"' -f 4)
if echo $GET_NEW_ADMIN_TOKEN | grep -q "access_token";
then
    echo -e "${GREEN}SUCCESS!${NC} ADMIN TOKEN RETRIEVED!"
else
    echo -e "${RED}FAILED TO RETRIEVE ADMIN TOKEN.${NC}\nDOUBLE CHECK THE CLUSTER NAME OR ROOT TENANT NAME VARIABLES. MAKE SURE THEY EXIST."
    echo -e "${YELLOW}STEP STATUS: ${RED}FAILED!"
    echo -e "${RL}\tTROUBLESHOOTING\n${RED}ADMIN TOKEN REQUEST RESPONSE:${NC}\n${GET_NEW_ADMIN_TOKEN}${END}"
    exit 1
fi

###########################################################################################################################################################
#-------------------- Get user ID from the ROOT TENANT --------------------#

GET_USER_INFO_FROM_TENANT=$(curl -s --location "https://${CLUSTER_NAME}.softwareName.companyName/api/Users/" \
--header "Authorization: Bearer ${NEW_ADMIN_TOKEN}")

USER_ID_ROOT_TENANT=$(echo ${GET_USER_INFO_FROM_TENANT} | grep -oEi ".{0,150}${USER_EMAIL}.{0,50}" | grep -oP '"id"\s*:\s*"\K[^"]*')
if [[ $USER_ID_ROOT_TENANT == "" ]];
then
    echo -e "${RED}FAILED TO GET USER ID.${NC}"
    echo -e "${YELLOW}STEP STATUS: ${RED}FAILED!${END}"
    exit 1
else
    echo -e "${GREEN}SUCCESS!${NC} USER ID RETRIEVED FOR ROOT TENANT!"
    echo -e "${BLUE}THE USER ID IS:${NC} ${USER_ID_ROOT_TENANT}"
fi

###########################################################################################################################################################
#-------------------- Get group assignment ID --------------------#

echo -e "SELECTED GROUP ASSIGNMENT: ${YELLOW}${GROUP_ASSIGNMENT}${NC}"
echo -e "RETRIEVING GROUP ASSIGNMENT ID..."
GET_GROUP_ASSIGNMENT_ID=$(curl -s --location "https://${CLUSTER_NAME}.softwareName.companyName/api/Groups" \
--header "Authorization: Bearer ${NEW_ADMIN_TOKEN}")

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
--header "Authorization: Bearer ${NEW_ADMIN_TOKEN}" \
--data '{
    "userId": "'${USER_ID_ROOT_TENANT}'",
    "groupId": "'${GROUP_ASSIGNMENT_ID}'"
}')

GET_USER_INFO_FROM_TENANT=$(curl -s --location "https://${CLUSTER_NAME}.softwareName.companyName/api/Users/" \
--header "Authorization: Bearer ${NEW_ADMIN_TOKEN}")

echo -e "VALIDATING SUCCESS..."
GET_GROUPS=$(echo ${GET_USER_INFO_FROM_TENANT} | grep -oEi ".{0,10}${USER_EMAIL}.{0,300}" | grep -oP '"groups"\s*:\s*\[\K[^]]*')
if echo $GET_GROUPS | grep -q "${GROUP_ASSIGNMENT}";
then
    echo -e "${GREEN}SUCCESS!${NC} GROUP ASSIGNMENT UPDATED!"
    echo -e "${GREEN}SCRIPT COMPLETE.${END}"
else
    echo -e "${RED}FAILED TO UPDATE GROUP ASSIGNMENT.${NC}\nDURING VALIDATION THE CHOSEN GROUP ASSIGNMENT WAS NOT FOUND UNDER THE USER IN THE ROOT TENANT."
    echo -e "${YELLOW}STEP STATUS: ${RED}FAILED!"
    echo -e "${RL}\tTROUBLESHOOTING\n${RED}USER INFO FROM TENANT:${NC}\n${GET_USER_INFO_FROM_TENANT}${RED}GROUPS PARSED:${NC}\n${GET_GROUPS}${END}"
    exit 1
fi
