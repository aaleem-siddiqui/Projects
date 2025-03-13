#!/bin/bash
# JIRAS: CDOP-925

GRAY='\033[1;30m';RED='\033[1;31m';GREEN='\033[1;32m';YELLOW='\033[1;33m';BLUE='\033[1;36m';PURPLE='\033[1;35m';NC='\033[0m';BOLD='\033[48;5;234m';

#vars passed from pipeline
while getopts ":c:y:" option; do
  case $option in
    c)
      CLUSTER_NAME="$OPTARG"
      ;;
    y)
      ADMIN_TOKEN_SECRET="$OPTARG"
      ;;
    *)
      echo -e "${RED}\nMISSING ARGUMENTS! EXITING SCRIPT...${NC}"
      exit 1
      ;;
  esac
done

# flag failsafes
if [[ -z "$ADMIN_TOKEN_SECRET" ]];
then
    echo -e "${RED}\nMISSING ARGUMENT!\nADMIN OR AUTH TOKEN SECRETS NOT PULLED FROM CI/CD VARIABLES.\nPLEASE NAVIGATE TO SETTINGS > CI/CD > VARIABLES AND MAKE SURE THEY EXIST.${END}"
    exit 1
elif [[ -z "$CLUSTER_NAME" ]];
then
    echo -e "${RED}\nMISSING ARGUMENT!\nCLUSTER NAME NOT PROVIDED.${END}"
    exit 1
fi

###########################################################################################################################################################
#-------------------- DEFINE FUNCTIONS --------------------#

GET_ADMIN_TOKEN_FUNCTION() {
    local CLIENT_ID=$1
    GET_ADMIN_TOKEN=$(curl -s --location "https://${CLUSTER_NAME}.company.com/authprov/connect/token" \
    --header 'Content-Type: application/x-www-form-urlencoded' \
    --data-urlencode 'grant_type=client_credentials' \
    --data-urlencode "client_id=${CLIENT_ID}" \
    --data-urlencode "client_secret=$ADMIN_TOKEN_SECRET" \
    --data-urlencode 'response_type=token')

    echo "$GET_ADMIN_TOKEN" | grep -o '"access_token":"[^"]*"' | cut -d '"' -f 4
}

PRINT_HEADER() {
    printf "%s\n" "-------------------------------------------------------------------------------------------------------------"
    printf "\e[36m%-40s\e[0m | \e[36m%-60s\e[0m\n" "USER EMAIL" "TENANTS"
    printf "%s\n" "-------------------------------------------------------------------------------------------------------------"
}

PRINT_FOOTER() {
    printf "%s\n" "-------------------------------------------------------------------------------------------------------------"
}

PROCESS_TENANT() {
    local TENANT_NAME=$1
    local TENANT_ADMIN_TOKEN=$(GET_ADMIN_TOKEN_FUNCTION "systemadministrator@$TENANT_NAME")

    LIST_USERS_IN_TENANT=$(curl -s --location "https://${CLUSTER_NAME}.company.com/usrmgmt/api/Users/" \
    --header "Authorization: Bearer ${TENANT_ADMIN_TOKEN}")

    USER_EMAILS=($(echo "$LIST_USERS_IN_TENANT" | grep -o '"email":"[^"]*"' | sed -E 's/.*"email":"([^"]*)".*/\1/'))

    for email in "${USER_EMAILS[@]}"; do
        echo "$email,$TENANT_NAME" >> "/tmp/tenant_users_${TENANT_NAME}.txt"
    done
}

###########################################################################################################################################################
#-------------------- PRINT HEADER, DEFINE VARIABLES, RETRIEVE INITIAL ADMIN TOKEN --------------------#

echo -e "${PURPLE}------------------------------------------------------------------------------------${GRAY}\n.\n.\n.\n\t\t\t${NC}LISTING ALL USERS IN $YELLOW$CLUSTER_NAME$NC"

ADMIN_TOKEN=$(GET_ADMIN_TOKEN_FUNCTION "systemadministrator@system")
LIST_ALL_TENANTS=$(curl -s --location "https://${CLUSTER_NAME}.company.com/instancemanagement/api/Tenants" \
--header "Authorization: Bearer ${ADMIN_TOKEN}")

TENANT_IDS=($(echo "$LIST_ALL_TENANTS" | grep -o '"tenantIdentifier":"[^"]*"' | sed -E 's/.*"tenantIdentifier":"([^"]*)".*/\1/'))
TENANT_COUNT=${#TENANT_IDS[@]}
COUNTER=0
START_TIME=$(date +%s)
LAST_PRINT_TIME=$START_TIME
MAX_CONCURRENT=30 # max number of background jobs to run at the same time
CURRENT_JOBS=0
ALTERNATE_COUNTER=0

echo -e "\t\tTHERE ARE $YELLOW$TENANT_COUNT$NC TENANTS IN THIS CLUSTER...${GRAY}\n.\n.\n.$NC\nMAPPING USERS TO TENANTS, PLEASE WAIT...${GRAY}\n.$NC"

###########################################################################################################################################################
#-------------------- LOOP THROUGH EACH TENANT, LIST USER ADD TO ARRAY / COMPARE --------------------#

for TENANT_NAME in "${TENANT_IDS[@]}"; do
    PROCESS_TENANT "$TENANT_NAME" &
    ((CURRENT_JOBS++))
    if ((CURRENT_JOBS >= MAX_CONCURRENT)); then
        wait -n
        ((CURRENT_JOBS--))
    fi

    ((COUNTER++))
    CURRENT_TIME=$(date +%s)
    ELAPSED_TIME=$(( CURRENT_TIME - LAST_PRINT_TIME ))
    if (( ELAPSED_TIME >= 3 )); then
        PERCENT_COMPLETE=$(( COUNTER * 100 / TENANT_COUNT ))
        echo -e "STILL WORKING...\n$COUNTER/$TENANT_COUNT TENANTS PROCESSED [ $YELLOW$PERCENT_COMPLETE%$NC ]"
        LAST_PRINT_TIME=$CURRENT_TIME
    fi
done

###########################################################################################################################################################
#-------------------- GATHER RESULTS FROM TEMPORARY FILES AND UPDATE USER_TENANTS --------------------#

wait 
declare -A USER_TENANTS

for TENANT_FILE in /tmp/tenant_users_*.txt; do
    while IFS=',' read -r EMAIL TENANT; do
        USER_TENANTS["$EMAIL"]+="$TENANT,"
    done < "$TENANT_FILE"
    rm "$TENANT_FILE"
done

###########################################################################################################################################################
#-------------------- PRINT TABLE --------------------#

TOTAL_USERS=${#USER_TENANTS[@]}
echo -e "${GRAY}.\n${GREEN}MAPPING COMPLETE!$NC THERE ARE $BLUE$TOTAL_USERS$NC USERS IN $BLUE$CLUSTER_NAME$NC. PRINTING TABLE...${GRAY}\n.\n.\n.$NC"

PRINT_HEADER
for USER in $(printf "%s\n" "${!USER_TENANTS[@]}" | sort -f); do
    if (( ALTERNATE_COUNTER % 2 == 0 )); then # alternates background color in table for readability
        printf "$BOLD%-40s$NC | $BOLD%-60s$NC\n" "$USER" "${USER_TENANTS[$USER]%,}"
    else
        printf "%-40s | %-60s\n" "$USER" "${USER_TENANTS[$USER]%,}"
    fi
    ((ALTERNATE_COUNTER++))
done | column -t -s $'\t'
PRINT_FOOTER
