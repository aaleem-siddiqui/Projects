#!/bin/bash
GRAY='\033[1;30m';RED='\033[1;31m';GREEN='\033[1;32m';YELLOW='\033[1;33m';BLUE='\033[1;34m';PURPLE='\033[1;35m';NC='\033[0m'
END="${GRAY}\n.\n.\n${PURPLE}------------------------------------------------------------------------------------"
RL="${GRAY}\n.\n${RED}----------------${GRAY}\n.\n${NC}"

#vars passed from pipeline
while getopts ":t:n:e:c:g:" option; do
  case $option in
    t)
      EXISTING_INSTANCES="$OPTARG"
      ;;
    n)
      NEW_INSTANCES="$OPTARG"
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
    *)
      echo -e "${RED}\nMISSING ARGUMENTS! EXITING SCRIPT...${END}"
      exit 1
      ;;
  esac
done

#flag failsafes 
if [[ $EXISTING_INSTANCES == "" ]];
then
	echo -e "${RED}\nMISSING ARGUMENT!\nEXISTING INSTANCES NOT PROVIDED.${END}"
	exit 1
elif [[ $NEW_INSTANCES == "" ]];
then
	echo -e "${RED}\nMISSING ARGUMENT!\nNEW INSTANCE NOT PROVIDED.${END}"
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
fi

##################################################################################################################
#Intro

echo -e "${PURPLE}------------------------------------------------------------------------------------${GRAY}\n.\n.\n\t\t${YELLOW}MULTI-INSTANCE USER CREATION${GRAY}\n.${NC}"
FIRST_INSTANCE=$(echo "$EXISTING_INSTANCES" | cut -d ',' -f 1)

###########################################################################################################################################################
#--------------------------------------Getting Multi collection admin token----------------------------------

echo "RETRIEVING ADMIN TOKEN FOR AN EXISTING INSTANCE..."
GET_ADMIN_TOKEN=$(curl -s --location "https://${CLUSTER_NAME}.fake.web/authprov/connect/token" \
--header 'Content-Type: application/x-www-form-urlencoded' \
--data-urlencode 'grant_type=client_credentials' \
--data-urlencode "client_id=systemadmin@${FIRST_INSTANCE}" \
--data-urlencode 'client_secret={{SECRET}}' \
--data-urlencode 'response_type=token')

ADMIN_TOKEN=$(echo $GET_ADMIN_TOKEN | cut -d '"' -f 4)
if echo $GET_ADMIN_TOKEN | grep -q "access_token";
then
    echo -e "${GREEN}SUCCESS!${NC} ADMIN TOKEN RETRIEVED!"
else
    echo -e "${RED}FAILED TO RETRIEVE ADMIN TOKEN.${NC}\nDOUBLE CHECK THE CLUSTER NAME OR INSTANCE NAME VARIABLES. MAKE SURE THEY EXIST."
    echo -e "${YELLOW}STEP STATUS: ${RED}FAILED!"
    echo -e "${RL}\tTROUBLESHOOTING\n${RED}ADMIN TOKEN REQUEST RESPONSE:${NC}\n${GET_ADMIN_TOKEN}${END}"
    exit 1
fi

###########################################################################################################################################################
#----------------------------------------------Getting User ID------------------------------------------------

echo -e "RETRIEVING USER IDENTITY ID FOR ${YELLOW}${USER_EMAIL}${NC}..."
GET_USER_IDENTITY_ID=$(curl -s --location "https://${CLUSTER_NAME}.fake.web/usermanagement/api/Users/" \
--header "Authorization: Bearer $ADMIN_TOKEN")

USER_IDENTITY_ID=$(echo ${GET_USER_IDENTITY_ID} | grep -oE ".{0,100}${USER_EMAIL}.{0,240}" | grep -oP '"identityId"\s*:\s*"\K[^"]*')
USER_ID=$(echo ${GET_USER_IDENTITY_ID} | grep -oE ".{0,150}${USER_EMAIL}.{0,50}" | grep -oP '"id"\s*:\s*"\K[^"]*')

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
#-------------------------------------List All INSTANCEs------------------------------------------------

echo "GETTING INSTANCE IDs..."
GET_ALL_INSTANCES=$(curl -s --location "https://${CLUSTER_NAME}.fake.web/INSTANCEmanagement/api/INSTANCEs" \
--header "Authorization: Bearer $ADMIN_TOKEN")

IFS=','
EXISTING_INSTANCES="${EXISTING_INSTANCES},${NEW_INSTANCES}"
read -a INSTANCES <<< "$EXISTING_INSTANCES"
INSTANCE_IDS="["

while [ ${#INSTANCES[@]} -gt 0 ]; do
    echo "PROCESSING..."
    CURRENT_INSTANCE="${INSTANCES[0]}" # Pop the first element from the array
    INSTANCE_ID=$(echo ${GET_ALL_INSTANCES} | grep -oE ".{0,300}${CURRENT_INSTANCE}.{0,200}" | grep -oP '"id"\s*:\s*"\K[^"]*')
    if [[ $INSTANCE_ID == "" ]]; 
    then
        echo -e "${RED}FAILED TO RETRIEVE INSTANCE ID FOR: ${NC}${CURRENT_INSTANCE}\nDOUBLE CHECK THE INSTANCE NAME FOR ANY SPELLING ERRORS!"
        echo -e "${YELLOW}STEP STATUS: ${RED}FAILED!${END}"
        exit 1
    fi
    INSTANCE_IDS+="\"$INSTANCE_ID\""
    [ ${#INSTANCES[@]} -gt 1 ] && INSTANCE_IDS+="," # Add a comma if there are more INSTANCEs
    INSTANCES=("${INSTANCES[@]:1}") # Remove the processed INSTANCE from the array
done

NEW_INSTANCES_IDS="$INSTANCE_IDS]"
echo -e "${BLUE}THE INSTANCE IDs ARRAY IS AS FOLLOWS:${NC} $NEW_INSTANCES_IDS"

###########################################################################################################################################################
#-------------auth token request--------------------#

echo "RETRIEVING AUTHORIZATION TOKEN..."
GET_AUTH_TOKEN=$(curl -s --location "https://${CLUSTER_NAME}.fake.web/authprov/connect/token" \
--header 'Content-Type: application/x-www-form-urlencoded' \
--data-urlencode 'grant_type=client_credentials' \
--data-urlencode "client_id=authprov@${FIRST_INSTANCE}" \
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

###########################################################################################################################################################
#-------------------- Patch Users request --------------------#

echo "PATCHING USER..."
PATCH_USER=$(curl -s --location --request PATCH "https://${CLUSTER_NAME}.fake.web/authprov/api/Identities/${USER_IDENTITY_ID}/INSTANCEs" \
--header 'Content-Type: application/json' \
--header "Authorization: Bearer ${AUTH_TOKEN}" \
--data "{
    "INSTANCEs": $NEW_INSTANCES_IDS
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
PATCH_USERS_COPY=$(curl -s --location "https://${CLUSTER_NAME}.fake.web/authprov/api/Identities/${USER_IDENTITY_ID}" \
--header "Authorization: Bearer ${AUTH_TOKEN}" \ --header \ --data '')
 
INSTANCE_IDENTIFIERS_PARSED=$(echo "$PATCH_USERS_COPY" | grep -o '"INSTANCEIdentifier":"[^"]*' | awk -F '"' '{print $4}')
INSTANCE_IDENTIFIERS_SORTED=$(echo "$INSTANCE_IDENTIFIERS_PARSED" | tr '\n' ',' | tr -s ',' | tr ',' '\n' | sort | tr '\n' ',' | grep -v ',')
ORIGINAL_INSTANCES_PROVIDED_SORTED=$(echo "$EXISTING_INSTANCES" | tr ',' '\n' | sort | tr '\n' ',' | grep -v ',')


if [ "$INSTANCE_IDENTIFIERS_SORTED" = "$ORIGINAL_INSTANCES_PROVIDED_SORTED" ]; then
    echo -e "${GREEN}SUCCESS!${NC} MULTI-INSTANCE USER CREATED!"
else
    echo -e "${RED}SOMETHING WENT WRONG!${NC}"
    echo "$INSTANCE_IDENTIFIERS_SORTED" > INSTANCE_IDENTIFIERS_SORTED.txt
    echo "$ORIGINAL_INSTANCES_PROVIDED_SORTED" > ORIGINAL_INSTANCES_PROVIDED_SORTED.txt
    DIFFERENCE=$(diff INSTANCE_IDENTIFIERS_SORTED.txt ORIGINAL_INSTANCES_PROVIDED_SORTED.txt)
    echo -e "THIS INSTANCE WAS NOT ADDED TO THE USER:\n${DIFFERENCE}${END}"
    rm INSTANCE_IDENTIFIERS_SORTED.txt ORIGINAL_INSTANCES_PROVIDED_SORTED.txt
    exit 1
fi

###########################################################################################################################################################
#-------------------- Get admin token for the new INSTANCE --------------------#

echo -e "RETRIEVING ADMIN TOKEN FOR NEW INSTANCE..."
GET_NEW_ADMIN_TOKEN=$(curl -s --location "https://${CLUSTER_NAME}.fake.web/authprov/connect/token" \
--header 'Content-Type: application/x-www-form-urlencoded' \
--data-urlencode 'grant_type=client_credentials' \
--data-urlencode "client_id=systemadmin@${NEW_INSTANCES}" \
--data-urlencode 'client_secret={{SECRET}}' \
--data-urlencode 'response_type=token')

NEW_ADMIN_TOKEN=$(echo $GET_NEW_ADMIN_TOKEN | cut -d '"' -f 4)
if echo $GET_NEW_ADMIN_TOKEN | grep -q "access_token";
then
    echo -e "${GREEN}SUCCESS!${NC} ADMIN TOKEN RETRIEVED!"
else
    echo -e "${RED}FAILED TO RETRIEVE ADMIN TOKEN.${NC}\nDOUBLE CHECK THE CLUSTER NAME OR NEW INSTANCE NAME VARIABLES. MAKE SURE THEY EXIST."
    echo -e "${YELLOW}STEP STATUS: ${RED}FAILED!"
    echo -e "${RL}\tTROUBLESHOOTING\n${RED}ADMIN TOKEN REQUEST RESPONSE:${NC}\n${GET_NEW_ADMIN_TOKEN}${END}"
    exit 1
fi

###########################################################################################################################################################
#-------------------- Get user ID from the new INSTANCE --------------------#

GET_USER_INFO_FROM_INSTANCE=$(curl -s --location "https://${CLUSTER_NAME}.fake.web/usermanagement/api/Users/" \
--header "Authorization: Bearer ${NEW_ADMIN_TOKEN}")

USER_ID_NEW_INSTANCES=$(echo ${GET_USER_INFO_FROM_INSTANCE} | grep -oE ".{0,150}${USER_EMAIL}.{0,50}" | grep -oP '"id"\s*:\s*"\K[^"]*')
if [[ $USER_ID_NEW_INSTANCES == "" ]];
then
    echo -e "${RED}FAILED TO GET USER ID.${NC}"
    echo -e "${YELLOW}STEP STATUS: ${RED}FAILED!${END}"
    exit 1
else
    echo -e "${GREEN}SUCCESS!${NC} USER ID RETRIEVED FOR NEW INSTANCE!"
    echo -e "${BLUE}THE USER ID IS:${NC} ${USER_ID}"
fi

###########################################################################################################################################################
#-------------------- Get group assignment ID --------------------#

echo -e "SELECTED GROUP ASSIGNMENT: ${YELLOW}${GROUP_ASSIGNMENT}${NC}"
echo -e "RETRIEVING GROUP ASSIGNMENT ID..."
GET_GROUP_ASSIGNMENT_ID=$(curl -s --location "https://${CLUSTER_NAME}.fake.web/usermanagement/api/Groups" \
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

echo -e "UPDATING GROUP ASSIGNMENT IN INSTANCE: ${YELLOW}${NEW_INSTANCES}${NC}"
POST_GROUP_ASSIGNMENT=$(curl -s --location "https://${CLUSTER_NAME}.fake.web/usermanagement/api/UserGroups" \
--header 'Content-Type: application/json' \
--header "Authorization: Bearer ${NEW_ADMIN_TOKEN}" \
--data '{
    "userId": "'${USER_ID_NEW_INSTANCES}'",
    "groupId": "'${GROUP_ASSIGNMENT_ID}'"
}')

echo -e "VALIDATING SUCCESS..."
GET_GROUPS=$(echo ${GET_USER_INFO_FROM_INSTANCE} | grep -oE ".{0,10}${USER_EMAIL}.{0,300}" | grep -oP '"groups"\s*:\s*\[\K[^]]*')
if echo $GET_GROUPS | grep -q "${GROUP_ASSIGNMENT}";
then
    echo -e "${GREEN}SUCCESS!${NC} GROUP ASSIGNMENT UPDATED!"
    echo -e "${GREEN}SCRIPT COMPLETE.${END}"
else
    echo -e "${RED}FAILED TO UPDATE GROUP ASSIGNMENT.${NC}\nDURING VALIDATION THE CHOSEN GROUP ASSIGNMENT WAS NOT FOUND UNDER THE USER IN THE NEW INSTANCE."
    echo -e "${YELLOW}STEP STATUS: ${RED}FAILED!"
    echo -e "${RL}\tTROUBLESHOOTING\n${RED}USER INFO FROM INSTANCE:${NC}\n${GET_USER_INFO_FROM_INSTANCE}${RED}GROUPS PARSED:${NC}\n${GET_GROUPS}${END}"
    exit 1
fi