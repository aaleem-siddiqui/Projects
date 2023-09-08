'''
INPUT PAYLOAD:

standby_region: '{{retrieveRegions.STANDBY_REGION}}'
date_time: '{{retrieveRegions.DATE_TIME}}'
wikiLink: '{{retrieveRegions.WIKI_LINK}}'
failoverLog: '{{restartSpecificServices.FAILOVER_LOG}}'

'''


import boto3
import botocore
import time
import re

def restartAllServices(event,context):

  #variables
  failoverLog = event['failoverLog']
  failoverLog.append("STEP: restartAllServices\n")
  wiki = event['wikiLink']
  date_time = event['date_time']
  standby_region=event['standby_region']
  if (standby_region == 'us-east-1'):
    associationID = "associationID" #restartAllServices association in East
    instanceList = ["InstanceId","InstanceId","InstanceId","InstanceId","InstanceId","InstanceId","InstanceId"] #MICROSERVICE_QA_APPLICATION_INSTANCES_EAST
    clusterN = 'MICROSERVICE-qa'
  elif (standby_region == 'us-west-2'):
    associationID	= "associationID" #restartAllServices association in West
    instanceList = ["InstanceId","InstanceId","InstanceId","InstanceId","InstanceId","InstanceId","InstanceId"] #MICROSERVICE_QA_APPLICATION_INSTANCES_WEST
    clusterN = 'MICROSERVICE-qa-west'
  successCounter = 0
  serviceN = 'QA-MICROSERVICE-processor'

  
  client = boto3.client(service_name='ssm',region_name=standby_region)
  ecsclient = boto3.client(service_name='ecs',region_name=standby_region)
  
  #trigger associations
  response = client.start_associations_once(
    AssociationIds=[associationID]
    )
  
  #trigger task refresh
  listTasks = ecsclient.list_tasks(
    cluster=clusterN,
    serviceName=serviceN,
    )
  
  currentTasks = listTasks["taskArns"]
  cycleTasks = ecsclient.update_service(
    cluster=clusterN,
    service=serviceN,
    forceNewDeployment=True
    )

  #waits until the service reaches a steady state
  waiter = ecsclient.get_waiter('services_stable')
  try:
    waiter.wait(
      cluster=clusterN,
      services=[serviceN]
    )
  except:
    OPstatus = 'bad'
  else:
    OPstatus = 'good'
  
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
    if ((successCounter == len(instanceList)) and (OPstatus == 'good')):
      log = f"STEP STATUS: SUCCESS!\n{successCounter} OF {len(instanceList)} INSTANCES SUCCESSFULLY RAN THE restartAllServices ({associationID}) ASSOCIATION AND PROCESSOR ECS TASKS HAVE BEEN CYCLED."
    elif ((successCounter != len(instanceList)) and (OPstatus == 'good')):
      log = f"STEP STATUS: FAILED!\nERROR CODE: 7A\nONLY {successCounter} OF {len(instanceList)} INSTANCES WERE ABLE TO RUN THE restartAllServices ({associationID}) ASSOCIATION. PLEASE CHECK EACH APPLICATION INSTANCE MANUALLY.\n{wiki}"
    elif ((successCounter == len(instanceList)) and (OPstatus == 'bad')):
      log = f"STEP STATUS: FAILED!\nERROR CODE: 7C\nPROCESSOR FAILED TO CYCLE TASKS.\n{wiki}"
  except AttributeError:
    failoverLog.append('THERE WAS AN ISSUE RETRIEVING OUTPUTS FROM THE ASSOCIATION. CHECKING ASSOCIATION STATUS...')
    #if unable to grab or parse commandID, grabs association details
    output = client.describe_association(
      AssociationId=associationID,
      AssociationVersion='$LATEST'
      )
  
    validateSuccess = output["AssociationDescription"]["Overview"]["Status"]
      
    if (validateSuccess == 'Success'):
      log = f"STEP STATUS: SUCCESS!\nTHE restartAllServices ({associationID}) ASSOCIATION WAS RUN SUCCESSFULLY!"
    elif (validateSuccess == 'Pending'):
      log = f"STEP STATUS: IN PROGRESS!\nTHE ASSOCIATION IS STILL IN PROGRESS. MAKE SURE TO CHECK THE restartAllServices ({associationID}) ASSOCIATION IN MICROSERVICE-QA TO CONFIRM IT COMPLETES SUCCESSFULLY."
  except:
    log = f"STEP STATUS: UNKNOWN!\nERROR CODE: 7B\nASSOCIATION ID: {associationID}\nTHERE WAS AN ISSUE RETRIEVING OUTPUTS FROM THE ASSOCIATION. THIS DOES NOT MEAN THAT THE COMMANDS WERE NOT RUN.\n{wiki}"
    
  failoverLog.append("\n" + log)
  return {'FAILOVER_LOG': failoverLog}
  