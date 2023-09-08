'''
INPUT PAYLOAD:

region: '{{retrieveRegions.STANDBY_REGION}}'
wikiLink: '{{retrieveRegions.WIKI_LINK}}'
failoverLog: '{{retrieveRegions.FAILOVER_LOG}}'

'''


import boto3
import botocore
import re

def modify_instance_type(event,context):
  
  #variables
  failoverLog = event['failoverLog']
  failoverLog.append("STEP: upsizeStandby\n\n")
  wiki = event['wikiLink']
  standby_region = event['region']
  instanceType = 'db.r6g.large' #instance type to upsize to
  successCounter = 0
  responseOutputs = []
  if (standby_region == 'us-west-2'):
    nodeList = ["QA-MICROSERVICE-db-node-0"] #docDB nodes in us-west-2
  elif (standby_region == 'us-east-1'):
    nodeList = ["QA-MICROSERVICE-db-node-0","QA-MICROSERVICE-db-node-1","QA-MICROSERVICE-db-node-2"] #docDB nodes in us-east-1
  

  #upsizes standby region nodes
  client = boto3.client('docdb',region_name=standby_region)
  
  for x in range(len(nodeList)):
    response = client.modify_db_instance(
      DBInstanceIdentifier=nodeList[x],
      DBInstanceClass=instanceType,
      ApplyImmediately=True,
      )
    responseOutputs.append(response)
    
  #parsing response output from instances
  for i in range(len(responseOutputs)):
    try:
      parseResponseOutput = responseOutputs[i]["DBInstance"]["PendingModifiedValues"]["DBInstanceClass"]
      if (parseResponseOutput == instanceType):
        successCounter += 1
    except AttributeError:
      if re.search(r"\b'PendingModifiedValues': {'DBInstanceClass': 'db.r6g.large'}\b", str(responseOutputs[i])):
        successCounter += 1
    except:
      failoverLog.append(f"THERE WAS AN ISSUE VALIDATING SUCCESS FOR {nodeList[i]}.\n")
  
  #--- validate step success ---
  if (successCounter == len(nodeList)):
    log = f"STEP STATUS: SUCCESS!\n{successCounter} OF {len(nodeList)} NODES HAVE SUCCESSFULLY BEEN SENT THE REQUEST TO UPSIZE."
  elif (successCounter != len(nodeList)):
    log = f"STEP STATUS: FAILED!\nERROR CODE: 2A\n{successCounter} OF {len(nodeList)} NODES WERE SENT THE REQUEST TO UPSIZE.\nNOTE: THE INSTANCES COULD ALREADY BE SCALED UP. PLEASE CHECK THE DOCDB NODES IN {standby_region} TO CONFIRM THEY ARE SCALED UP.\n{wiki}"
  else:
    log = f"STEP STATUS: UNKNOWN!\nERROR CODE: 2B\nTHERE WAS AN ISSUE RETRIEVING OUTPUTS FROM THE MODIFY DOCDB REQUESTS. THIS DOES NOT MEAN THE REQUESTS WERE NOT SENT, PLEASE CHECK THE DOCDB NODES IN {standby_region} TO CONFIRM THEY ARE IN A MODIFYING STATE.\n{wiki}"

  failoverLog.append("\n" + log)
  return {'FAILOVER_LOG': failoverLog}
