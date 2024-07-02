#!/bin/bash
ORANGE='\033[0;33m';GRAY='\033[1;30m';RED='\033[1;31m';GREEN='\033[1;32m';YELLOW='\033[1;33m';BLUE='\033[1;36m';PURPLE='\033[1;35m';NC='\033[0m'
END="${GRAY}\n.\n.\n${PURPLE}------------------------------------------------------------------------------------"
RL="${GRAY}\n.\n${RED}----------------${GRAY}\n.\n${NC}"

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
fi

###########################################################################################################################################################
#-------------------- Get admin token for the ROOT INSTANCE --------------------#

GET_ADMIN_TOKEN=$(curl -s --location "https://${CLUSTER_NAME}.software.company/servicename/connect/token" \
--header 'Content-Type: application/x-www-form-urlencoded' \
--data-urlencode 'grant_type=client_credentials' \
--data-urlencode "client_id=systemadmin@system" \
--data-urlencode "client_secret=$ADMIN_TOKEN_SECRET" \
--data-urlencode 'response_type=token')

ADMIN_TOKEN=$(echo $GET_ADMIN_TOKEN | cut -d '"' -f 4)
if echo $GET_ADMIN_TOKEN | grep -q "access_token";
then
    echo -e "${PURPLE}------------------------------------------------------------------------------------${GRAY}\n.\n.\n.\n\t\t${NC}LISTING ALL INSTANCES...${NC}"
else
    echo -e "${RED}FAILED TO RETRIEVE ADMIN TOKEN.${NC}\nDOUBLE CHECK THE CLUSTER NAME OR ROOT INSTANCE NAME VARIABLES. MAKE SURE THEY EXIST."
    echo -e "${YELLOW}STEP STATUS: ${RED}FAILED!"
    echo -e "${RL}\tTROUBLESHOOTING\n${RED}ADMIN TOKEN REQUEST RESPONSE:${NC}\n${GET_ADMIN_TOKEN}${END}"
    exit 1
fi

###########################################################################################################################################################
#-------------------- Listing all INSTANCEs --------------------#

LIST_ALL_INSTANCES=$(curl -s --location "https://${CLUSTER_NAME}.software.company/servicename/api/INSTANCEs" \
--header "Authorization: Bearer ${ADMIN_TOKEN}")

INSTANCE_COUNT=$(echo "$LIST_ALL_INSTANCES" | grep -o 'INSTANCEIdentifier' | wc -l)
echo -e "\tTHERE ARE $YELLOW$INSTANCE_COUNT$NC INSTANCES IN $YELLOW$CLUSTER_NAME$NC...${GRAY}\n.\n.\n.$NC"


# Function to print table header
PRINT_HEADER() {
    printf "\e[36m%-30s\e[0m | \e[36m%-30s\e[0m | \e[36m%-40s\e[0m | \e[36m%-15s\e[0m | \e[36m%-35s\e[0m\n" \
        "Name" "INSTANCE Identifier" "Owner Email" \
        "Customer Number" "License Accepted"
    printf "%s\n" "-----------------------------------------------------------------------------------------------------------------------------------------------------"
}

PRINT_FOOTER() {
    printf "%s\n" "-----------------------------------------------------------------------------------------------------------------------------------------------------"
}

# Function to print table rows
PRINT_ROW() {
    if [[ "$5" == "true" ]]; then
        printf "%-30s | %-30s | %-40s | %-15s | \e[32m%-35s\e[0m\n" \
            "$1" "$2" "$3" "$4" "$5 ($6)"
    elif [[ "$5" == "false" ]]; then
        printf "%-30s | %-30s | %-40s | %-15s | \e[31m%-35s\e[0m\n" \
            "$1" "$2" "$3" "$4" "$5"
    else
        printf "%-30s | %-30s | %-40s | %-15s | %-35s\n" \
            "$1" "$2" "$3" "$4" "$5"
    fi
}

# Parse JSON string and print table
PARSE_JSON() {
    # Split the JSON string into individual RECORDS based on '}'
    RECORDS=$(echo "$1" | tr '}' '\n')

    # Iterate over each record to print rows
    while read -r record; do
        # Extract relevant fields from the record
        NAME=$(echo "$record" | grep -o '"name":"[^"]*' | cut -d':' -f2- | tr -d '"' | sed 's/^ //')
        INSTANCE_IDENTIFIER=$(echo "$record" | grep -o '"INSTANCEIdentifier":"[^"]*' | cut -d':' -f2 | tr -d '"')
        INSTANCE_OWNER_EMAIL=$(echo "$record" | grep -o '"customerEmail":"[^"]*' | cut -d':' -f2 | tr -d '"')
        CUSTOMER_NUMBER=$(echo "$record" | grep -o '"customerNumber":"[^"]*' | cut -d':' -f2 | tr -d '"')
        LICENSE_ACCEPTED=$(echo "$record" | grep -o '"licenseTermsAccepted":\w\+' | cut -d':' -f2)
        LICENSE_ACCEPTED_TIMESTAMP=$(echo "$record" | grep -o '"licenseTermsAcceptedTimestamp":"[^"]*' | cut -d':' -f2 | tr -d '"' | cut -d'T' -f1 | sed 's/$//g')

        # Print row

        if [[ -z "$INSTANCE_IDENTIFIER" ]];
        then
            continue
        else 
            PRINT_ROW "$NAME" "$INSTANCE_IDENTIFIER" "$INSTANCE_OWNER_EMAIL" "$CUSTOMER_NUMBER" "$LICENSE_ACCEPTED" "$LICENSE_ACCEPTED_TIMESTAMP"
        fi

    done <<< "$RECORDS"
}

# Main function
main() {
    PRINT_HEADER
    PARSE_JSON "$LIST_ALL_INSTANCES"
    PRINT_FOOTER
}

# Call main function
main