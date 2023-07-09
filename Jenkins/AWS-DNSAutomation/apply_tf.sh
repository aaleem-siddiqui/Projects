#!/bin/bash

#loop to apply terraform

cat tf_paths.txt | while read line
do
   set +x
   cd $line
   profile=$(cat providers.tf | grep profile -m 1 | cut -d '"' -f 2)
   account=$(echo $line | cut -d "/" -f 2)
   if [[ $account == "AWSaccount1" ]];
   then
      account_number="AWSaccount1#"
   elif [[ $account == "AWSaccount2" ]];
   then
      account_number="AWSaccount2#"
   else
      echo "Unable to read account name."
   fi

   #assumes credentials for account in question
   creds=$(aws sts assume-role --role-arn=arn:aws:iam::${account_number}:role/DNS-Automation-Role --role-session-name=genericSessionName)
   sudo echo "[$profile]" > ~/.aws/credentials
   sudo echo "aws_access_key_id=$(echo $creds | cut -d '"' -f 6 )" >> ~/.aws/credentials
   sudo echo "aws_secret_access_key=$(echo $creds | cut -d '"' -f 10 )" >> ~/.aws/credentials
   sudo echo "aws_session_token=$(echo $creds | cut -d '"' -f 14 )" >> ~/.aws/credentials
   
   set -x
   echo -e "\n\n\n\nAPPLYING TERRAFORM TO THE FOLLOWING DIRECTORY: $line"
   terraform init
   terraform apply -auto-approve
   ls -al
   cd ../../..
   echo -e "\n\n\n\n\n\n\n\n"
done