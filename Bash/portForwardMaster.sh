#!/bin/bash
###########################################
# FILENAME: portForwardMaster.sh
# CREATOR: AALEEM SIDDIQUI
# DESCRIPTION: Port forwards to pgAdmin, Grafana, or RabbitMQ within a cluster of your choice, opens browser and provides login credentials. Copy the code block into your git bash window to use.
###########################################

#colors
CYAN='\033[1;36m';RED='\033[1;31m';GREEN='\033[1;32m';YELLOW='\033[1;33m';BLUE='\033[1;34m';PURPLE='\033[1;35m';NC='\033[0m'
LINE='---------------------'

#clear shell and read service choice
# ---------------------------------
clear
echo -e "$BLUE+$LINE+\n|$NC PORT FORWARD MASTER $BLUE|\n+$LINE+\n\nSERVICES:$PURPLE\n\n1)$NC PGAdmin$PURPLE\n2)$NC Grafana$PURPLE\n3)$NC RabbitMQ\n"

while true; do
    echo -e "${YELLOW}CHOOSE SERVICE:$NC \c"
    read SERVICE_CHOICE
    if [[ $SERVICE_CHOICE == "1" ]];
    then
        PODNAME_GREP='pgadmin'
        EMAIL_GREP='PGADMIN_DEFAULT_EMAIL'
        PASSWORD_GREP='PGADMIN_DEFAULT_PASSWORD'
        SERVICE_PATH='services/pgadmin4'
        PORT_RANGE=3000
        TCP_PORT=80
        break
    elif [[ $SERVICE_CHOICE == "2" ]];
    then
        PODNAME_GREP='grafana'
        EMAIL_GREP='GF_SECURITY_ADMIN_USER'
        PASSWORD_GREP='GF_SECURITY_ADMIN_PASSWORD'
        SERVICE_PATH='services/prometheus-grafana'
        NAMESPACE='monitoring'
        PORT_RANGE=3000
        TCP_PORT=80
        break
    elif [[ $SERVICE_CHOICE == "3" ]];
    then
        PODNAME_GREP='RabbitMQ'
        PORT_RANGE=50120
        TCP_PORT=15672
        break
    else
        echo -e "${RED}\nINVALID OPTION. YOU MUST PICK A VALID SERVICE OPTION [1-3].$NC"
    fi
done

# read cluster choice
# ---------------------------------

echo -e "\n\n${BLUE}CLUSTERS:$PURPLE\n\n1)$NC CLUSTER1$PURPLE\n2)$NC CLUSTER2$PURPLE\n3)$NC CLUSTER3$PURPLE\n4)$NC CLUSTER4$PURPLE\n5)$NC CLUSTER5$PURPLE\n6)$NC CLUSTER6$PURPLE\n7)$NC CLUSTER7\n"

while true; do
    echo -e "${YELLOW}CHOOSE CLUSTER:$NC \c"
    read CLUSTER_CHOICE
    if [[ $CLUSTER_CHOICE == "1" ]];
    then
        CLUSTER='CLUSTER1'
        break
    elif [[ $CLUSTER_CHOICE == "2" ]];
    then
        CLUSTER='CLUSTER2'
        break
    elif [[ $CLUSTER_CHOICE == "3" ]];
    then
        CLUSTER='CLUSTER3'
        break
    elif [[ $CLUSTER_CHOICE == "4" ]];
    then
        CLUSTER='CLUSTER4'
        break
    elif [[ $CLUSTER_CHOICE == "5" ]];
    then
        CLUSTER='CLUSTER5'
        break
    elif [[ $CLUSTER_CHOICE == "6" ]];
    then
        CLUSTER='CLUSTER6'
        break
    elif [[ $CLUSTER_CHOICE == "7" ]];
    then
        CLUSTER='CLUSTER7'
        break
    else
        echo -e "${RED}\nINVALID OPTION. YOU MUST PICK A VALID CLUSTER OPTION [1-7].$NC"
    fi
done

echo -e "$CYAN\n\nPLEASE WAIT..."

if [[ $SERVICE_CHOICE != "2" && $CLUSTER_CHOICE != "1" ]];
then
    NAMESPACE="software-$CLUSTER"
elif [[ $SERVICE_CHOICE != "2" && $CLUSTER_CHOICE == "1" ]];
then
    NAMESPACE='software-CLUSTER1'
fi

# switch cluster get info from k8s
# ---------------------------------

kubectl config use-context software-$CLUSTER > /dev/null 2>&1


PODNAME=$(kubectl get pods -n $NAMESPACE | grep -i "$PODNAME_GREP.*Running" | awk '{print $1}')
if [[ $SERVICE_CHOICE == "3" ]];
then
    EMAIL='software'
    PASSWORD=$(kubectl.exe get secret rabbitmq-secret -n $NAMESPACE -o jsonpath='{.data.rabbitmq-password}' | base64 --decode)
    SERVICE_PATH="pod/$PODNAME"
else
    EMAIL=$(kubectl exec -it -n $NAMESPACE $PODNAME -- env 2>/dev/null | grep "$EMAIL_GREP" | cut -d'=' -f2)
    PASSWORD=$(kubectl exec -it -n $NAMESPACE $PODNAME -- env 2>/dev/null | grep "$PASSWORD_GREP" | cut -d'=' -f2)
fi


echo -e "${GREEN}STARTING PORT FORWARD TO $PODNAME_GREP IN $CLUSTER.$NC YOUR BROWSER WILL OPEN SHORTLY."

# find open port and open browser
# ---------------------------------

RANDOM_PORT=$((RANDOM % 101 + $PORT_RANGE))
start "http://localhost:${RANDOM_PORT}/"

echo -e "TYPE$RED CTRL + C$NC TO EXIT PORT FORWARDING...\n\n\nUSE THE FOLLOWING CREDENTIALS TO LOGIN:\n$RED\nEMAIL: $NC$EMAIL$RED\nPASSWORD:$NC $PASSWORD"

# forward port
# ---------------------------------
while true; do
        kubectl port-forward -n $NAMESPACE $SERVICE_PATH $RANDOM_PORT:$TCP_PORT > /dev/null 2>&1
done