#!/bin/bash

#colors
ORANGE='\033[0;33m';CYAN='\033[1;36m';RED='\033[1;31m';GREEN='\033[1;32m';YELLOW='\033[1;33m';BLUE='\033[1;34m';PURPLE='\033[1;35m';NC='\033[0m'
LINE='---------------'

# services list
# ---------------------------------

START_SOFTWARE_SERVICES_FIRST=(
    "software1"
    "software2"
    "software3"
    "software4"
    "software5"
    "software6"
    "software7"
    "software8"
)

SOFTWARE_SERVICES=(
    "software1"
    "software2"
    "software3"
    "software4"
    "software5"
    "software6"
    "software7"
    "software8"
)

SECONDARY_SOFTWARE_SERVICES=(
    "secondarysoftware1"
    "secondarysoftware2"
    "secondarysoftware3"
    "secondarysoftware4"
    "secondarysoftware5"
    "secondarysoftware6"
    "secondarysoftware7"
    "secondarysoftware8"
)

# clear shell and read operation choice
# ---------------------------------
clear
echo -e "$BLUE+$LINE+\n|$NC SOFWARE CONTROL $BLUE|\n+$LINE+\n\nOPERATIONS:\n$NC\n1)$NC ${GREEN}START$NC SOFTWARE\n2)$NC ${GREEN}START$NC SECONDARY SOFTWARE\n3)$NC ${RED}SHUTDOWN$NC SOFTWARE\n4)$NC ${RED}SHUTDOWN$NC SECONDARY SOFTWARE\n"

while true; do
    echo -e "${YELLOW}CHOOSE OPERATION:$NC \c"
    read OPERATION_CHOICE
    if [[ $OPERATION_CHOICE == "1" ]];
    then
        OPERATION_TYPE="START_SOFTWARE"
        break
    elif [[ $OPERATION_CHOICE == "2" ]];
    then
        OPERATION_TYPE="START_SECONDARY_SOFTWARE"
        break
    elif [[ $OPERATION_CHOICE == "3" ]];
    then
        OPERATION_TYPE="SHUTDOWN_SOFTWARE"
        break
    elif [[ $OPERATION_CHOICE == "4" ]];
    then
        OPERATION_TYPE="SHUTDOWN_SECONDARY_SOFTWARE"
        break
    else
        echo -e "${RED}\nINVALID OPTION. YOU MUST PICK A VALID OPERATION [1-4].$NC"
    fi
done

# read cluster choice
# ---------------------------------

if [[ $OPERATION_CHOICE == "1" || $OPERATION_CHOICE == "3" ]];
then
    echo -e "\n\n${BLUE}CLUSTERS:\n$NC\n1) cluster1\n2)$NC cluster2\n3)$NC cluster3\n4)$NC cluster4\n5)$NC cluster5\n6)$NC cluster6\n7)$NC cluster7\n8)$NC cluster8\n9)$NC custom\n"
else
    echo -e "\n\n${BLUE}CLUSTERS:\n$NC\n1) cluster7\n2)$NC cluster8\n"
fi

while true; do
    echo -e "${YELLOW}CHOOSE CLUSTER:$NC \c"
    read CLUSTER_CHOICE
    if [[ ($OPERATION_CHOICE == "2" && $CLUSTER_CHOICE == "1") || ($OPERATION_CHOICE == "4" && $CLUSTER_CHOICE == "1") ]];
    then
        CLUSTER='cluster7'
        break
    elif [[ ($OPERATION_CHOICE == "2" && $CLUSTER_CHOICE == "2") || ($OPERATION_CHOICE == "4" && $CLUSTER_CHOICE == "2") ]];
    then
        CLUSTER='cluster8'
        break
    elif [[ $CLUSTER_CHOICE == "1" ]];
    then
        CLUSTER='cluster1-01'
        break
    elif [[ $CLUSTER_CHOICE == "2" ]];
    then
        CLUSTER='cluster2-01'
        break
    elif [[ $CLUSTER_CHOICE == "3" ]];
    then
        CLUSTER='cluster3-01'
        break
    elif [[ $CLUSTER_CHOICE == "4" ]];
    then
        CLUSTER='cluster4-01'
        break
    elif [[ $CLUSTER_CHOICE == "5" ]];
    then
        CLUSTER='cluster5'
        break
    elif [[ $CLUSTER_CHOICE == "6" ]];
    then
        CLUSTER='cluster6'
        break
    elif [[ $CLUSTER_CHOICE == "7" ]];
    then
        CLUSTER='cluster7'
        break
    elif [[ $CLUSTER_CHOICE == "8" ]];
    then
        CLUSTER='cluster8'
        break
    elif [[ $CLUSTER_CHOICE == "9" ]];
    then
        echo -e "${YELLOW}ENTER CUSTOM CLUSTER NAME:$NC \c"
        read CLUSTER
        break
    else
        echo -e "${RED}\nINVALID OPTION. YOU MUST PICK A VALID CLUSTER OPTION [1-9].$NC"
    fi
done

# switch namespace to relevant cluster and confirm choice
# ---------------------------------

if [[ $CLUSTER == software-* ]]; 
then
    NAMESPACE="$CLUSTER"
else
    NAMESPACE="software-$CLUSTER"
fi

kubectl config use-context $NAMESPACE > /dev/null 2>&1
VERIFY_SWITCH_CONTEXT=$(kubectl.exe config view --minify | grep -i $NAMESPACE)
if [[ -z "$VERIFY_SWITCH_CONTEXT" ]]; 
then
    echo -e "\n${RED}UNABLE TO USE CONTEXT $NC$NAMESPACE$RED. DOUBLE-CHECK THE CLUSTER NAME AND TRY AGAIN.$NC"
    echo -e "${YELLOW}HINT:$NC HERE IS A LIST OF CONTEXTS CONFIGURED IN YOUR LOCAL."
    echo -e "IF YOU DO NOT SEE THE CLUSTER HERE, FOLLOW THESE INSTRUCTIONS TO ADD THE CLUSTER: [WIKI LINK HERE] \n\n"
    kubectl.exe config get-contexts
    exit 1
else
    echo -e "$CYAN\nYOU ARE CHOOSING TO ${OPERATION_TYPE//_/ } in $NAMESPACE$NC"
    echo -e "DO YOU WISH TO CONTINUE? (YES/NO) \c"
    while true; do
        read yn
        case $yn in
            [Yy]* )
                echo -e "[${GREEN}YES$NC] GREAT! CONTINUING...\n\n$BLUE$LINE$LINE$LINE$NC\n\n"
                break;;
            [Nn]* )
                echo -e "[${RED}NO$NC] YOU HAVE CHOSEN NOT TO CONTINUE... EXITING..."
                exit 1;;
            * ) echo -e "${RED}PLEASE ANSWER YES OR NO.$NC \c";;
        esac
    done
fi

# Perform operation
# ---------------------------------

FAILED_SERVICES=""
SUCCESS_COUNTER=0
FAILURE_COUNTER=0
if [[ $OPERATION_TYPE == "START_SOFTWARE" ]];
then
    echo -e "STARTING INITIAL PRIORITY SERVICES IN ORDER..."
    for SERVICE in "${START_SOFTWARE_SERVICES_FIRST[@]}"; do
        WAIT_COUNTER=0
        echo -e "\n\n${PURPLE}SERVICE:$NC $SERVICE"
        if kubectl scale --replicas=1 -n "$NAMESPACE" deployment/"$SERVICE" > /dev/null 2>&1;
        then
            echo -e "$GREEN$SERVICE STARTED!$NC"
            ((SUCCESS_COUNTER++))
        else
            echo -e "${RED}FAILED TO SCALE $SERVICE DEPLOYMENT. THE SERVICE MAY NOT EXIST IN THIS CLUSTER."
            FAILED_SERVICES+=" $SERVICE,"
            ((FAILURE_COUNTER++))
            continue
        fi
        while [[ $(kubectl get pods -n $NAMESPACE -l run=$SERVICE | grep Running | awk '{print $1}' | xargs -I {} kubectl get pod {} -n $NAMESPACE -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True" ]]; do
            if [[ $WAIT_COUNTER == 0 ]];
            then
                echo -e "WAITING ON $SERVICE TO BECOME STABLE BEFORE CONTINUING...";
                ((WAIT_COUNTER++))
            else
                echo -e "STILL WAITING..." && sleep 2
            fi
        done
    done
    echo -e "\n\n$BLUE$LINE$LINE$LINE$NC\n\nSTARTING THE REST OF THE SERVICES..."
    for SERVICE in "${SOFTWARE_SERVICES[@]}"; do
        if [[ ! " ${START_SOFTWARE_SERVICES_FIRST[@]} " =~ " ${SERVICE} " ]];
        then
            echo -e "\n\n${PURPLE}SERVICE:$NC $SERVICE"
            if kubectl scale --replicas=1 -n "$NAMESPACE" deployment/"$SERVICE" > /dev/null 2>&1; 
            then
                echo -e "$GREEN$SERVICE STARTED!$NC"
                ((SUCCESS_COUNTER++))
            else
                echo -e "${RED}FAILED TO SCALE $SERVICE DEPLOYMENT. THE SERVICE MAY NOT EXIST IN THIS CLUSTER."
                FAILED_SERVICES+=" $SERVICE,"
                ((FAILURE_COUNTER++))
            fi
        fi
    done
    echo -e "\n\n$LINE OVERVIEW $LINE\n\n"
    echo -e "$SUCCESS_COUNTER SERVICES WERE SCALED UP SUCCESSFULLY!"
    echo -e "$RED${FAILURE_COUNTER} SERVICES FAILED TO SCALE:$NC ${FAILED_SERVICES%,}"
# ---------------------------------
elif [[ $OPERATION_TYPE == "START_SECONDARY_SOFTWARE" ]];
then
    echo -e "\n\n$BLUE$LINE$LINE$LINE$NC\n\nSTARTING SERVICES..."
    for SERVICE in "${SECONDARY_SOFTWARE_SERVICES[@]}"; do
        echo -e "\n\n${PURPLE}SERVICE:$NC $SERVICE"
        if kubectl scale --replicas=1 -n "$NAMESPACE" deployment/"$SERVICE" > /dev/null 2>&1; 
        then
            echo -e "$GREEN$SERVICE STARTED!$NC"
            ((SUCCESS_COUNTER++))
        else
            echo -e "${RED}FAILED TO SCALE $SERVICE DEPLOYMENT. THE SERVICE MAY NOT EXIST IN THIS CLUSTER."
            FAILED_SERVICES+=" $SERVICE,"
            ((FAILURE_COUNTER++))
        fi
    done
    echo -e "\n\n$LINE OVERVIEW $LINE\n\n"
    echo -e "$SUCCESS_COUNTER SERVICES WERE SCALED UP SUCCESSFULLY!"
    echo -e "$RED${FAILURE_COUNTER} SERVICES FAILED TO SCALE:$NC ${FAILED_SERVICES%,}"
# ---------------------------------
elif [[ $OPERATION_TYPE == "SHUTDOWN_SOFTWARE" ]];
then
    echo -e "STOPPING SERVICES..."
    for SERVICE in "${SOFTWARE_SERVICES[@]}"; do
        echo -e "\n\n${PURPLE}SERVICE:$NC $SERVICE"
        if kubectl scale --replicas=0 -n "$NAMESPACE" deployment/"$SERVICE" > /dev/null 2>&1; 
        then
            echo -e "$GREEN$SERVICE STOPPED!$NC"
            ((SUCCESS_COUNTER++))
        else
            echo -e "${RED}FAILED TO SCALE $SERVICE DEPLOYMENT. THE SERVICE MAY NOT EXIST IN THIS CLUSTER."
            FAILED_SERVICES+=" $SERVICE,"
            ((FAILURE_COUNTER++))
        fi
    done
    echo -e "\n\n$LINE OVERVIEW $LINE\n\n"
    echo -e "$SUCCESS_COUNTER SERVICES WERE SCALED DOWN SUCCESSFULLY!"
    echo -e "$RED${FAILURE_COUNTER} SERVICES FAILED TO SCALE:$NC ${FAILED_SERVICES%,}"
# ---------------------------------
elif [[ $OPERATION_TYPE == "SHUTDOWN_SECONDARY_SOFTWARE" ]];
then
    echo -e "STOPPING SERVICES..."
    for SERVICE in "${SECONDARY_SOFTWARE_SERVICES[@]}"; do
        echo -e "\n\n${PURPLE}SERVICE:$NC $SERVICE"
        if kubectl scale --replicas=0 -n "$NAMESPACE" deployment/"$SERVICE" > /dev/null 2>&1; 
        then
            echo -e "$GREEN$SERVICE STOPPED!$NC"
            ((SUCCESS_COUNTER++))
        else
            echo -e "${RED}FAILED TO SCALE $SERVICE DEPLOYMENT. THE SERVICE MAY NOT EXIST IN THIS CLUSTER."
            FAILED_SERVICES+=" $SERVICE,"
            ((FAILURE_COUNTER++))
        fi
    done
    echo -e "\n\n$LINE OVERVIEW $LINE\n\n"
    echo -e "$SUCCESS_COUNTER SERVICES WERE SCALED DOWN SUCCESSFULLY!"
    echo -e "$RED${FAILURE_COUNTER} SERVICES FAILED TO SCALE:$NC ${FAILED_SERVICES%,}"
else
    echo -e "${RED}\nAN ERROR OCCURED, OPERATION TYPE ( $OPERATION_TYPE ) NOT DECLARED FROM OPERATION CHOICE ( $OPERATION_CHOICE ).$NC"
fi

echo -e "\n\n\n\n"