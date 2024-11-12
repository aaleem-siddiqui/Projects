#!/bin/bash

ORANGE='\033[0;33m';GRAY='\033[1;30m';RED='\033[1;31m';GREEN='\033[1;32m';YELLOW='\033[1;33m';BLUE='\033[1;36m';PURPLE='\033[1;35m';NC='\033[0m'
END="${GRAY}\n.\n.\n${PURPLE}------------------------------------------------------------------------------------"
RL="${GRAY}\n.\n${RED}----------------${GRAY}\n.\n${NC}"

#vars passed from pipeline
while getopts ":c:y:e:" option; do
  case $option in
    c)
      CLUSTER_NAME="$OPTARG"
      ;;
    e)
      USER_EMAIL="$OPTARG"
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
if [[ -z "$ADMIN_TOKEN_SECRET" ]];
then
	echo -e "${RED}\nMISSING ARGUMENT!\nADMIN OR AUTH TOKEN SECRETS NOT PULLED FROM CI/CD VARIABLES.\nPLEASE NAVIGATE TO SETTINGS > CI/CD > VARIABLES AND MAKE SURE THEY EXIST.${END}"
	exit 1
elif [[ -z "$CLUSTER_NAME" ]];
then
	echo -e "${RED}\nMISSING ARGUMENT!\nCLUSTER NAME NOT PROVIDED.${END}"
	exit 1
elif [[ -z "$USER_EMAIL" ]];
then
	echo -e "${RED}\nMISSING ARGUMENT!\nCUSTOMER EMAIL NOT PROVIDED.${END}"
	exit 1
fi

###########################################################################################################################################################
#-------------------- FUNCTION FOR RETRIEVING ADMIN TOKEN --------------------#

GET_ADMIN_TOKEN_FUNCTION() {
    local CLIENT_ID=$1
    local GET_ADMIN_TOKEN

    GET_ADMIN_TOKEN=$(curl -s --location "https://${CLUSTER_NAME}.cloudSoftware.ifm/auth/connect/token" \
    --header 'Content-Type: application/x-www-form-urlencoded' \
    --data-urlencode 'grant_type=client_credentials' \
    --data-urlencode "client_id=${CLIENT_ID}" \
    --data-urlencode "client_secret=$ADMIN_TOKEN_SECRET" \
    --data-urlencode 'response_type=token')

    if echo "$GET_ADMIN_TOKEN" | grep -q "access_token"; then
        echo "$GET_ADMIN_TOKEN" | cut -d '"' -f 4  # RETURN TOKEN
    else
        echo -e "${RED}FAILED TO RETRIEVE ADMIN TOKEN.${NC}\nDOUBLE CHECK THE CLUSTER NAME OR ROOT TENANT NAME VARIABLES. MAKE SURE THEY EXIST."
        echo -e "${YELLOW}STEP STATUS: ${RED}FAILED!"
        echo -e "${RL}\tTROUBLESHOOTING\n${RED}ADMIN TOKEN REQUEST RESPONSE:${NC}\n${GET_ADMIN_TOKEN}${END}"
        exit 1
    fi
}

ADMIN_TOKEN=$(GET_ADMIN_TOKEN_FUNCTION "systemadmin@system")

###########################################################################################################################################################
#-------------------- PRINT HEADER, DEFINE VARIABLES --------------------#

USER_EMAIL=$(echo $USER_EMAIL | tr '[:upper:]' '[:lower:]')
echo -e "${PURPLE}------------------------------------------------------------------------------------${GRAY}\n.\n.\n.\n\t\t${NC}SEARCHING FOR USER $YELLOW$USER_EMAIL$NC IN $YELLOW$CLUSTER_NAME$NC"

LIST_ALL_TENANTS=$(curl -s --location "https://${CLUSTER_NAME}.cloudSoftware.ifm/tnntmgmt/api/Tenants" \
--header "Authorization: Bearer ${ADMIN_TOKEN}")

# vars
TENANT_IDS=($(echo "$LIST_ALL_TENANTS" | grep -o '"tenantIdentifier":"[^"]*"' | sed -E 's/.*"tenantIdentifier":"([^"]*)".*/\1/'))
TENANT_COUNT=${#TENANT_IDS[@]}
COUNTER=1
START_TIME=$(date +%s)
LAST_PRINT_TIME=$START_TIME
MATCHING_TENANTS_FILE=$(mktemp)
MAX_CONCURRENT=30 # max number of jobs to run at the same time
CURRENT_JOBS=0

echo -e "\t\t\tTHERE ARE $BLUE$TENANT_COUNT$NC TENANTS IN THIS CLUSTER...${GRAY}\n.\n.\n.$NC"

###########################################################################################################################################################
#-------------------- FUNCTION TO PROCESS EACH TENANT --------------------#

echo -e "PROCESSING TENANTS..."
PROCESS_TENANT() {
    local TENANT_NAME=$1
    local ADMIN_TOKEN=$(GET_ADMIN_TOKEN_FUNCTION "systemadmin@$TENANT_NAME")

    LIST_USERS_IN_TENANT=$(curl -s --location "https://${CLUSTER_NAME}.cloudSoftware.ifm/usrmgmt/api/Users/" \
    --header "Authorization: Bearer ${ADMIN_TOKEN}")

    USER_EMAILS=($(echo "$LIST_USERS_IN_TENANT" | grep -o '"email":"[^"]*"' | sed -E 's/.*"email":"([^"]*)".*/\1/'))
    for email in "${USER_EMAILS[@]}"; do
        if [[ "${email,,}" == "${USER_EMAIL,,}" ]]; then
            echo "$TENANT_NAME" >> "$MATCHING_TENANTS_FILE"
            echo -e "${GREEN}USER FOUND IN TENANT!$NC ( $TENANT_NAME )"
            break
        fi
    done
}

###########################################################################################################################################################
#-------------------- LOOP THROUGH EACH TENANT AND RUN GET USERS IN PARALELL --------------------#

for TENANT_NAME in "${TENANT_IDS[@]}"; do
    PROCESS_TENANT "$TENANT_NAME" &  # runs function in the background
    ((CURRENT_JOBS++))
    if ((CURRENT_JOBS >= MAX_CONCURRENT)); then
        wait -n  # Wait for any background job to complete
        ((CURRENT_JOBS--))
    fi

    # echo progress every 4 seconds
    ((COUNTER++))
    CURRENT_TIME=$(date +%s)
    ELAPSED_TIME=$(( CURRENT_TIME - LAST_PRINT_TIME ))
    if (( ELAPSED_TIME >= 4 )); then
        PERCENT_COMPLETE=$(( COUNTER * 100 / TENANT_COUNT ))
        echo -e "STILL WORKING...\n$COUNTER/$TENANT_COUNT TENANTS PROCESSED [ $YELLOW$PERCENT_COMPLETE%$NC ]"
        LAST_PRINT_TIME=$CURRENT_TIME
    fi
done

###########################################################################################################################################################
#-------------------- WAITS FOR JOBS TO COMPLETE, PRINTS FINAL OUTPUT, REMOVES TEMP FILE --------------------#

# Wait for all background jobs to complete
wait
echo -e "${GREEN}PROCESSING COMPLETE!$NC"
MATCHING_TENANTS_LIST=$(cat "$MATCHING_TENANTS_FILE" | tr '\n' ',' | sed 's/,$//')  # Remove newlines and trailing comma
if [[ -z "$MATCHING_TENANTS_LIST" ]];
then
    echo -e "${GRAY}.\n.\n.\n$NC${RED}THE USER $USER_EMAIL WAS NOT FOUND IN $CLUSTER_NAME.$NC"
else
    echo -e "${GRAY}.\n.\n.\n$NC${BLUE}COPY THE BELOW VALUE INTO 'EXISTING_TENANTS' FIELD OF USER ADMIN TOOL IF APPLICABLE:\n$YELLOW$MATCHING_TENANTS_LIST$NC"
fi
echo -e "${GRAY}\n.\n.\n.${PURPLE}------------------------------------------------------------------------------------${NC}"

# Clean up temporary file
rm "$MATCHING_TENANTS_FILE"