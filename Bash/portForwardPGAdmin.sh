#!/bin/bash
###########################################
# FILENAME: portForwardPGAdmin.sh
# CREATOR: AALEEM SIDDIQUI
# DESCRIPTION: Port forwards to pgAdmin within a kubernetes cluster of your choice, opens browser and provides login credentials.
###########################################

#colors
CYAN='\033[1;36m';RED='\033[1;31m';GREEN='\033[1;32m';YELLOW='\033[1;33m';BLUE='\033[1;34m';PURPLE='\033[1;35m';NC='\033[0m'
LINE='----------------------'

#clear shell and read cluster choice
clear
echo -e "$BLUE+$LINE+\n|$NC PGADMIN PORT FORWARD |\n$BLUE+$LINE+\n\nCLUSTER LIST:$PURPLE\n\n1)$NC CLUSTER1$PURPLE\n2)$NC CLUSTER2$PURPLE\n3)$NC CLUSTER3$PURPLE\n4)$NC CLUSTER4$PURPLE\n5)$NC CLUSTER5"
echo -e "$YELLOW\nCHOOSE CLUSTER OPTION:$NC"
read CHOICE
echo -e "$CYAN\nPLEASE WAIT..."

if [[ $CHOICE == "1" ]];
then
    CLUSTER='CLUSTER1-01'
    NAMESPACE='CLUSTER1'
elif [[ $CHOICE == "2" ]];
then
    CLUSTER='CLUSTER2-01'
elif [[ $CHOICE == "3" ]];
then
    CLUSTER='CLUSTER3-01'
elif [[ $CHOICE == "4" ]];
then
    CLUSTER='CLUSTER4'
elif [[ $CHOICE == "5" ]];
then
    CLUSTER='CLUSTER5'
else
    echo -e "${RED}\nINVALID OPTION. YOU MUST PICK A CLUSTER OPTION [1-5].$NC"
    exit 1
fi

if [[ $CHOICE != "1" ]];
then
    NAMESPACE=$CLUSTER
fi

#switch cluster
kubectl config use-context genericCompanyName-$CLUSTER > /dev/null 2>&1

#get info from k8s
NAMESPACE="genericCompanyName-$NAMESPACE"
PODNAME=$(kubectl get pods -n $NAMESPACE | awk '$1 ~ /^pgadmin/ {print $1}')
EMAIL=$(kubectl exec -it -n $NAMESPACE $PODNAME -- env 2>/dev/null | grep 'PGADMIN_DEFAULT_EMAIL' | cut -d'=' -f2)
PASSWORD=$(kubectl exec -it -n $NAMESPACE $PODNAME -- env 2>/dev/null | grep 'PGADMIN_DEFAULT_PASSWORD' | cut -d'=' -f2)

echo -e "${GREEN}STARTING PORT FORWARD TO PGADMIN IN $CLUSTER.$NC YOUR BROWSER WILL OPEN SHORTLY.\nTYPE$RED CTRL + C$NC TO EXIT PORT FORWARDING...\n\n\nUSE THE FOLLOWING CREDENTIALS TO LOGIN TO PGADMIN:\n$RED\nEMAIL: $NC$EMAIL$RED\nPASSWORD:$NC $PASSWORD"

#open browser
start http://localhost:3002/login

#forward port
while true; do
    kubectl port-forward -n $NAMESPACE services/pgadmin4 3002:80 > /dev/null 2>&1
done

#same version of the script but in one line
CYAN='\033[1;36m';RED='\033[1;31m';GREEN='\033[1;32m';YELLOW='\033[1;33m';BLUE='\033[1;34m';PURPLE='\033[1;35m';NC='\033[0m';LINE='----------------------';clear;echo -e "$BLUE+$LINE+\n|$NC PGADMIN PORT FORWARD |\n$BLUE+$LINE+\n\nCLUSTER LIST:$PURPLE\n\n1)$NC CLUSTER1$PURPLE\n2)$NC CLUSTER2$PURPLE\n3)$NC CLUSTER3$PURPLE\n4)$NC CLUSTER4$PURPLE\n5)$NC CLUSTER5";echo -e "$YELLOW\nCHOOSE CLUSTER OPTION:$NC";read CHOICE;echo -e "$CYAN\nPLEASE WAIT...";if [[ $CHOICE == "1" ]]; then CLUSTER='CLUSTER1-01'; NAMESPACE='CLUSTER1'; elif [[ $CHOICE == "2" ]]; then CLUSTER='CLUSTER2-01'; elif [[ $CHOICE == "3" ]]; then CLUSTER='CLUSTER3-01'; elif [[ $CHOICE == "4" ]]; then CLUSTER='CLUSTER4'; elif [[ $CHOICE == "5" ]]; then CLUSTER='CLUSTER5'; else echo -e "${RED}\nINVALID OPTION. YOU MUST PICK A CLUSTER OPTION [1-5].$NC"; exit 1; fi; if [[ $CHOICE != "1" ]]; then NAMESPACE=$CLUSTER; fi; kubectl config use-context genericCompanyName-$CLUSTER > /dev/null 2>&1; NAMESPACE="genericCompanyName-$NAMESPACE"; PODNAME=$(kubectl get pods -n $NAMESPACE | awk '$1 ~ /^pgadmin/ {print $1}'); EMAIL=$(kubectl exec -it -n $NAMESPACE $PODNAME -- env 2>/dev/null | grep 'PGADMIN_DEFAULT_EMAIL' | cut -d'=' -f2); PASSWORD=$(kubectl exec -it -n $NAMESPACE $PODNAME -- env 2>/dev/null | grep 'PGADMIN_DEFAULT_PASSWORD' | cut -d'=' -f2); echo -e "${GREEN}STARTING PORT FORWARD TO PGADMIN IN $CLUSTER.$NC YOUR BROWSER WILL OPEN SHORTLY.\nTYPE$RED CTRL + C$NC TO EXIT PORT FORWARDING...\n\n\nUSE THE FOLLOWING CREDENTIALS TO LOGIN TO PGADMIN:\n$RED\nEMAIL: $NC$EMAIL$RED\nPASSWORD:$NC $PASSWORD"; start http://localhost:3002/login; while true; do kubectl port-forward -n $NAMESPACE services/pgadmin4 3002:80 > /dev/null 2>&1; done