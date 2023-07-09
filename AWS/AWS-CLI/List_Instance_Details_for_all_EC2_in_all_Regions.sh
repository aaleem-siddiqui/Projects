#!/bin/bash
###########################################
# FILENAME: List_Instance_Details_for_all_EC2_in_all_Regions.sh
# CREATOR: AALEEM SIDDIQUI
# DESCRIPTION: Checks details for all EC2 instances in all of the regions in an AWS acccount
###########################################

for region in `aws ec2 describe-regions --output text | cut -f4`
do
     echo -e "\nListing Instances in region:'$region'..."
     aws ec2 describe-instances --query "Reservations[*].Instances[*].{ID:InstanceId,AMI:ImageId,Type:InstanceType,State:State.Name,Tags:Tags[0].Value}" --output=table --region $region
done
