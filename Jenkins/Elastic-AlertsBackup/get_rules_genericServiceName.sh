#!/bin/bash
###########################################
# FILENAME: get_rules_genericServiceName.sh
# CREATOR: AALEEM SIDDIQUI
# DESCRIPTION: gets a set of alarm rules from elastic for a specific service
###########################################
#             CHANGE_LOG
#    - replaced API Key with variable being passed while executing script
#    - replaced authorization type from Basic to ApiKey
#    - updated path for files based on bitbucket repo
###########################################
 
FULL_LIST=$(curl --silent --location --request GET 'https://genericCompanyName.elastic.us-east-1.aws.found.io:1234/genericServiceName/api/genericServiceName/rules/_find?page=1&per_page=100&fields=id&fields=name' --header 'Content-Type: application/json;charset=UTF-8' --header 'header: true' --header "Authorization: ApiKey $1" 2>/dev/null)
FULL_IDS=$(echo ${FULL_LIST} | jq '.data[].id' | sed 's/\"//g')
for i in ${FULL_IDS[@]}
do
    NAME=$(echo ${FULL_LIST} | jq '.data[] | {id,name}' | grep -A1 "${i}" | grep "name" | awk -F\" '{print $4}' | sed 's/ /_/g')
    curl --silent --location --request GET 'https://genericCompanyName.elastic.us-east-1.aws.found.io:1234/genericServiceName/api/genericServiceName/rule/'"${i}"'' --header 'Content-Type: application/json;charset=UTF-8' --header 'header: true' --header "Authorization: ApiKey $1" | python3 -m json.tool > genericServiceName-backup/genericServiceName_rules/${NAME}.groovy
    echo "Generating ... ${NAME},${i}"
done
