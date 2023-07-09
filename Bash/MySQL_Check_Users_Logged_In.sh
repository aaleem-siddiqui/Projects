#!/bin/bash
###########################################
# FILENAME: MySQL_Check_Users_Logged_In.sh
# CREATOR: AALEEM SIDDIQUI
# DESCRIPTION: Checks to see if there are any users still logged into a system
###########################################


if [ "$(mysql db -e "select user_uid, identificationNumber, firstName, lastName, logInTimestamp, logOutTimestamp from Timestamps, users where Timestamps.user_uid = users.user_uid and logOutTimestamp is null" | wc -l)" -ge 1 ]; 
then 
	mysql db -e "select user_uid, identificationNumber, firstName, lastName, logInTimestamp, logOutTimestamp from Timestamps, users where Timestamps.user_uid = users.user_uid and logOutTimestamp is null"
else 
	echo -e "\n \n \n\033[0;31mthere is no one logged in :-( \033[m \n \n \n"
fi 
