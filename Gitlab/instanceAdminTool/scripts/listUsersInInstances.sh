#!/bin/bash
ORANGE='\033[0;33m';GRAY='\033[1;30m';RED='\033[1;31m';GREEN='\033[1;32m';YELLOW='\033[1;33m';BLUE='\033[1;36m';PURPLE='\033[1;35m';NC='\033[0m'
END="${GRAY}\n.\n.\n${PURPLE}------------------------------------------------------------------------------------"
RL="${GRAY}\n.\n${RED}----------------${GRAY}\n.\n${NC}"

#vars passed from pipeline
while getopts ":c:n:y:" option; do
  case $option in
    c)
      CLUSTER_NAME="$OPTARG"
      ;;
    n)
      ROOT_INSTANCE="$OPTARG"
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
if [[ -z "$ROOT_INSTANCE" ]];
then
	echo -e "${RED}\nMISSING ARGUMENT!\ROOT INSTANCE NOT PROVIDED.${END}"
	exit 1 
elif [[ -z "$ADMIN_TOKEN_SECRET" ]];
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

GET_ADMIN_TOKEN=$(curl -s --location "https://${CLUSTER_NAME}.software.company/service/connect/token" \
--header 'Content-Type: application/x-www-form-urlencoded' \
--data-urlencode 'grant_type=client_credentials' \
--data-urlencode "client_id=systemadmin@$ROOT_INSTANCE" \
--data-urlencode "client_secret=$ADMIN_TOKEN_SECRET" \
--data-urlencode 'response_type=token')

ADMIN_TOKEN=$(echo $GET_ADMIN_TOKEN | cut -d '"' -f 4)
if echo $GET_ADMIN_TOKEN | grep -q "access_token";
then
    echo -e "${PURPLE}------------------------------------------------------------------------------------${GRAY}\n.\n.\n.\n\t\t${NC}LISTING USERS..."
else
    echo -e "${RED}FAILED TO RETRIEVE ADMIN TOKEN.${NC}\nDOUBLE CHECK THE CLUSTER NAME OR ROOT INSTANCE NAME VARIABLES. MAKE SURE THEY EXIST."
    echo -e "${YELLOW}STEP STATUS: ${RED}FAILED!"
    echo -e "${RL}\tTROUBLESHOOTING\n${RED}ADMIN TOKEN REQUEST RESPONSE:${NC}\n${GET_ADMIN_TOKEN}${END}"
    exit 1
fi

###########################################################################################################################################################
#-------------------- Listing all INSTANCEs --------------------#

LIST_USERS_IN_INSTANCE=$(curl -s --location "https://${CLUSTER_NAME}.software.company/service/api/Users/" \
--header "Authorization: Bearer ${ADMIN_TOKEN}")

USER_COUNT=$(echo "$LIST_USERS_IN_INSTANCE" | grep -o 'userName' | wc -l)
echo -e "\tTHERE ARE $YELLOW$USER_COUNT$NC USERS IN $YELLOW$ROOT_INSTANCE$NC...${GRAY}\n.\n.\n.$NC"

# Function to print table header
PRINT_HEADER() {
    printf "\e[36m%-25s\e[0m | \e[36m%-40s\e[0m | \e[36m%-30s\e[0m | \e[36m%-15s\e[0m | \e[36m%-15s\e[0m\n" \
        "Name" "Email" "Access" \
        "Initial Login" "Locked"
    printf "%s\n" "-----------------------------------------------------------------------------------------------------------------------------------------------------"
}

PRINT_FOOTER() {
    printf "%s\n" "-----------------------------------------------------------------------------------------------------------------------------------------------------"
}

# Function to print table rows
PRINT_ROW() {
    if [[ "$5" == "true" && "$6" == "true" ]]; then
        printf "%-25s | %-40s | %-30s | \e[32m%-15s\e[0m | \e[32m%-15s\e[0m\n" \
            "$1 $2" "$3" "$4" "$5" "$6"
    elif [[ "$5" == "false" && "$6" == "false" ]]; then
        printf "%-25s | %-40s | %-30s | \e[31m%-15s\e[0m | \e[31m%-15s\e[0m\n" \
            "$1 $2" "$3" "$4" "$5" "$6"
    elif [[ "$5" == "true" && "$6" == "false" ]]; then
        printf "%-25s | %-40s | %-30s | \e[32m%-15s\e[0m | \e[31m%-15s\e[0m\n" \
            "$1 $2" "$3" "$4" "$5" "$6"
    elif [[ "$5" == "false" && "$6" == "true" ]]; then
        printf "%-25s | %-40s | %-30s | \e[31m%-15s\e[0m | \e[32m%-15s\e[0m\n" \
            "$1 $2" "$3" "$4" "$5" "$6"
    else
        printf "%-25s | %-40s | %-30s | %-15s | %-15s\n" \
            "$1 $2" "$3" "$4" "$5" "$6"
    fi
}

# Parse JSON string and print table
PARSE_JSON() {
    # Split the JSON string into individual RECORDS based on '}'
    RECORDS=$(echo "$1" | tr '}' '\n')

    # Iterate over each record to print rows
    while read -r record; do

        
        # Extract relevant fields from the record
        FIRST_NAME=$(echo "$record" | grep -o '"firstName":"[^"]*' | cut -d':' -f2 | tr -d '"')
        LAST_NAME=$(echo "$record" | grep -o '"lastName":"[^"]*' | cut -d':' -f2 | tr -d '"')
        EMAIL=$(echo "$record" | grep -o '"email":"[^"]*' | cut -d':' -f2 | tr -d '"')
        ACCESS=$(echo $record | grep -o '"groups":\[.*\]' | sed 's/"groups":\|\[\|\]\|\"//g')
        INITIAL_LOGIN=$(echo "$record" | grep -o '"initialLogin":\w\+' | cut -d':' -f2)
        LOCKED=$(echo "$record" | grep -o '"locked":\w\+' | cut -d':' -f2)

        #print row
        if [[ -z "$EMAIL" ]];
        then
            continue
        else 
            PRINT_ROW "$FIRST_NAME" "$LAST_NAME" "$EMAIL" "$ACCESS" "$INITIAL_LOGIN" "$LOCKED"
        fi

    done <<< "$RECORDS"
}

# Main function
main() {
    PRINT_HEADER
    PARSE_JSON "$LIST_USERS_IN_INSTANCE"
    PRINT_FOOTER
}

# Call main function
main