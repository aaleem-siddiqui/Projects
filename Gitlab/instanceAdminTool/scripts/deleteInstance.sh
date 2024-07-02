#!/bin/bash
ORANGE='\033[0;33m';GRAY='\033[1;30m';RED='\033[1;31m';GREEN='\033[1;32m';YELLOW='\033[1;33m';BLUE='\033[1;36m';PURPLE='\033[1;35m';NC='\033[0m'
END="${GRAY}\n.\n.\n${PURPLE}------------------------------------------------------------------------------------"
OL="${GRAY}\n.\n.\n${ORANGE}------------------------$NC$GRAY\n.\n.$NC"
RL="${GRAY}\n.\n.\n${NC}"

#vars passed from pipeline
while getopts ":c:n:y:a:b:" option; do
  case $option in
    c)
      CLUSTER_NAME="$OPTARG"
      ;;
    n)
      ROOT_INSTANCES="$OPTARG"
      ;;
    y)
      ADMIN_TOKEN_SECRET="$OPTARG"
      ;;
    a)
      ADMIN_TOKEN_SECRET_MOON="$OPTARG"
      ;;
    b)
      ADMIN_TOKEN_CLIENTID_MOON="$OPTARG"
      ;;
    *)
      echo -e "${RED}\nMISSING ARGUMENTS! EXITING SCRIPT...${END}"
      exit 1
      ;;
  esac
done

#flag failsafes
if [[ -z "$ROOT_INSTANCES" ]];
then
	echo -e "${RED}\nMISSING ARGUMENT!\ROOT INSTANCE NOT PROVIDED.${END}"
	exit 1 
elif [[ -z "$ADMIN_TOKEN_SECRET" || -z "$ADMIN_TOKEN_SECRET_MOON" || -z "$ADMIN_TOKEN_CLIENTID_MOON" ]];
then
	echo -e "${RED}\nMISSING ARGUMENT!\nADMIN OR AUTH TOKEN SECRETS NOT PULLED FROM CI/CD VARIABLES.\nPLEASE NAVIGATE TO SETTINGS > CI/CD > VARIABLES AND MAKE SURE THEY EXIST.${END}"
	exit 1
elif [[ -z "$CLUSTER_NAME" ]];
then
	echo -e "${RED}\nMISSING ARGUMENT!\nCLUSTER NAME NOT PROVIDED.${END}"
	exit 1
fi

###########################################################################################################################################################
#-------------------- Intro --------------------#

echo -e "${PURPLE}------------------------------------------------------------------------------------${GRAY}\n.\n.\n\t\t${YELLOW}DELETE INSTANCE${GRAY}\n.${NC}"
echo -e "${OL}${GRAY}\n.\n${NC}PIPELINE PARAMETERS:${GRAY}\n."
echo -e "${BLUE}ROOT INSTANCES:$NC $ROOT_INSTANCES"
echo -e "${BLUE}CLUSTER NAME:$NC $CLUSTER_NAME"

###########################################################################################################################################################
#-------------------- Get admin token for the ROOT INSTANCE and MOON --------------------#

FAILED_INSTANCES=""
SUCCESS_COUNTER=0
FAILURE_COUNTER=0

IFS=','
read -a INSTANCES <<< "$ROOT_INSTANCES"
while [ ${#INSTANCES[@]} -gt 0 ]; do
    echo -e "$OL"
    CURRENT_INSTANCE="${INSTANCES[0]}"
    echo -e "PROCESSING $BLUE$CURRENT_INSTANCE...$NC"
    echo -e "RETRIEVING ADMIN TOKEN FOR $YELLOW$CURRENT_INSTANCE$NC IN $CLUSTER_NAME..."
    GET_ADMIN_TOKEN=$(curl -s --location "https://${CLUSTER_NAME}.software.companyname/servicename/connect/token" \
      --header 'Content-Type: application/x-www-form-urlencoded' \
      --data-urlencode 'grant_type=client_credentials' \
      --data-urlencode "client_id=systemadmin@$CURRENT_INSTANCE" \
      --data-urlencode "client_secret=$ADMIN_TOKEN_SECRET" \
      --data-urlencode 'response_type=token')

    if [[ -z "$ADMIN_TOKEN_MOON" ]]; 
    then
      echo -e "RETRIEVING ADMIN TOKEN FOR MOON..."
      GET_ADMIN_TOKEN_MOON=$(curl -s --location 'https://moon-w-eu.software.companyname/servicename/connect/token' \
        --header 'Content-Type: application/x-www-form-urlencoded' \
        --data-urlencode 'grant_type=client_credentials' \
        --data-urlencode "client_id=${ADMIN_TOKEN_CLIENTID_MOON}@system" \
        --data-urlencode "client_secret=${ADMIN_TOKEN_SECRET_MOON}" \
        --data-urlencode 'response_type=token')
    fi

    ADMIN_TOKEN=$(echo $GET_ADMIN_TOKEN | cut -d '"' -f 4)
    ADMIN_TOKEN_MOON=$(echo $GET_ADMIN_TOKEN_MOON | cut -d '"' -f 4)

    if [[ $GET_ADMIN_TOKEN == *"access_token"* && $GET_ADMIN_TOKEN_MOON == *"access_token"* ]];
    then
        echo -e "${GREEN}SUCCESS!${NC} ADMIN TOKENS RETRIEVED!"
    elif [[ ( -z "$GET_ADMIN_TOKEN" ) || ! ( $GET_ADMIN_TOKEN == *"access_token"* ) ]];
    then
        echo -e "${RED}FAILED TO RETRIEVE ADMIN TOKEN.${NC}\nDOUBLE CHECK THE CLUSTER NAME OR ROOT INSTANCE NAME VARIABLES. MAKE SURE THEY ARE CORRECT."
        echo -e "${YELLOW}HINT:$NC THE INSTANCE MAY NOT EXIST IN THE CLUSTER."
        echo -e "STEP STATUS: ${RED}FAILED!${NC}"
        echo -e "${RL}\tTROUBLESHOOTING\n${RED}ADMIN TOKEN REQUEST RESPONSE:${NC}\n${GET_ADMIN_TOKEN}"
        INSTANCES=("${INSTANCES[@]:1}")
        FAILED_INSTANCES+=" $CURRENT_INSTANCE,"
        ((FAILURE_COUNTER++))
        continue
    elif [[ -z "$GET_ADMIN_TOKEN_MOON" ]];
    then
        echo -e "${RED}FAILED TO RETRIEVE ADMIN TOKEN FOR MOON.${NC}"
        echo -e "STEP STATUS: ${RED}FAILED!${NC}"
        echo -e "${RL}\tTROUBLESHOOTING\n${RED}ADMIN TOKEN REQUEST RESPONSE:${NC}\n${GET_ADMIN_TOKEN_MOON}"
        exit 1
    fi

###########################################################################################################################################################
#-------------------- get INSTANCE ID, INSTANCEID in moon, and customerNumber by INSTANCEIdentifier --------------------#

    echo -e "RETRIEVING INSTANCE IDS..."
    LIST_ALL_INSTANCES=$(curl -s --location "https://${CLUSTER_NAME}.software.companyname/servicename/api/INSTANCEs" \
      --header "Authorization: Bearer ${ADMIN_TOKEN}")

    INSTANCE_ID=$(echo "${LIST_ALL_INSTANCES}" | grep -oP ".{0,350}\"INSTANCEIdentifier\":\"${CURRENT_INSTANCE}\".{0,50}" | grep -oP '"id"\s*:\s*"\K[^"]*')
    INSTANCE_ID_MOON=$(echo "${LIST_ALL_INSTANCES}" | grep -oP ".{0,50}\"INSTANCEIdentifier\":\"${CURRENT_INSTANCE}\".{0,400}" | grep -oP '"url"\s*:\s*"\K[^"]*' | cut -d'/' -f7)
    CUSTOMER_NUMBER=$(echo "${LIST_ALL_INSTANCES}" | grep -oP ".{0,350}\"INSTANCEIdentifier\":\"${CURRENT_INSTANCE}\".{0,50}" | grep -oP '"customerNumber"\s*:\s*"\K[^"]*')
    if [[ -z "$INSTANCE_ID_MOON" ]]; 
    then
        GET_INSTANCE_ID_MOON=$(curl -s --location "https://moon-w-eu.software.companyname/globalservicename/api/INSTANCEs?INSTANCEIdentifiers=$CURRENT_INSTANCE" \
        --header "Authorization: Bearer ${ADMIN_TOKEN_MOON}")

        INSTANCE_ID_MOON=$(echo "${GET_INSTANCE_ID_MOON}" | grep -oP '"id"\s*:\s*"\K[^"]*')
        if [[ -z "$INSTANCE_ID_MOON" ]]; 
        then
            echo -e "${RED}FAILED TO RETRIEVE INSTANCE ID IN MOON FOR: ${NC}${CURRENT_INSTANCE}"
            echo -e "STEP STATUS: ${RED}FAILED!${NC}"
            echo -e "${YELLOW}HINT:$NC THE INSTANCE MAY NOT EXIST IN THE CLUSTER."
            INSTANCES=("${INSTANCES[@]:1}")
            FAILED_INSTANCES+=" $CURRENT_INSTANCE,"
            ((FAILURE_COUNTER++))
            continue
        fi
    fi

    echo -e "${GREEN}SUCCESS!${NC} INSTANCE IDS RETRIEVED!"
    echo -e "${BLUE}THE INSTANCE ID IN $CLUSTER_NAME IS:${NC} $INSTANCE_ID"
    echo -e "${BLUE}THE INSTANCE ID IN MOON IS:${NC} $INSTANCE_ID_MOON"

###########################################################################################################################################################
#-------------------- Delete INSTANCE --------------------#

    echo -e "DELETING INSTANCE..."
    DELETE_INSTANCE_MOON=$(curl -s -w "%{http_code}" --location --request DELETE "https://moon-w-eu.software.companyname/globalservicename/api/INSTANCEs/${INSTANCE_ID_MOON}" \
      --header "Authorization: Bearer ${ADMIN_TOKEN_MOON}")

    STATUS_CODE_MOON="${DELETE_INSTANCE_MOON##*]}"
    DELETE_FROM_MOON_COUNTER=0
    if [[ $STATUS_CODE_MOON == "202" ]];
    then
        echo -e "THE DELETE INSTANCE API CALL IN MOON RETURNED A STATUS ${GREEN}202 ACCEPTED$NC! DOUBLE CHECKING TO CONFIRM STATUS..."

        while true; do
            LIST_ALL_INSTANCES=$(curl -s --location "https://${CLUSTER_NAME}.software.companyname/servicename/api/INSTANCEs" \
            --header "Authorization: Bearer ${ADMIN_TOKEN}")

            CHECK_DELETION_STATE=$(curl -s --location "https://moon-w-eu.software.companyname/globalservicename/api/INSTANCEs?INSTANCEIdentifiers=$CURRENT_INSTANCE" \
            --header "Authorization: Bearer ${ADMIN_TOKEN_MOON}")

            if [[ $CHECK_DELETION_STATE != *"$INSTANCE_ID_MOON"* && $LIST_ALL_INSTANCES != *"$INSTANCE_ID"* ]];
            then
                ((SUCCESS_COUNTER++))
                echo -e "${GREEN}SUCCESS!${NC} THE INSTANCE WAS SUCCESSFULLY DELETED!${GRAY}\n.$NC"
                if [[ -z $CUSTOMER_NUMBER ]]; 
                then
                    echo -e "${YELLOW}NOTE:$NC THE CUSTOMER NUMBER FIELD WAS NULL. THIS MEANS THAT THE INSTANCE WAS PROBABLY CREATED MANUALLY VIA API."
                    echo -e "NO FURTHER STEPS TO DELETE THE INSTANCE IN THE DATANET PORTAL ARE REQUIRED."
                else
                    echo -e "${YELLOW}NOTE:$NC REMEMBER TO ALSO DELETE THE INSTANCE FROM THE DATANET PORTAL!"
                    echo -e "NAVIGATE TO ${ORANGE}https://google.com$NC AND SEARCH FOR THE CUSTOMER NUMBER: $ORANGE$CUSTOMER_NUMBER"
                fi
                break
            else
                ((DELETE_FROM_MOON_COUNTER++))
                if [[ $DELETE_FROM_MOON_COUNTER -ge 24 ]];
                then
                    echo -e "${RED}FAILED TO DELETE INSTANCE.${NC}."
                    if [[ $CHECK_DELETION_STATE == *"$INSTANCE_ID_MOON"* && $LIST_ALL_INSTANCES != *"$INSTANCE_ID"* ]];
                    then
                        FAILED_CLUSTER="GLOBALservicename WITHIN MOON"
                    elif [[ $CHECK_DELETION_STATE != *"$INSTANCE_ID_MOON"* && $LIST_ALL_INSTANCES == *"$INSTANCE_ID"* ]];
                    then
                        FAILED_CLUSTER="$CLUSTER_NAME"
                    else
                        FAILED_CLUSTER="$CLUSTER_NAME AND GLOBALservicename WITHIN MOON"
                    fi
                    echo -e "THE API REQUEST WAS SENT BUT THE INSTANCE STILL EXISTS IN $FAILED_CLUSTER..."
                    echo -e "STEP STATUS: ${RED}FAILED!${NC}"
                    INSTANCES=("${INSTANCES[@]:1}")
                    FAILED_INSTANCES+=" $CURRENT_INSTANCE,"
                    ((FAILURE_COUNTER++))
                    continue
                else
                  echo -e "WAITING..."
                  sleep 3
                fi
            fi
        done
    else
        echo -e "${RED}FAILED TO DELETE INSTANCE IN MOON.${NC}."
        echo -e "THE DELETE INSTANCE API CALL RETURNED A STATUS: $STATUS_CODE_MOON"
        echo -e "STEP STATUS: ${RED}FAILED!${NC}"
        INSTANCES=("${INSTANCES[@]:1}")
        FAILED_INSTANCES+=" $CURRENT_INSTANCE,"
        ((FAILURE_COUNTER++))
        continue
    fi
INSTANCES=("${INSTANCES[@]:1}")
done

###########################################################################################################################################################
#-------------------- End --------------------#

echo -e "$OL$GRAY\n.\n.\n\t\t${BLUE}OVERVIEW${GRAY}\n.${NC}"
if [[ $FAILURE_COUNTER -eq 0 ]];
then
    echo -e "ALL INSTANCES ( $GREEN$SUCCESS_COUNTER$NC ) WERE DELETED SUCCESSFULLY."
elif [[ $SUCCESS_COUNTER -gt 1 ]];
then
    echo -e "THERE WERE $GREEN$SUCCESS_COUNTER$NC INSTANCES DELETED SUCCESSFULLY."
elif [[ $SUCCESS_COUNTER -eq 1 ]];
then 
    echo -e "THERE WAS $GREEN$SUCCESS_COUNTER$NC INSTANCE THAT WAS DELETED SUCCESSFULLY."
fi

if [[ $SUCCESS_COUNTER -eq 0 ]];
then
    echo -e "ALL INSTANCES ( $RED$FAILURE_COUNTER$NC ) FAILED TO DELETE."
elif [[ $FAILURE_COUNTER -gt 1 ]];
then
    echo -e "THERE WERE $RED$FAILURE_COUNTER$NC INSTANCES THAT FAILED TO DELETE."
    echo -e "${RED}LIST OF FAILED INSTANCES:$NC ${FAILED_INSTANCES%,}"
elif [[ $FAILURE_COUNTER -eq 1 ]];
then 
    echo -e "THERE WAS $RED$FAILURE_COUNTER$NC INSTANCE THAT FAILED TO DELETE."
    echo -e "${RED}LIST OF FAILED INSTANCES:$NC ${FAILED_INSTANCES%,}"
fi
echo -e "$END"

