#!/bin/bash
###########################################
# FILENAME: secretManager.sh
# CREATOR: AALEEM SIDDIQUI
# DESCRIPTION: simple script to loop through csv file and display comma seperated values
###########################################

#colors
clear
RED='\033[1;31m';GREEN='\033[1;32m';YELLOW='\033[1;33m';BLUE='\033[1;34m';NC='\033[0m'
LINE='----------------'
LINE2='****************'

#header
echo -e "\n\n$BLUE+$LINE+\n|$NC SECRET MANAGER $YELLOW|\n+$LINE+\n$RED\nWARNING. DO NOT SHARE.\n\n\n$NC$LINE2$LINE2\n\n$NC"

#filename
FILE="secrets.csv"

#loop to display name,key,value in file
while IFS=',' read -r NAME KEY VALUE || [[ -n "$KEY" ]]; do
    echo -e "[$NAME]\n${GREEN}KEY:$NC $KEY\n${GREEN}VALUE:$NC $VALUE\n\n"
done < "$FILE"
