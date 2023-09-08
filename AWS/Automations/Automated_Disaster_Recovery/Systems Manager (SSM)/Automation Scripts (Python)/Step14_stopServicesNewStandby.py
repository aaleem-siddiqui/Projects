'''
INPUT PAYLOAD:

active_region: '{{retrieveRegions.ACTIVE_REGION}}'
date_time: '{{retrieveRegions.DATE_TIME}}'
wikiLink: '{{retrieveRegions.WIKI_LINK}}'

'''


import boto3
import botocore
import time
import re
from datetime import datetime

def stopServicesNewStandby(event,context):

  #variables
  wiki = event['wikiLink']
  dt_raw = datetime.now()
  date_time = dt_raw.strftime("%Y-%m-%dT%H:%M:00Z")
  active_region=event['active_region']
  if (active_region == 'us-east-1'):
    associationID = "associationID" #stopServicesNewStandby association in East
    startAgain = "associationID" #startServicesNewStandby association in East. (only used for testing. this portion should be hashed out.)
    instanceList = ["InstanceId","InstanceId","InstanceId","InstanceId","InstanceId","InstanceId","InstanceId"] #MICROSERVICE_QA_APPLICATION_INSTANCES_EAST
  elif (active_region == 'us-west-2'):
    associationID	= "associationID" #stopServicesNewStandby association in West
    startAgain = "associationID" #startServicesNewStandby association in West. (only used for testing. this portion should be hashed out.)
    instanceList = ["InstanceId","InstanceId","InstanceId","InstanceId","InstanceId","InstanceId","InstanceId"] #MICROSERVICE_QA_APPLICATION_INSTANCES_WEST
  successCounter = 0
  
  client = boto3.client(service_name='ssm',region_name=active_region)
  
  response = client.start_associations_once(
    AssociationIds=[associationID]
    )
  
  time.sleep(20)
  
  #getting the command ID
  getCommandId = client.list_command_invocations(
    InstanceId=instanceList[0],
    Filters=[
        {
          'key': 'InvokedAfter',
          'value': date_time
        }
      ],
    )
  
  #running another association to start the MICROSERVICE processes again -- QA ONLY
  response = client.start_associations_once(
    AssociationIds=[
      startAgain
      ]
    )
    
  #parsing the command ID
  try:
    command_ID = getCommandId["CommandInvocations"][0]["CommandId"]
    
    #getting association output from instances
    associationOutputs = []
    for i in range(len(instanceList)):
      associationOutput = client.get_command_invocation(
        CommandId=command_ID,
        InstanceId=instanceList[i],
      )
      associationOutputs.append(associationOutput)
  
    #parsing association output from instances
    for x in range(len(associationOutputs)):
      parseAssociationOutput = re.search(r"'StandardOutputContent': '(.*)', 'StandardOutputUrl':", str(associationOutputs[x]))
      if re.search(r"\bApplying action stopProcessId\b", str(associationOutputs[x])):
        successCounter += 1
    

    #--- validate step success ---
    failoverLog.append("\n-- -- -- -- -- -- -- -- -- -- --\n")
    if (successCounter == len(instanceList)):
      print(f"STEP STATUS: SUCCESS!\n{successCounter} OF {len(instanceList)} INSTANCES SUCCESSFULLY RAN THE stopServicesNewStandby ({associationID}) ASSOCIATION.")
    elif (successCounter != len(instanceList)):
      print(f"STEP STATUS: FAILED!\nERROR CODE: 14A\nONLY {successCounter} OF {len(instanceList)} INSTANCES WERE ABLE TO RUN THE stopServicesNewStandby ({associationID}) ASSOCIATION. PLEASE CHECK EACH APPLICATION INSTANCE MANUALLY.\n{wiki}")
  except AttributeError:
    print('THERE WAS AN ISSUE RETRIEVING OUTPUTS FROM THE ASSOCIATION. CHECKING ASSOCIATION STATUS...')
    #if unable to grab or parse commandID, grabs association details
    output = client.describe_association(
      AssociationId=associationID,
      AssociationVersion='$LATEST'
      )
  
    validateSuccess = output["AssociationDescription"]["Overview"]["Status"]
    
    if (validateSuccess == 'Success'):
      print(f"STEP STATUS: SUCCESS!\nTHE stopServicesNewStandby ({associationID}) ASSOCIATION WAS RUN SUCCESSFULLY!")
    elif (validateSuccess == 'Pending'):
      print(f"STEP STATUS: IN PROGRESS!\nTHE ASSOCIATION IS STILL IN PROGRESS. MAKE SURE TO CHECK THE stopServicesNewStandby ({associationID}) ASSOCIATION IN MICROSERVICE-QA TO CONFIRM IT COMPLETES SUCCESSFULLY.")
  except:
    print(f"STEP STATUS: UNKNOWN!\nERROR CODE: 14B\nASSOCIATION ID: {associationID}\nTHERE WAS AN ISSUE RETRIEVING OUTPUTS FROM THE ASSOCIATION. THIS DOES NOT MEAN THAT THE COMMANDS WERE NOT RUN.\n{wiki}")
