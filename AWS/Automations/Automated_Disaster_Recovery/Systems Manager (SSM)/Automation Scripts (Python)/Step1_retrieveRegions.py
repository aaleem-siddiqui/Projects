'''
INPUT PAYLOAD:

REGION_EAST: us-east-1
REGION_WEST: us-west-2
SlackChannel: '{{SlackChannel}}'

'''


import boto3
import json
from datetime import datetime
from botocore.exceptions import ClientError

def get_active_stack(event,context):
  
  #variables
  region_east = event['REGION_EAST']
  region_west = event['REGION_WEST']
  dt_raw = datetime.now()
  current_datetime = dt_raw.strftime("%Y-%m-%dT%H:%M:00Z")
  print_datetime = dt_raw.strftime("%m/%d/%Y %H:%M:%S")
  wikiLink = 'REFER TO THE ERROR CODE DOCUMENTATION FOR MORE INFO: [DOCUMENTATION LINK HERE]'
  failoverLog = [f"\t\t-- POST MICROSERVICE FAILOVER LOG --\n\nTHE CURRENT DATE AND TIME IS: {print_datetime}.\n"]
  failoverLog.append("STEP: retrieveRegions\n\n")
  
  #posts slack notification
  slack = event['SlackChannel']
  snsclient = boto3.client('sns')
  snsArn = 'arn:aws:sns:us-east-1:AWSACCOUNT#:MICROSERVICE_FAILOVER_NOTIF'
  message = f"FAILOVER START TIME: {print_datetime}\nCHANNEL: {slack}"
  
  try:
    if ((slack == 'MICROSERVICE-release') or (slack == 'MICROSERVICE-devops') or (slack == 'emergency-room')):
      response = snsclient.publish(
        TopicArn = snsArn,
        Message = message,
        MessageAttributes={
          'Channel': {
            'DataType': 'String',
            'StringValue': f"{slack}"
          }
        },
        Subject = "MICROSERVICE QA FAILOVER HAS BEEN TRIGGERED."
      )
    elif (slack == 'alarm'):
      response = snsclient.publish(
        TopicArn = snsArn,
        Message = message,
        MessageAttributes={
          'Channel': {
            'DataType': 'String',
            'StringValue': f"{slack}"
          }
        },
        Subject = "MICROSERVICE QA FAILOVER TRIGGERED VIA ALARM. PLEASE NOTIFY @oncall AND ALL RELEVANT RESOURCES."
      )
  except:
    print("UNABLE TO POST TO SLACK.")
  
  failoverLog.append("YOU HAVE CHOSEN TO RUN THE FAILOVER IN MICROSERVICE-QA...")

  #get the secret from us-east-1
  session = boto3.session.Session()
  try:
    secret_name = "arn:aws:secretsmanager:us-east-1:AWSACCOUNT#:secret:MICROSERVICE-QA-STACKS"
    client = session.client(service_name='secretsmanager',region_name="us-east-1")
    get_secret_value_response = client.get_secret_value(SecretId=secret_name)
    
  #if failed to get secrets from us-east-1, try replica in us-west-2
  except:
    failoverLog.append("\nFAILED TO RETRIEVE SECRETS FROM US-EAST-1 !! RETRIEVING SECRETS FROM US-WEST-2...")
    secret_name = "arn:aws:secretsmanager:us-west-2:AWSACCOUNT#:secret:MICROSERVICE-QA-STACKS"
    client = session.client(service_name='secretsmanager',region_name="us-west-2")
    get_secret_value_response = client.get_secret_value(SecretId=secret_name)
    
  #parsing secrets and saving them as vars
  MICROSERVICE_secrets = json.loads(get_secret_value_response['SecretString'])
  active_stack = MICROSERVICE_secrets['PRIMARY_MICROSERVICE_QA_STACK'] #active region in secrets manager
  credsEast = MICROSERVICE_secrets['QA_MASTER_CONNECTION_EAST'] #docdb master credentials for the east region
  credsWest = MICROSERVICE_secrets['QA_MASTER_CONNECTION_WEST'] #docdb master credentials for the west region
  LM_API_ID = MICROSERVICE_secrets['LM_API_ID'] #logicmonitor API key
  LM_API_KEY = MICROSERVICE_secrets['LM_API_KEY'] #logicmonitor secret key
  
  if (active_stack == 'EAST'):
      active_region=region_east
      standby_region=region_west
  elif (active_stack == 'WEST'):
      active_region=region_west
      standby_region=region_east
  
  failoverLog.append(f"\n-- -- -- -- -- -- -- -- -- -- --\nTHE CURRENT ACTIVE REGION IN MICROSERVICE-QA IS: {active_region}.\nTHE CURRENT STANDBY REGION IN MICROSERVICE-QA IS: {standby_region}.")
  
  return {'ACTIVE_REGION': active_region, 'STANDBY_REGION': standby_region, 'CREDS_EAST': credsEast,'CREDS_WEST': credsWest, 'LM_API_ID': LM_API_ID , 'LM_API_KEY': LM_API_KEY,'DATE_TIME': current_datetime, 'WIKI_LINK': wikiLink, 'FAILOVER_LOG': failoverLog}
