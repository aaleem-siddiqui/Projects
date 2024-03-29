#!/bin/bash
###########################################
# FILENAME: getInstances.sh
# CREATOR: AALEEM SIDDIQUI
# DESCRIPTION: From the Shell CLI, gets instance information associated with an e-mail address from a PostgreSQL DB
###########################################

#colors
OR='\033[0;33m';R='\033[1;31m';GR='\033[1;32m';Y='\033[1;33m';B='\033[1;34m';LC='\033[1;36m';P='\033[1;35m';NC='\033[0m';L='------------';

#clean shell and input e-mail
#--------------------------------
clear
echo -e "${P}ENTER USER EMAIL:$NC"
read EML

#cut db host from servers.json
#--------------------------------
HOST=$(cat /pgadmin4/servers.json | grep -o '"Host":"[^"]*' | awk -F ':"' '{print $2}')
if [[ -z "$PW" ]]; then
    echo -e "${P}ENTER PASSWORD FOR USER 'postgres' IN ${HOST%%.*}:$NC"
    read -s PW
fi

#convert e-mail var to all caps
#--------------------------------
USER_EMAIL=$(echo "$EML" | tr '[:lower:]' '[:upper:]')

#psql query passed through shell
#--------------------------------
BP=${BP:-/usr/local/pgsql-11/psql}
QUERY="SELECT \"ApplicationINSTANCEId\",\"INSTANCEs\".\"INSTANCEIdentifier\", \"UserINSTANCE\".\"Active\", \"State\" FROM public.\"UserINSTANCE\" FULL OUTER JOIN \"AspNetUsers\" ON \"Id\" = \"ApplicationUserId\" FULL OUTER JOIN \"INSTANCEs\" ON \"INSTANCEs\".\"Id\" = \"ApplicationINSTANCEId\" WHERE \"NormalizedEmail\" = '$USER_EMAIL' ORDER BY \"ApplicationINSTANCEId\" DESC;"
CLUSTER=$(echo $HOST | sed 's/-flex.*//' | tr '[:lower:]' '[:upper:]')
RSLT=$(PGPASSWORD="$PASSWORD" $BP -h "$HOST" -p "5432" -U "postgres" -d "DBTableName" -A -F ',' -t -c "$QUERY" 2>&1)

#list INSTANCE info formatted
#--------------------------------
if [[ -z "$RSLT" ]]; #error handling
then
    echo -e "\n${R}ERROR!$NC\nCHECK THE EMAIL, IT MAY NOT EXIST IN $CLSTR."
elif echo $RSLT | grep -q 'connection'; #error handling 
then
    echo -e "\n${R}ERROR!$NC\nPASSWORD FOR USER 'postgres' IS PROBABLY WRONG."
    PW=''
else
    echo -e "\n\nLISTING INSTANCES FOR $OR$USER_EMAIL$NC IN $OR$CLSTR$NC...\n$L$L$L$L$L\n"
    cd /tmp/
    echo "$RSLT" | while IFS=',' read -r INSTANCE_ID INSTANCE_NAME ACTIVE STATUS;do
        if [[ $ACTIVE == "t" && $STATUS == "1" ]];
        then
            AS="${GR}TRUE"
        else
            AS="${R}FALSE"
        fi
        echo -e "${NC}NAME:$Y $INSTANCE_NAME$NC\nID:$LC $INSTANCE_ID$NC\nACTIVE:$LC $AS$NC\n\n$L\n"
        echo -ne "$INSTANCE_NAME," >> tempInstanceNames.txt
        echo $INSTANCE_ID > tempInstanceIDPlaceholder.txt
    done
    echo -e "${B}COPY VALUE INTO 'EXISTING_INSTANCES' FIELD OF USER ADMIN TOOL IF APPLICABLE:$Y\n"
    sed -i 's/^,//;s/,$//' tempInstanceNames.txt
    echo -e "\n$NC" >> tempInstanceNames.txt
    cat tempInstanceNames.txt
    #clean up files
    #--------------------------------
    rm tempInstanceNames.txt tempInstanceIDPlaceholder.txt
    exit 1
fi

#same version of the script but in one line
#--------------------------------
OR='\033[0;33m';R='\033[1;31m';GR='\033[1;32m';Y='\033[1;33m';B='\033[1;34m';LC='\033[1;36m';P='\033[1;35m';NC='\033[0m';L='------------';clear;echo -e "${P}ENTER USER EMAIL:$NC";read EML;HOST=$(cat /pgadmin4/servers.json | grep -o '"Host":"[^"]*' | awk -F ':"' '{print $2}');if [[ -z "$PW" ]];then echo -e "\n${P}ENTER PASSWORD FOR USER 'postgres' IN ${HOST%%.*}:$NC";read -s PW;fi;USER_EMAIL=$(echo "$EML" | tr '[:lower:]' '[:upper:]');BP=${BP:-/usr/local/pgsql-11/psql};QUERY="SELECT \"ApplicationINSTANCEId\",\"INSTANCES\".\"INSTANCEIdentifier\", \"UserINSTANCE\".\"Active\", \"State\" FROM public.\"UserINSTANCE\" FULL OUTER JOIN \"AspNetUsers\" ON \"Id\" = \"ApplicationUserId\" FULL OUTER JOIN \"INSTANCES\" ON \"INSTANCES\".\"Id\" = \"ApplicationINSTANCEId\" WHERE \"NormalizedEmail\" = '$USER_EMAIL' ORDER BY \"ApplicationINSTANCEId\" DESC;";CLSTR=$(echo $HOST | sed 's/-flex.*//' | tr '[:lower:]' '[:upper:]');RSLT=$(PGPASSWORD="$PW" $BP -h "$HOST" -p "5432" -U "postgres" -d "AuthorizationProvider" -A -F ',' -t -c "$QUERY" 2>&1);if [[ -z "$RSLT" ]];then echo -e "\n${R}ERROR!$NC\nCHECK THE EMAIL, IT MAY NOT EXIST IN $CLSTR.";elif echo $RSLT | grep -q 'connection';then echo -e "\n${R}ERROR!$NC\nPASSWORD FOR USER 'postgres' IS PROBABLY WRONG.";PW='';else echo -e "\n\nLISTING INSTANCES FOR $OR$USER_EMAIL$NC IN $OR$CLSTR$NC...\n$L$L$L$L$L\n";cd /tmp/;echo "$RSLT" | while IFS=',' read -r INSTANCE_ID INSTANCE_NAME ACTIVE STATUS;do if [[ $ACTIVE == "t" && $STATUS == "1" ]];then AS="${GR}TRUE";else AS="${R}FALSE";fi;echo -e "${NC}NAME:$Y $INSTANCE_NAME$NC\nID:$LC $INSTANCE_ID$NC\nACTIVE:$LC $AS$NC\n\n$L\n";echo -ne "$INSTANCE_NAME," >> tempInstanceNames.txt;echo $INSTANCE_ID > tempInstanceIDPlaceholder.txt;done;echo -e "${B}COPY VALUE INTO 'EXISTING_INSTANCES' FIELD OF USER ADMIN TOOL IF APPLICABLE:$Y\n";sed -i 's/^,//;s/,$//' tempInstanceNames.txt;echo -e "\n$NC" >> tempInstanceNames.txt;cat tempInstanceNames.txt;rm tempInstanceNames.txt tempInstanceIDPlaceholder.txt;fi;