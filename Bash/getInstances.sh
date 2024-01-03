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
echo -e "${P}ENTER THE USER E-MAIL:$NC"
read EMAIL

#cut db host from servers.json
#--------------------------------
HOST=$(cat /pgadmin4/servers.json | grep -o '"Host":"[^"]*' | awk -F ':"' '{print $2}')

#assign PASSWORD based on host
#--------------------------------
if echo $HOST | grep -q "database1";
then
    PASSWORD="{{FAKEPASSWORD}}"
elif echo $HOST | grep -q "database2";
then
    PASSWORD="{{FAKEPASSWORD}}"
elif echo $HOST | grep -q "database3";
then
    PASSWORD="{{FAKEPASSWORD}}"
elif echo $HOST | grep -q "database4";
then
    PASSWORD="{{FAKEPASSWORD}}"

#convert e-mail var to all caps
#--------------------------------
USER_EMAIL=$(echo "$EMAIL" | tr '[:lower:]' '[:upper:]')

#psql query passed through shell
#--------------------------------
BP=${BP:-/usr/local/pgsql-11/psql}
QRY="SELECT \"ApplicationINSTANCEId\",\"INSTANCEs\".\"INSTANCEIdentifier\", \"UserINSTANCE\".\"Active\", \"State\" FROM public.\"UserINSTANCE\" FULL OUTER JOIN \"AspNetUsers\" ON \"Id\" = \"ApplicationUserId\" FULL OUTER JOIN \"INSTANCEs\" ON \"INSTANCEs\".\"Id\" = \"ApplicationINSTANCEId\" WHERE \"NormalizedEmail\" = '$USER_EMAIL' ORDER BY \"ApplicationINSTANCEId\" DESC;"
CLUSTER=$(echo $HOST | sed 's/-flex.*//' | tr '[:lower:]' '[:upper:]')
RSLT=$(PGPASSWORD="$PASSWORD" $BP -h "$HOST" -p "5432" -U "postgres" -d "DBTableName" -A -F ',' -t -c "$QRY" 2>&1)

#list INSTANCE info formatted
#--------------------------------
echo -e "\n\nLISTING INSTANCES FOR $OR$USER_EMAIL$NC IN $OR$CLUSTER$NC...\n$L$L$L$L$L\n"
cd /tmp/
echo "$RSLT" | while IFS=',' read -r INSTANCE_ID INSTANCE_NAME ACTIVE STATUS; do
    if [[ $ACTIVE == "t" && $STATUS == "1" ]];
    then
        AS="${GR}TRUE"
    else
        AS="${R}FALSE"
    fi
    echo -e "${NC}INSTANCE NAME:$Y $INSTANCE_NAME$NC\nINSTANCE ID:$LC $INSTANCE_ID$NC\nACTIVE:$LC $AS$NC\n\n$L\n"
    echo -ne "$INSTANCE_NAME," >> tempInstanceNames.txt
    echo $INSTANCE_ID > tempInstanceIDPlaceholder.txt
done

#catch errors if invalid e-mail is provided
#--------------------------------
ERROR_CHECK=$(wc -c tempInstanceIDPlaceholder.txt | awk '{print $1}')
if [[ $ERROR_CHECK == 37 ]]; then
    echo -e "${B}COPY THIS VALUE INTO THE 'EXISTING_INSTANCES' FIELD OF THE MULTI-INSTANCE USER AUTOMATION IF APPLICABLE:$Y\n"
    sed -i 's/^,//; s/,$//' tempInstanceNames.txt
    echo -e "\n$NC" >> tempInstanceNames.txt
    cat tempInstanceNames.txt
else
    echo -e "${R}SOMETHING WENT WRONG!$NC\nHINT: DOUBLE CHECK THE E-MAIL, IT MAY NOT EXIST IN $CLUSTER."
fi

#clean up files
#--------------------------------
rm tempInstanceNames.txt tempInstanceIDPlaceholder.txt
exit 1

#same version of the script but in one line
#--------------------------------
OR='\033[0;33m';R='\033[1;31m';GR='\033[1;32m';Y='\033[1;33m';B='\033[1;34m';LC='\033[1;36m';P='\033[1;35m';NC='\033[0m';L='------------'; clear; echo -e "${P}ENTER THE USER E-MAIL:$NC"; read EMAIL; HOST=$(cat /pgadmin4/servers.json | grep -o '"Host":"[^"]*' | awk -F ':"' '{print $2}'); if echo $HOST | grep -q "w-eu-load"; then PASSWORD="dEq4IXSG7W7Nc"; elif echo $HOST | grep -q "operations"; then PASSWORD="EYc9rJGZ8UJuy"; elif echo $HOST | grep -q "w-eu"; then PASSWORD="c_znrhi327Q6l-z5E0pVFGjewzpTajZPGRQaAaeOT5nVtAyAjt8korkkwnU4MAXqI891KPXIpYrVsl1e"; elif echo $HOST | grep -q "c-us"; then PASSWORD="wT8GJyyRpq04h"; fi; USER_EMAIL=$(echo "$EMAIL" | tr '[:lower:]' '[:upper:]'); BP=${BP:-/usr/local/pgsql-11/psql}; QRY="SELECT \"ApplicationINSTANCEId\",\"INSTANCEs\".\"INSTANCEIdentifier\", \"UserINSTANCE\".\"Active\", \"State\" FROM public.\"UserINSTANCE\" FULL OUTER JOIN \"AspNetUsers\" ON \"Id\" = \"ApplicationUserId\" FULL OUTER JOIN \"INSTANCEs\" ON \"INSTANCEs\".\"Id\" = \"ApplicationINSTANCEId\" WHERE \"NormalizedEmail\" = '$USER_EMAIL' ORDER BY \"ApplicationINSTANCEId\" DESC;"; CLUSTER=$(echo $HOST | sed 's/-flex.*//' | tr '[:lower:]' '[:upper:]'); RSLT=$(PGPASSWORD="$PASSWORD" $BP -h "$HOST" -p "5432" -U "postgres" -d "DBTableName" -A -F ',' -t -c "$QRY" 2>&1); echo -e "\n\nLISTING INSTANCES FOR $OR$USER_EMAIL$NC IN $OR$CLUSTER$NC...\n$L$L$L$L$L\n"; cd /tmp/; echo "$RSLT" | while IFS=',' read -r INSTANCE_ID INSTANCE_NAME ACTIVE STATUS; do if [[ $ACTIVE == "t" && $STATUS == "1" ]]; then AS="${GR}TRUE"; else AS="${R}FALSE"; fi; echo -e "${NC}INSTANCE NAME:$Y $INSTANCE_NAME$NC\nINSTANCE ID:$LC $INSTANCE_ID$NC\nACTIVE:$LC $AS$NC\n\n$L\n"; echo -ne "$INSTANCE_NAME," >> tempInstanceNames.txt; echo $INSTANCE_ID > tempInstanceIDPlaceholder.txt; done; ERROR_CHECK=$(wc -c tempInstanceIDPlaceholder.txt | awk '{print $1}'); if [[ $ERROR_CHECK == 37 ]]; then echo -e "${B}COPY THIS VALUE INTO THE 'EXISTING_INSTANCES' FIELD OF THE MULTI-INSTANCE USER AUTOMATION IF APPLICABLE:$Y\n"; sed -i 's/^,//; s/,$//' tempInstanceNames.txt; echo -e "\n$NC" >> tempInstanceNames.txt; cat tempInstanceNames.txt; else echo -e "${R}SOMETHING WENT WRONG!$NC\nHINT: DOUBLE CHECK THE E-MAIL. IT MAY NOT EXIST IN $CLUSTER"; fi; rm tempInstanceNames.txt tempInstanceIDPlaceholder.txt