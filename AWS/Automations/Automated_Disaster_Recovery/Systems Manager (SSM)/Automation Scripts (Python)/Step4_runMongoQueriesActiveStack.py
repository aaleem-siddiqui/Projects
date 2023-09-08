'''
INPUT PAYLOAD:

active_region: '{{retrieveRegions.ACTIVE_REGION}}'
credsEast: '{{retrieveRegions.CREDS_EAST}}'
credsWest: '{{retrieveRegions.CREDS_WEST}}'
wikiLink: '{{retrieveRegions.WIKI_LINK}}'
failoverLog: '{{waitUntilStandbyIsUpsized.FAILOVER_LOG}}'

'''


import boto3
import json
import botocore
import re

def runMongoQueriesActiveStack(event,context):

  #variables
  failoverLog = event['failoverLog']
  failoverLog.append("STEP: runMongoQueriesActiveStack\n")
  wiki = event['wikiLink']
  active_region=event['active_region']
  if (active_region == 'us-east-1'):
    creds = event['credsEast'] #docdb master credentials for the east region
  elif (active_region == 'us-west-2'):
    creds = event['credsWest'] #docdb master credentials for the west region
  lambdaPayload={"region":active_region,"creds":creds,"readOnly":"false"} #creates payload to be sent to lambda
  
  failoverLog.append(f"THE CURRENT ACTIVE REGION IS {active_region}.\nDISABLING MICROSERVICE API CALLS IN THE DATABASE FOR THIS REGION...\n\n")

  #trigger lambda to run queries in DB
  client = boto3.client(service_name='lambda',region_name=active_region)
  response = client.invoke(
    FunctionName=f"arn:aws:lambda:{active_region}:AWSACCOUNT#:function:runMongoQueries",
    InvocationType='RequestResponse',
    LogType='Tail',
    Payload=json.dumps(lambdaPayload)
    )
  
  #prints lambda output
  lineBreak = "-- -- -- -- -- -- -- -- -- -- --\n"
  lambdaOutput = response['Payload']
  LO = lambdaOutput.read()
  LO_remove_backslash = str(LO).replace("\\","")
  LO_parsed = str(LO_remove_backslash).split(",")
  failoverLog.append(lineBreak + "THE NEW VALUES FROM THE DATABASE ARE AS FOLLOWS:\n\n")
  for x in LO_parsed:
    failoverLog.append(x + "\n")
  
  #microservice disabled parsing
  microService1Check = re.search(r"{\\'microServiceDisabled\\': (.*)}}]\"', ' \"Reports\"", str(LO_parsed))

  #reports parsing
  microService2Check = re.search(r"'sendToS3\\': (.*)}', \" 'report1':", str(LO_parsed))
  microService3Check = re.search(r"{'sendToS3': (.*)}\", \" 'report2':", str(LO_parsed))
  microService4Check = re.search(r"'report2': {'sendToS3': (.*)}\", ' \\'report3\\'", str(LO_parsed))
  microService5Check = re.search(r"'report3\\': {\\'sendToS3\\': (.*)}}}}]\"'", str(LO_parsed))

  #partners config parsing
  partner1Check = re.search(r"{\\'partner1\\': {\\'apiInfo\\': {\\'fakeApi\\': (.*)}}', \"", str(LO_parsed))
  partner3Check = re.search(r"\" 'partner3': {'apiInfo': {'fakeApi': (.*)}}\", ' \\'partner2\\':", str(LO_parsed))
  partner2Check = re.search(r"'partner2\\': {\\'apiInfo\\': {\\'fakeApi\\': (.*)}}}}}]", str(LO_parsed))
  
  #--- validate step success ---
  try:
    if ((microService1Check.group(1) == 'True') and (microService2Check.group(1) == 'False') and (microService3Check.group(1) == 'False') and (microService4Check.group(1) == 'False') and (microService5Check.group(1) == 'False') and (partner1Check.group(1) == 'True') and (partner3Check.group(1) == 'True') and (partner2Check.group(1) == 'True')):
      log = "STEP STATUS: SUCCESS!"
    elif ((microService1Check.group(1) == 'False') and (microService2Check.group(1) == 'True') and (microService3Check.group(1) == 'True') and (microService4Check.group(1) == 'True') and (microService5Check.group(1) == 'True') and (partner1Check.group(1) == 'False') and (partner3Check.group(1) == 'False') and (partner2Check.group(1) == 'False')):
      log = f"STEP STATUS: FAILED!\nERROR CODE: 4A\nIT LOOKS LIKE THE VALUES FAILED TO UPDATE IN THE DATABASE.\n{wiki}"
    else:
      log = f"STEP STATUS: FAILED!\nERROR CODE: 4B\nIT LOOKS LIKE SOME OF THE VALUES UPDATED AND SOME DIDN'T.\n{wiki}"
  except:
    log = f"STEP STATUS: UNKNOWN!\nERROR CODE: 4C\nTHERE WAS EITHER AN ISSUE TRIGGERING THE LAMBDA OR VALIDATING STEP SUCCESS. PLEASE REVIEW THE ABOVE OUTPUT FROM THE DATABASE IF IT EXISTS AND CONFIRM THE TRUE/FALSE VALUES FOLLOW THIS PATTERN:\nTRUE, FALSE, FALSE, FALSE, FALSE, TRUE, TRUE, TRUE\n{wiki}"
  
  failoverLog.append("\n" + log)
  return {'FAILOVER_LOG': failoverLog}
      