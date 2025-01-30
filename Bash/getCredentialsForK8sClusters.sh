#!/bin/bash
# DESCRIPTION: This script imports all available kuberneties clusters within your Azure scope to your local config file (useful for OpenLens). Copy the code block into your git bash window to use.

#colors
ORANGE='\033[0;33m';CYAN='\033[1;36m';RED='\033[1;31m';GREEN='\033[1;32m';YELLOW='\033[1;33m';BLUE='\033[1;34m';PURPLE='\033[1;35m';NC='\033[0m'
LINE='\n----------------------------------------------------------------------\n'

#vars
clear
SUBSCRIPTIONS=()
SUBSCRIPTIONS_WITHOUT_CLUSTERS=""
CHECK_AZURE_CREDS=$(az account show 2>&1)

#--------------------------------------------------------------------------------------------------------------------------------
# check azure credentials

echo -e "SCRIPT STARTED.\nCHECKING AZURE CREDENTIALS..."

if [[ "$CHECK_AZURE_CREDS" == *"Please run"* ]]; then
    echo -e "${RED}YOU DO NOT HAVE AN ACTIVE AZURE SESSION.$NC\nPLEASE RUN 'az login' TO ACCESS YOUR ACCOUNTS AND RE-RUN THE SCRIPT."
    exit 1
else
    echo -e "AZURE CREDENTIALS ${GREEN}ACTIVE.$NC"
fi


#--------------------------------------------------------------------------------------------------------------------------------
# choose operation (add or remove)

echo -e "\nOPERATIONS:\n1) ${GREEN}ADD$NC CLUSTERS \n2) ${RED}DELETE$NC CLUSTERS\n"
while true; do
    read -p "CHOOSE OPERATION: " USER_INPUT
    case "$USER_INPUT" in
        * )
            if [[ "$USER_INPUT" =~ ^[0-9]+$ ]] && (( USER_INPUT >= 1 && USER_INPUT <= 2 )); then
                if [[ "$USER_INPUT" == 1 ]]; then
                    DELETE_CONTEXTS="FALSE"
                    echo -e "YOU HAVE CHOSEN TO \"${GREEN}ADD$NC\" K8S CLUSTERS TO LOCAL CONTEXTS..."
                else
                    DELETE_CONTEXTS="TRUE"
                    echo -e "YOU HAVE CHOSEN TO \"${RED}DELETE$NC\" K8S CLUSTERS FROM LOCAL CONTEXTS..."
                fi
                break
            else
                echo -e "${RED}ENTER A VALID OPERATION CHOICE (1-2).$NC"
            fi
            ;;
    esac
done

#--------------------------------------------------------------------------------------------------------------------------------
# get subscriptions and cluster names from azure

echo -e "RETRIEVING YOUR AZURE SUBSCRIPTION NAMES AND IDS...\nCONVERTING THEM TO ARRAYS..."
SUBSCRIPTION_IDS=$(az account list --query '[].id' -o tsv)
SUBSCRIPTION_NAMES=$(az account list --query '[].name' -o tsv)
IFS=$'\n' read -r -d '' -a SUB_IDS <<< "$SUBSCRIPTION_IDS"
IFS=$'\n' read -r -d '' -a SUB_NAMES <<< "$SUBSCRIPTION_NAMES"

# Ensure the array has the same length for both IDs and Names
for (( i = 0; i < ${#SUB_IDS[@]}; i++ )); do
    CURRENT_SUB_ID="${SUB_IDS[$i]//[[:space:]]/}"
    CURRENT_SUB_NAME="${SUB_NAMES[$i]//[[:space:]]/}"
    SUBSCRIPTIONS+=("$CURRENT_SUB_ID:$CURRENT_SUB_NAME")
done

#--------------------------------------------------------------------------------------------------------------------------------
# loop to add or remove subscriptions

echo -e "LOOPING THROUGH SUBSCRIPTIONS... PLEASE WAIT...\n$LINE"
for SUBSCRIPTION in "${SUBSCRIPTIONS[@]}"; do
    SUBSCRIPTION_NAME="${SUBSCRIPTION#*:}"
    SUBSCRIPTION_ID="${SUBSCRIPTION%%:*}"
    
    az account set --subscription "$SUBSCRIPTION_ID"
    CLUSTERS=$(az aks list --query '[].{name:name,resourceGroup:resourceGroup}' -o json)
    if [ -z "$CLUSTERS" ] || [ "$CLUSTERS" == "[]" ]; then
        SUBSCRIPTIONS_WITHOUT_CLUSTERS+="$SUBSCRIPTION_NAME"$'\n'
    else
        echo -e "$YELLOW$SUBSCRIPTION_NAME$NC ($SUBSCRIPTION_ID)"
        echo "$CLUSTERS" | grep -E '"name"|"resourceGroup"' | sed 's/[",]//g' | while read -r line; do
            KEY=$(echo "$line" | awk -F: '{print $1}' | xargs)
            VALUE=$(echo "$line" | awk -F: '{print $2}' | xargs)
            
            if [ "$KEY" == "name" ]; then
                CLUSTER_NAME="$VALUE"
                echo -ne "\t$YELLOW-$NC $VALUE | [${ORANGE}PROCESSING...$NC]"
            elif [ "$KEY" == "resourceGroup" ]; then
                RESOURCE_GROUP="$VALUE"
                CLUSTER_INFO+=("${SUBSCRIPTION_ID}:${RESOURCE_GROUP}:${CLUSTER_NAME}")
                if [[ "$DELETE_CONTEXTS" == "TRUE" ]]; then
                    DELETE_CLUSTER_FROM_CONTEXT=$(kubectl config delete-context "${CLUSTER_NAME}" 2>&1)
                    if [[ "$DELETE_CLUSTER_FROM_CONTEXT" == *"deleted context"* ]] || [[ "$DELETE_CLUSTER_FROM_CONTEXT" == *"cannot delete context"* ]]; then
                        echo -e "\r\t$YELLOW-$NC $CLUSTER_NAME | [${GREEN}SUCCESSFULLY DELETED$NC]"
                    else
                        echo -e "\r\t$YELLOW-$NC $CLUSTER_NAME | [${RED}DELETE FAILED$NC]"
                    fi
                else
                    GET_CLUSTER_CREDENTIALS=$(az aks get-credentials --resource-group "${RESOURCE_GROUP}" --name "${CLUSTER_NAME}" --overwrite-existing 2>&1)
                    if [[ "$GET_CLUSTER_CREDENTIALS" == *"WARNING: Merged"* ]]; then
                        echo -e "\r\t$YELLOW-$NC $CLUSTER_NAME | [${GREEN}SUCCESSFULLY ADDED$NC]"
                    else
                        echo -e "\r\t$YELLOW-$NC $CLUSTER_NAME | [${RED}ADD TO CONTEXT FAILED$NC]"
                    fi
                fi
            fi
        done
        echo -e "$LINE"
    fi
done

echo -e "${GREEN}SCRIPT COMPLETE!$NC"
echo -e "THE FOLLOWING AZURE SUBSCRIPTIONS IN YOUR SCOPE DID NOT CONTAIN ANY CLUSTERS:\n$RED$SUBSCRIPTIONS_WITHOUT_CLUSTERS"
exit 1