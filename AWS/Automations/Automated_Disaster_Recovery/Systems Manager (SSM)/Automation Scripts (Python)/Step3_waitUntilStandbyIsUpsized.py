'''
INPUT PAYLOAD:

region: '{{retrieveRegions.STANDBY_REGION}}'
wikiLink: '{{retrieveRegions.WIKI_LINK}}'
failoverLog: '{{upsizeStandby.FAILOVER_LOG}}'

'''


import boto3
import botocore
import time

def wait_instance_type(event,context):
  
  time.sleep(60)
  
  #variables
  failoverLog = event['failoverLog']
  failoverLog.append("STEP: waitUntilStandbyIsUpsized\n")
  wiki = event['wikiLink']
  standby_region = event['region']
  successCounter = 0
  if (standby_region == 'us-west-2'):
    nodeList = ["QA-MICROSERVICE-db-node-0"] #docDB nodes in us-west-2
  elif (standby_region == 'us-east-1'):
    nodeList = ["QA-MICROSERVICE-db-node-0","QA-MICROSERVICE-db-node-1","QA-MICROSERVICE-db-node-2"] #docDB nodes in us-east-1
  

  #waits until the docdb nodes are scaled up
  client = boto3.client('docdb',region_name=standby_region)
  waiter = client.get_waiter('db_instance_available')
  
  for x in range(len(nodeList)):
    waiter.wait(
      DBInstanceIdentifier=nodeList[x],
      WaiterConfig={
          'Delay': 20
      }
    )
    successCounter += 1
    failoverLog.append(f"WAIT COMPLETE FOR {nodeList[x]} IN {standby_region}.\n")
  
    
  #--- validate step success ---
  if (successCounter == len(nodeList)):
    log = f"STEP STATUS: SUCCESS!\n{successCounter} OF {len(nodeList)} NODES HAVE SUCCESSFULLY BEEN SCALED UP.\n"
  elif (successCounter != len(instanceList)):
    log = f"STEP STATUS: FAILED!\nERROR CODE: 3A\n{successCounter} OF {len(nodeList)} NODES HAVE BEEN SCALED UP.\n{wiki}"
  else:
    log = f"STEP STATUS: UNKNOWN!\nERROR CODE: 3B\nTHERE WAS AN ISSUE VALIDATING STEP SUCCESS. THIS DOES NOT MEAN THE DOCDB NODES ARE NOT SCALED UP. PLEASE CHECK THE DOCDB NODES IN {standby_region} TO CONFIRM THEY ARE SCALED UP.\n{wiki}"

  failoverLog.append("\n" + log)
  return {'FAILOVER_LOG': failoverLog}