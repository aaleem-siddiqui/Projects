'''
INPUT PAYLOAD:

active_region: '{{retrieveRegions.ACTIVE_REGION}}'
date_time: '{{retrieveRegions.DATE_TIME}}'
wikiLink: '{{retrieveRegions.WIKI_LINK}}'
failoverLog: '{{runMongoQueriesStandbyStack.FAILOVER_LOG}}'

'''


import boto3
import botocore
import time
import re

def restartSpecificServices(event,context):
  
  #variables
  failoverLog = event['failoverLog']
  failoverLog.append("STEP: restartSpecificServices\n")
  wiki = event['wikiLink']
  date_time = event['date_time']
  active_region=event['active_region']
  if (active_region == 'us-east-1'):
    associationID = "associationID" #restartSpecificServices association in East
    instanceList = ["InstanceId","InstanceId"] #MICROSERVICE_QA_INSTANCES_EAST
  elif (active_region == 'us-west-2'):
    associationID	= "associationID" #restartSpecificServices association in West
    instanceList = ["InstanceId","InstanceId"] #MICROSERVICE_QA_INSTANCES_WEST
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
      parseAssociationOutput = re.search(r"update-env to update environment variables(.*)', 'StandardOutputUrl':", str(associationOutputs[x]))
      if re.search(r"\bApplying action restartProcessId\b", str(associationOutputs[x])):
        successCounter += 1

    #--- validate step success ---
    if (successCounter == len(instanceList)):
      log = f"STEP STATUS: SUCCESS!\n{successCounter} OF {len(instanceList)} INSTANCES SUCCESSFULLY RAN THE restartSpecificServices ({associationID}) ASSOCIATION."
    elif (successCounter != len(instanceList)):
      log = f"STEP STATUS: FAILED!\nERROR CODE: 6A\nONLY {successCounter} OF {len(instanceList)} INSTANCES WERE ABLE TO RUN THE restartSpecificServices ({associationID}) ASSOCIATION.\n{wiki}"
  except AttributeError:
    failoverLog.append('THERE WAS AN ISSUE RETRIEVING OUTPUTS FROM THE ASSOCIATION. CHECKING ASSOCIATION STATUS...')
    #if unable to grab or parse commandID, grabs association details
    output = client.describe_association(
      AssociationId=associationID,
      AssociationVersion='$LATEST'
      )
  
    validateSuccess = output["AssociationDescription"]["Overview"]["Status"]
    
    if (validateSuccess == 'Success'):
      log = f"STEP STATUS: SUCCESS!\nTHE restartSpecificServices ({associationID}) ASSOCIATION WAS RUN SUCCESSFULLY!"
    elif (validateSuccess == 'Pending'):
      log = f"STEP STATUS: IN PROGRESS!THE ASSOCIATION IS STILL IN PROGRESS. MAKE SURE TO CHECK THE restartSpecificServices ({associationID}) ASSOCIATION IN MICROSERVICE-QA TO CONFIRM IT COMPLETES SUCCESSFULLY."
  except:
    log = f"STEP STATUS: UNKNOWN!\nERROR CODE: 6B\nASSOCIATION ID: {associationID}\nTHERE WAS AN ISSUE RETRIEVING OUTPUTS FROM THE ASSOCIATION. THIS DOES NOT MEAN THAT THE COMMANDS WERE NOT RUN.\n{wiki}"
  
  failoverLog.append("\n" + log)
  return {'FAILOVER_LOG': failoverLog}
  