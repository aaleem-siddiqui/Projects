#!/bin/bash
# FILENAME: getAndSetDNSRecordsTFfromAWS.sh
# CREATOR: AALEEM SIDDIQUI
# DESCRIPTION: This script will pull all of the records from a hosted zone in AWS, create terraform files, and import those resources into the terraform state.
# -------------------------------------
# USAGE: getAndSetDNSRecordsTFfromAWS.sh [-z zone_id] [-p aws_account_name] [-b s3_bucket_name] [-i import_resources (y/n)]
# -------------------------------------


#environment variables
BUCKET_REGION='us-east-1'
IMPORT_RESOURCES=''


###################################################   SCRIPT FLAGS   ###################################################


#gets flags from script execution
USAGE="Usage:\t $0 [-z zone_id] [-p aws_account_name] [-b s3_bucket_name] [-i import_resources (y/n)]"
dashZ="-z\tProvide a hosted zone ID from AWS."
dashP="-p\tProvide an AWS account name. This will be used with providers and folder structuring."
dashB="-b\tProvide the s3 bucket that holds terraform content in the specified AWS account."
dashI="-i\tUse -i to actually import resources from AWS. Otherwise it will perform a dry-run and only create files."
HELP="\n\n------ HELP MENU -------\n\n ${USAGE} \n\n ${dashZ} \n ${dashP} \n ${dashB} \n ${dashI}"
while getopts ":z:p:b:i:h:" option; do
  case $option in
    z)
      HOSTED_ZONE_ID="$OPTARG"
      ;;
    p)
      PROFILE="$OPTARG"
      ;;
    b)
      BUCKET_NAME="$OPTARG"
      ;;
    i)
	  if [[ $OPTARG == "y" ]] || [[ $OPTARG == "yes" ]] || [[ $OPTARG == "Y" ]] || [[ $OPTARG == "YES" ]];
	  then
      	IMPORT_RESOURCES='yes'
      else
      	IMPORT_RESOURCES='no'
      fi
      ;;
    h)
	  echo -e $HELP
	  exit 1
	  ;;
    *)
      echo -e $HELP
      exit 1
      ;;
  esac
done

#flag failsafes 
if [[ $HOSTED_ZONE_ID == "" ]];
then
	echo -e "\nMISSING ARGUMENT!\nPlease provide a hosted zone ID."
	echo -e $HELP
	exit 1
elif [[ $PROFILE == "" ]];
then
	echo -e "\nMISSING ARGUMENT!\nPlease provide an AWS account name."
	echo -e $HELP
	exit 1
elif [[ $BUCKET_NAME == "" ]];
then
	echo -e "\nMISSING ARGUMENT!\nPlease provide the s3 bucket name that holds terraform content for the specified AWS account."
	echo -e $HELP
	exit 1
fi

###################################################   RETRIEVES HOSTED ZONE INFO FOR NAMING   ###################################################


#retrieves information about the hosted zone for the naming convention
echo -e "RETRIEVING INFORMATION ABOUT THE ${HOSTED_ZONE_ID} TO BE USED FOR NAMING..."
aws route53 get-hosted-zone --id $HOSTED_ZONE_ID --profile=$PROFILE > zoneINFO.txt
dos2unix zoneINFO.txt

cat zoneINFO.txt | while read line
do
	zoneAttribute=$(echo $line | cut -d '"' -f 2)

	if [[ $zoneAttribute == "Name" ]];
	then
		zoneName=$(echo $line | cut -d '"' -f 4 | sed -r 's/\.$//')
	elif [[ $zoneAttribute == "PrivateZone" ]];
	then
		isPrivate=$(echo $line | cut -d ':' -f 2)
			if [[ $isPrivate == " false" ]];
			then
				zonePrivacy="Public"
			else
				zonePrivacy="Private"
			fi
	fi
	echo -e "${zoneName}_${zonePrivacy}_${HOSTED_ZONE_ID}" > zoneName.txt
done

zoneNamingConvention=$(cat zoneName.txt)
rm zoneName.txt
rm zoneINFO.txt

#creates tf path for files if they don't already exist
echo -e "CREATING TERRAFORM PATHS IF THEY DON'T ALREADY EXIST..."
mkdir -p ../../genericCompanyName/${PROFILE}
mkdir -p ../../genericCompanyName/${PROFILE}/${zoneNamingConvention}
cd ../../genericCompanyName/${PROFILE}/${zoneNamingConvention}/


###################################################    POPULATES PROVIDERS.TF    ###################################################


echo -e "CREATING PROVIDERS.TF..."
echo -e "/* -------- MAIN PROVIDER -------- */\n/* -------- DO NOT MODIFY -------- */\n\nprovider \"aws\" {" > providers.tf
echo -e "\tregion            = \"$BUCKET_REGION\"\n\tprofile           = \"$PROFILE\"\n}\n" >> providers.tf
echo -e "terraform {\n\tbackend \"s3\" {\n\t\tbucket        = \"$BUCKET_NAME\"" >> providers.tf
echo -e "\t\t# KEY FOLDER MUST BE UNIQUE\n\t\tkey           = \"Route_53/Hosted_Zones/${zoneNamingConvention}/terraform.tfstate\"" >> providers.tf
echo -e "\t\tregion        = \"$BUCKET_REGION\"\n\t\tprofile       = \"$PROFILE\"\n\t}\n}" >> providers.tf


###################################################    POPULATES RECORDS.TF    #####################################################


#retrieves current infrastructure from AWS
echo -e "RETRIEVING RECORDS IN ${PROFILE} FROM THE ${HOSTED_ZONE_ID} HOSTED ZONE..."
aws route53 list-resource-record-sets --hosted-zone-id=$HOSTED_ZONE_ID --profile=$PROFILE > CLIOutput.txt
dos2unix CLIOutput.txt
sed -i 's/\\"//g' CLIOutput.txt

#while loop to read each line in CLIOutput text file, retrieve the important information and add it to the records.tf file
echo -e "CREATING RECORDS.TF..."
echo -e "/* -------- DNS RECORDS -------- */\n\n/* HOW TO ADD/REMOVE/MODIFY A DNS RECORD: [DOCUMENTATION_LINK_HERE] */\n\n/* ----------------------------- */\n" > records.tf
RESOURCE_NAME_COUNTER=0
cat CLIOutput.txt | while read line
do
	#cuts name, type, ttl, or value from the line
	Attribute=$(echo $line | cut -d '"' -f 2)
	randNumb=1

	if [[ $Attribute == "Name" ]];
	then
		Name=$(echo $line | cut -d '"' -f 4)
		countPeriods=$(echo $Name | grep -o "\." | wc -l)
		if [[ $countPeriods > 3 ]]; 
		then
			tempResourceName=$(echo $Name | cut -d '.' -f 1)
			resourceName="$tempResourceName-$randNumb"
		else
			resourceName=$(echo $Name | cut -d '.' -f 1)
		fi
		if [[ $resourceName == $sameName ]]; 
		then
			echo "resource \"aws_route53_record\" \"$resourceName-$RESOURCE_NAME_COUNTER\" {" >> records.tf
			let RESOURCE_NAME_COUNTER++
		else
			echo "resource \"aws_route53_record\" \"$resourceName\" {" >> records.tf
			RESOURCE_NAME_COUNTER=1
		fi
		echo -e "\tzone_id = \"$HOSTED_ZONE_ID\"" >> records.tf
		echo -e "\tname    = \"$Name\"" >> records.tf
		RECORD_COUNTER=0
		sameName="$resourceName"
	elif [[ $Attribute == "Type" ]];
	then
		Type=$(echo $line | cut -d '"' -f 4)
		echo -e "\ttype    = \"$Type\"" >> records.tf
	elif [[ $Attribute == "TTL" ]];
	then
		TTL=$(echo $line | cut -d ' ' -f 2 | sed 's/,//')
		echo -e "\tttl     = $TTL" >> records.tf
	elif [[ $Attribute == "Value" ]];
	then
		Value=$(echo $line | cut -d '"' -f 4)
		#Value=${Value_Raw/'\"'}
		if [[ "$RECORD_COUNTER" -eq 0 ]];
		then
			echo -ne "\trecords = [\n\t\"$Value\"" >> records.tf
			#echo -e "counter: $RECORD_COUNTER"
		elif [[ "$RECORD_COUNTER" -gt 0 ]];
		then
			echo -ne ",\n\t\"$Value\"" >> records.tf
			#echo -e "counter: $RECORD_COUNTER"
		fi
		let RECORD_COUNTER++
	elif [[ $line == ']' ]];
	then
		echo -e "\n\t]\n}\n" >> records.tf
	fi
	let randNumb++	
done

#removes extra brackets at EOF
cat records.tf > records_tmp.tf 
head -n -5 records_tmp.tf > records.tf
rm records_tmp.tf


###################################################    ACTUALLY IMPORTS RESOURCES   #####################################################

#loops through each line of import_command.txt and runs each import command
if [[ $IMPORT_RESOURCES == "yes" ]];
then
	#CREATES FILE WITH IMPORT COMMANDS
	echo -e "CREATING FILE WITH IMPORT COMMANDS..."
	echo -ne "" > import_command.txt
	NEW_RESOURCE_COUNTER=0

	cat records.tf | while read line
	do
		newResource=$(echo $line | cut -d '"' -f 1)
		Attribute=$(echo $line | cut -d ' ' -f 1)
		if [[ $newResource == "resource " ]];
		then
			Unique_ID=$(echo $line | cut -d '"' -f 4)
			echo -ne "terraform.exe import aws_route53_record." >> import_command.txt
			echo -ne "$Unique_ID ${HOSTED_ZONE_ID}_" >> import_command.txt
			let NEW_RESOURCE_COUNTER++
			echo $NEW_RESOURCE_COUNTER > NEW_RESOURCE_COUNTER.txt
		elif [[ $Attribute == "name" ]];
		then
			Name=$(echo $line | cut -d '"' -f 2 | sed 's/\.$//g')
			echo -ne "${Name}_" >> import_command.txt
		elif [[ $Attribute == "type" ]];
		then
			Type=$(echo $line | cut -d '"' -f 2)
			echo -ne "${Type}\n" >> import_command.txt
		fi
	done

	NEW_RESOURCE_COUNTER=$(cat NEW_RESOURCE_COUNTER.txt)
	echo -e "THERE ARE ${NEW_RESOURCE_COUNTER} RECORDS IN THIS HOSTED ZONE..."

	#IMPORTS RESOURCES USING IMPORT_COMMAND FILE
	echo -e "\n\nYOU HAVE CHOSEN TO IMPORT RESOURCES...\n\n"
	IMPORT_COUNTER=1
	PERCENTAGE_CALCULATOR=100
	echo -e "INITIALIZING TERRAFORM...\n------------------------------\n"
	terraform.exe init
	echo -e "\nIMPORTING RESOURCES...\n------------------------------\n"
	while read line; do echo -e "\n\nIMPORTING RESOURCE ${IMPORT_COUNTER} OUT OF ${NEW_RESOURCE_COUNTER}...\nPERCENTAGE COMPLETE: $((PERCENTAGE_CALCULATOR/NEW_RESOURCE_COUNTER))%\n";$line;PERCENTAGE_CALCULATOR=$((PERCENTAGE_CALCULATOR + 100));let IMPORT_COUNTER++;echo -e "------------------------------"; done < import_command.txt;
	echo -e "\n------------------------------\n\nRUNNING TERRAFORM PLAN TO CONFIRM THAT THE INFRASTRUCTURE IN AWS MATCHES TERRAFORM...\n\n"
	terraform.exe plan
else
	echo -e "\n\nYOU HAVE CHOSEN NOT TO IMPORT THESE RESOURCES, ONLY CREATE THE TERRAFORM FILES.\n\n"
fi

echo -e "\n------------------------------\n\nCLEANING UP TEMPORARY FILES..."
rm -rf .terraform
rm -f .terraform*
rm -f NEW_RESOURCE_COUNTER.txt
rm -f CLIOutput.txt
rm -f import_command.txt
echo -e "\nSCRIPT COMPLETE.\n\n"
