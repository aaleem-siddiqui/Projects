#!/bin/bash
###########################################
# FILENAME: createRecoveryUser.ps1
# DESCRIPTION: Creates a recovery user for a windows application that you are locked out of.
###########################################


# defining variables
RED='\033[1;31m'; GREEN='\033[1;32m'; YELLOW='\033[1;33m'; PURPLE='\033[1;36m'; PINK='\033[1;35m'; PURPLE='\033[1;34m'; NC='\033[0m'
SERVICE_NAME="APPLICATIONOS"
SOURCE_PATH="/c/Program Files/APPLICATION/os"
PROCESS_NAME="Application.Suite.Services.SingleProcess"
APPLICATION_URL="http://localhost:5000/shell/"
FAILURE_COUNTER=0
RETRY_LIMIT=5

# function that gets the status of the application
GET_SERVICE_STATUS() {
    sc queryex state= all | grep -i "$SERVICE_NAME" -B1 -A10 | grep -i "state"
}

KILL_PID() {
    PID_PROCESS=$(ps axf | awk "/${PROCESS_NAME}/ {print \$1}")
    if [ -n "$PID_PROCESS" ]; then
        kill -9 "$PID_PROCESS"
    fi
}

echo -e "SCRIPT START.\nNAVIGATING TO SOURCE PATH..."
cd "$SOURCE_PATH"
echo -e "WE ARE HERE: $PURPLE$(pwd)$NC\nSTOPPING THE $SERVICE_NAME SERVICE..."

while true; do
    net stop "$SERVICE_NAME" >> /dev/null 2>&1
    sleep 5
    CHECK_SERVICE_STATUS=$(GET_SERVICE_STATUS)
    if echo $CHECK_SERVICE_STATUS | grep -q "RUNNING";
    then
        echo -e "$RED$SERVICE_NAME FAILED TO STOP. EXITING...$NC"
        exit 1
    else
        echo -e "$RED$SERVICE_NAME STOPPED!$NC"
        break
    fi
done

echo -e "RUNNING ($PURPLE./$PROCESS_NAME repair=True$NC) IN ORDER TO RETRIEVE RECOVERY CREDENTIALS\nPLEASE WAIT..."
KILL_PID
credentials=$(./Application.Suite.Services.SingleProcess.exe repair=True | awk '
    /------ Recovery user ------/ {flag=1; next}
    /---------------------------/ {flag=0; exit}
    flag
' &)

if [[ -z $credentials ]]; then
    echo -e "${RED}FAILED TO RETRIEVE CREDENTIALS!$NC"
else
    echo -e "${GREEN}CREDENTIALS RETRIEVED!$NC"
fi

FORMATTED_CREDENTIALS="$YELLOW------ Recovery user ------$NC\n$(echo "$credentials" | awk 'NR==1')\n$(echo "$credentials" | awk 'NR==2')\n$YELLOW---------------------------$NC"
echo -e "$FORMATTED_CREDENTIALS"
KILL_PID

echo -e "STARTING THE $SERVICE_NAME SERVICE..."
while true; do
    net start "$SERVICE_NAME" >> /dev/null 2>&1
    sleep 5
    CHECK_SERVICE_STATUS=$(GET_SERVICE_STATUS)
    if echo $CHECK_SERVICE_STATUS | grep -q "RUNNING";
    then
        echo -e "$GREEN$SERVICE_NAME STARTED!$NC\nOPENING APPLICATION IN YOUR WEB BROWSER..."
        start "$APPLICATION_URL"
        echo -e "SCRIPT COMPLETE."
        exit 1
    else
        if [[ $FAILURE_COUNTER > $RETRY_LIMIT ]]; then
            echo -e "$RED$SERVICE_NAME FAILED TO START. EXITING...$NC"
            exit 1
        fi
        echo -e "$RED$SERVICE_NAME FAILED TO START. RETRYING...$NC"
        echo -e "TRIES: $FAILURE_COUNTER/$RETRY_LIMIT"
        (( FAILURE_COUNTER++ ))
    fi
done

exit 1