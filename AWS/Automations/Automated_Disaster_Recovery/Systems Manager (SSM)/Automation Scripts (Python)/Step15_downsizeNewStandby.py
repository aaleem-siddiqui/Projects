'''
INPUT PAYLOAD:

region: '{{retrieveRegions.ACTIVE_REGION}}'
wikiLink: '{{retrieveRegions.WIKI_LINK}}'

'''


import boto3
import botocore
import re

def modify_instance_type(event,context):
  
  wiki = event['wikiLink']
  active_region = event['region']
  instanceType = 'db.t4g.medium' #instance type to upsize to
  successCounter = 0
  responseOutputs = []
  if (active_region == 'us-west-2'):
    nodeList = ["QA-MICROSERVICE-db-node-0"] #docDB nodes in us-west-2
  elif (active_region == 'us-east-1'):
    nodeList = ["QA-MICROSERVICE-db-node-0","QA-MICROSERVICE-db-node-1","QA-MICROSERVICE-db-node-2"] #docDB nodes in us-east-1
  
  client = boto3.client('docdb',region_name=active_region)
  

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
      if re.search(r"\b'PendingModifiedValues': {'DBInstanceClass': 'db.t4g.medium'}\b", str(responseOutputs[i])):
        successCounter += 1
    except:
      print(f"THERE WAS AN ISSUE VALIDATING SUCCESS FOR {nodeList[i]}.")
  
  if (successCounter == len(nodeList)):
    print(f"STEP STATUS: SUCCESS!\n{successCounter} OF {len(nodeList)} NODES HAVE SUCCESSFULLY BEEN SENT THE REQUEST TO DOWNSIZE.")
  elif (successCounter != len(nodeList)):
    print(f"STEP STATUS: FAILED!\nERROR CODE: 15A\nONLY {successCounter} OF {len(nodeList)} NODES WERE SENT THE REQUEST TO DOWNSIZE.\nNOTE: THE INSTANCES COULD ALREADY BE SCALED DOWN. PLEASE CHECK THE DOCDB NODES IN {active_region} TO CONFIRM THEY ARE SCALED DOWN.\n{wiki}")
  else:
    print(f"STEP STATUS: UNKNOWN!\nERROR CODE: 15B\nTHERE WAS AN ISSUE RETRIEVING OUTPUTS FROM THE MODIFY DOCDB REQUESTS. THIS DOES NOT MEAN THE REQUESTS WERE NOT SENT, PLEASE CHECK THE DOCDB NODES IN {active_region} TO CONFIRM THEY ARE IN A MODIFYING STATE.\n{wiki}")
  