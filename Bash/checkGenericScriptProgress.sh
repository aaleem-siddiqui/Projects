#!/bin/bash
###########################################
# FILENAME: checkGenericScriptProgress.sh
# CREATOR: AALEEM SIDDIQUI
# DESCRIPTION: Checks the status of a script to see if it has completed gzipping files in the latest created directory 
###########################################

PID="/tmp/example_gzip_script.sh.lock"
SCRIPT_PROGRESS=$(cat ${PID} 2>/dev/null) #this lock file contains the pid of the script when executed


if [[ -f ${PID} ]]; then
        if [[ -s ${PID} && ! -z ${SCRIPT_PROGRESS} ]]; then
                EXAMPLE_SCRIPT_CHECK_PID=$(cat ${PID})
                if kill -0 ${EXAMPLE_SCRIPT_CHECK_PID} > /dev/null 2>&1; then
                        if [ $(ls -1 /example/directory/$(ls -1 /example/directory | tail -n1)/*.txt 2>/dev/null | wc -l) != '0' ]; then
                                echo "GZIPPING IS IN PROGRESS."
                        elif [ $(ls -1 /example/directory/$(ls -1 /example/directory | tail -n1)/*.bkp 2>/dev/null | wc -l) != '0' ]; then
                                echo "GZIPPING IS IN PROGRESS."
                        else
                                echo "ANOMALY DETECTED | THE LOCK FILE HAS BEEN FOUND, BUT THERE ARE NO FILES IN THE DIRECTORY."
                        fi
                else
                        echo "GZIPPING HAS BEEN COMPLETED."
                fi
        else
                echo "ANOMALY DETECTED | THE LOCK FILE HAS BEEN FOUND, BUT IT IS EMPTY WITH NO PID."
        fi
else
        echo "GZIPPING HAS BEEN COMPLETED."
fi