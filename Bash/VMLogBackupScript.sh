#!/bin/bash
# Description: This script automates log rotation between disks on the a VM.  

#colors
RED='\033[1;31m';GREEN='\033[1;32m';YELLOW='\033[1;33m';BLUE='\033[1;36m';PURPLE='\033[1;35m';NC='\033[0m'

# get current date/time function
GET_CURRENT_TIME() {
    date '+%Y-%m-%d_%H-%M-%S'
}

# logging function
LOG_OUTPUT() {
    echo -e "$GREEN$(GET_CURRENT_TIME)$NC | $1" >> $SOURCE_PATH/$BACKUP_SCRIPT_LOG_NAME 2>&1
}

# function that gets the status of the SERVICENAME connector
GET_SERVICE_STATUS() {
    sc queryex state= all | grep -i "$SERVICE_DISPLAY_NAME" -B1 -A10 | grep -i "state"
}

#variables
SOURCE_PATH="/d/SERVICENAME_Log"
TARGET_PATH="/c/LogFilesFromD"
SERVICE_NAME="SERVICENAMEBO"
SERVICE_DISPLAY_NAME=" SERVICENAME connector"
BACKUP_SCRIPT_LOG_NAME="SERVICENAMEConnectorBackupScript.log"
BACKUP_SCRIPT_LOG_FILE_SIZE=$(stat -c%s "$BACKUP_SCRIPT_LOG_NAME")
LOG_FILE_NAME=$(ls -alt | grep -i "SERVICENAMEConnector_Log_" | head -n2 | tail -n1 | awk '{print $NF}')
DIRECTORY_NAME="${LOG_FILE_NAME%.txt}/"
ZIP_FILE_NAME="${LOG_FILE_NAME%.txt}.zip"
FILE_SIZE_THRESHOLD=$((5 * 1024 * 1024)) #5MB in bytes
FAILURE_COUNTER=0
RETRY_LIMIT=5

#--------------------------------------------------------------------------------------------------------------------------------
#script start / check self-log for rotation

LOG_OUTPUT "\n\n\n\n${PURPLE}------------------------------------------------------------------------------------$NC\n\n"
LOG_OUTPUT "\t -- SCRIPT START --$NC"
LOG_OUTPUT "NAVIGATING TO SOURCE PATH ($BLUE$SOURCE_PATH$NC)..."
cd $SOURCE_PATH
LOG_OUTPUT "WE ARE HERE: $PURPLE$(pwd)$NC"
LOG_OUTPUT "CHECKING THE $BACKUP_SCRIPT_LOG_NAME FILE SIZE FOR ROTATION..."
if [[ "$BACKUP_SCRIPT_LOG_FILE_SIZE" -gt "$FILE_SIZE_THRESHOLD" ]]; then
    LOG_OUTPUT "THE $BACKUP_SCRIPT_LOG_NAME EXCEEDS THE FILE SIZE THRESHOLD! ($BLUE$BACKUP_SCRIPT_LOG_FILE_SIZE$NC/$BLUE$FILE_SIZE_THRESHOLD$NC)"
    LOG_OUTPUT "ROTATING $BACKUP_SCRIPT_LOG_NAME..."
    mv -v $BACKUP_SCRIPT_LOG_NAME "${BACKUP_SCRIPT_LOG_NAME%.log}.txt" && echo '' > $BACKUP_SCRIPT_LOG_NAME
else
    LOG_OUTPUT "THE $BACKUP_SCRIPT_LOG_NAME IS WITHIN THE FILE SIZE THRESHOLD ($BLUE$BACKUP_SCRIPT_LOG_FILE_SIZE$NC/$BLUE$FILE_SIZE_THRESHOLD$NC). NO ACTION NEEDED."
fi

#--------------------------------------------------------------------------------------------------------------------------------
#simulates restarting the service and creating a new log | prevents any log overwrite

LOG_OUTPUT "CHECKING FOR CURRENT LOG IN SOURCE PATH..."
if ls -al | grep -q "SERVICENAMEConnector_Log_$(date '+%Y_%m_%d').txt"
then
    LOG_OUTPUT "LOG EXISTS BUT IS TIME-STAMPTED FOR THE CURRENT DAY. PREVENTING LOG OVERWRITE..."
    cp -p SERVICENAMEConnector_Log_$(date '+%Y_%m_%d').txt SERVICENAMEConnector_Log_$(date '+%Y_%m_%d').$(ls -1 | grep -i "SERVICENAMEConnector_Log_$(date '+%Y_%m_%d').txt" | wc -l).txt && echo '' > SERVICENAMEConnector_Log_$(date '+%Y_%m_%d').txt
else
    LOG_OUTPUT "LOG EXISTS AND IS TIME-STAMPTED FOR A PREVIOUS DAY. LOG WILL NOT BE OVERWRITTEN WHEN SERVICE IS RESTARTED."
fi

#--------------------------------------------------------------------------------------------------------------------------------
# restarting the  SERVICENAME connector service | checks service to confirm successful restart

LOG_OUTPUT "RESTARTING THE $SERVICE_NAME SERVICE...\n$YELLOW"
while true; do
    net stop "$SERVICE_NAME" >> $SOURCE_PATH/$BACKUP_SCRIPT_LOG_NAME 2>&1
    sleep 5
    CHECK_SERVICE_STATUS=$(GET_SERVICE_STATUS)
    if echo $CHECK_SERVICE_STATUS | grep -q "RUNNING";
    then
        LOG_OUTPUT "$RED THE SERVICE FAILED TO STOP. EXITING...$NC"
        exit 1
    else
        break
    fi
done

while true; do
    net start "$SERVICE_NAME" >> $SOURCE_PATH/$BACKUP_SCRIPT_LOG_NAME 2>&1
    sleep 5
    CHECK_SERVICE_STATUS=$(GET_SERVICE_STATUS)
    if echo $CHECK_SERVICE_STATUS | grep -q "RUNNING";
    then
        LOG_OUTPUT "THE SERVICE RESTARTED SUCCESSFULLY! NEW LOG FILE CREATED."
        break
    else
        if [[ $FAILURE_COUNTER > $RETRY_LIMIT ]]; then
            LOG_OUTPUT "$RED THE SERVICE FAILED TO START. EXITING...$NC"
            exit 1
        fi
        LOG_OUTPUT "$RED THE SERVICE FAILED TO START. RETRYING...$NC"
        LOG_OUTPUT "TRIES: $FAILURE_COUNTER/$RETRY_LIMIT"
        (( FAILURE_COUNTER++ ))
    fi
done

#--------------------------------------------------------------------------------------------------------------------------------
# rename old log, compress it, move it to backup folder

LOG_OUTPUT "CREATING DIRECTORY & MOVING LOGS...\n$YELLOW"
mkdir $DIRECTORY_NAME >> $SOURCE_PATH/$BACKUP_SCRIPT_LOG_NAME 2>&1
find $SOURCE_PATH -maxdepth 1 -type f -name "*.txt" -exec mv -v {} $DIRECTORY_NAME \; >> $SOURCE_PATH/$BACKUP_SCRIPT_LOG_NAME 2>&1
LOG_OUTPUT ""
LOG_OUTPUT "CREATING COMPRESSED ZIP OF DIRECTORY...\n$YELLOW"
zip.exe -r $ZIP_FILE_NAME $DIRECTORY_NAME >> $SOURCE_PATH/$BACKUP_SCRIPT_LOG_NAME 2>&1
LOG_OUTPUT ""
LOG_OUTPUT "ROTATING LOG TO TARGET PATH AND CLEANING UP FILES... ($BLUE$TARGET_PATH$NC)$YELLOW"
mv -v $ZIP_FILE_NAME $TARGET_PATH/SERVICENAME_CONNECTOR_LOG_$(GET_CURRENT_TIME).zip && rm -rf $DIRECTORY_NAME >> $SOURCE_PATH/$BACKUP_SCRIPT_LOG_NAME 2>&1

#--------------------------------------------------------------------------------------------------------------------------------
# delete any backups older than 30 days | -mmin 60 = 60 minutes | -mtime .5 = 12 hours

LOG_OUTPUT "NAVIGATING TO TARGET PATH ($BLUE$TARGET_PATH$NC)..."
cd $TARGET_PATH
LOG_OUTPUT "WE ARE HERE: $PURPLE$(pwd)$NC"
LOG_OUTPUT "LOOKING FOR BACKUPS OLDER THAN 30 DAYS..."
if [ -z $(find . -type f -mtime +30 -name "*.zip") ];
then 
    LOG_OUTPUT "NOTHING TO REMOVE."
else
    LOG_OUTPUT "CLEANING UP FILES:$RED"
    find . -type f -mtime +30 -name "*.zip" -print -exec rm {} \; >> $SOURCE_PATH/$BACKUP_SCRIPT_LOG_NAME 2>&1
fi
LOG_OUTPUT "\t -- SCRIPT END --$NC"
