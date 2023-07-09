#!/bin/bash
###########################################
# FILENAME: List_Platform_Details_for_all_EC2_in_all_Regions.sh
# CREATOR: AALEEM SIDDIQUI
# DESCRIPTION: Checks platform details for all EC2 instances in all of the regions in an AWS acccount
###########################################

for region in `aws ec2 describe-regions --output text | cut -f4`
do
     echo -e "\nListing Instances in region:'$region'..."
     aws ssm describe-instance-information --query 'InstanceInformationList[*].{ID:InstanceId,Platform_Type:PlatformType,Platform_Name:PlatformName,Platform_Version:PlatformVersion,Instance_Name:ComputerName}' --output=table --region $region   
done
