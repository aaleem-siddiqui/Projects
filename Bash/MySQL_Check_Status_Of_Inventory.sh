#!/bin/bash
###########################################
# FILENAME: MySQL_Check_Status_Of_Inventory.sh
# CREATOR: AALEEM SIDDIQUI
# DESCRIPTION: Checks the status of inventory items for sale on a specific business date
###########################################



if [ "$(mysql db -e "select inventoryItem_status_uid,inventoryItem_number,department_number,status,date,sold_time,is_for_sale from inventoryItem_status where date is null" | wc -l)" -ge 1 ];
then 
	for_sale='\e[92m'
	in_progress='\e[93m'
	sold='\e[91m'
	nocolor='\e[0m'
	fstring="| %10s | %13s | %8s |"
	fstringe="| %-10s | %-19s | %10s |\n"
	fstrings="| %-10s | %10s %8s | %10s |\n"
	string="+------------+---------------+----------+--------+------------+---------------------+------------+\n"
	printf $string
	mysql db -e "SELECT inventoryItem_status_uid AS inventoryItem_uid, inventoryItem_number AS inventoryItem_number, department_number AS department, status AS Status, date AS Date, sold_time AS sold_time, is_for_sale AS is_for_sale FROM inventoryItem_status WHERE date is NULL" | while read line
	do 
		if [ "$(echo "$line"|awk '{print$4}')" == "1" ];
		then 
			printf "$fstring$for_sale %6s $nocolor$fstringe" $line
		elif [ "$(echo "$line"|awk '{print$4}')" == "3" ];
		then
			printf "$fstring$in_progress %6s $nocolor$fstringe" $line
		elif [ "$(echo "$line"|awk '{print$4}')" == "5" ];
		then
			printf "$fstring$in_progress %6s $nocolor$fstringe" $line
		elif [ "$(echo "$line"|awk '{print$4}')" == "4" ];
		then
			printf "$fstring$sold %6s $nocolor$fstrings" $line
		else 
			printf "$fstring %6s $fstringe" $line
			printf $string
		fi
	done
	printf $string; 
else 
	echo -e "\n \n \n\033[1;35mthere are no inventory items for sale for this business date :-( \033[m \n \n \n" 
fi
