'''
INPUT PAYLOAD:

active_region: '{{retrieveRegions.ACTIVE_REGION}}'
standby_region: '{{retrieveRegions.STANDBY_REGION}}'
credsEast: '{{retrieveRegions.CREDS_EAST}}'
credsWest: '{{retrieveRegions.CREDS_WEST}}'
LM_API_ID: '{{retrieveRegions.LM_API_ID}}'
LM_API_KEY: '{{retrieveRegions.LM_API_KEY}}'
wikiLink: '{{retrieveRegions.WIKI_LINK}}'
failoverLog: '{{changePort.FAILOVER_LOG}}'

'''


import boto3
import json
import botocore

def swapSecrets(event,context):

  #variables
  failoverLog = event['failoverLog']
  failoverLog.append("STEP: swapSecrets\n")
  wiki = event['wikiLink']
  active_region = event['active_region']
  standby_region = event['standby_region']
  credsEast = event['credsEast'] 
  credsWest = event['credsWest']
  LM_API_ID	= event['LM_API_ID']
  LM_API_KEY = event['LM_API_KEY']
  secret_arn = "arn:aws:secretsmanager:us-east-1:AWSACCOUNT#:secret:MICROSERVICE-QA-STACKS"
  
  session = boto3.session.Session()
  client = session.client(service_name='secretsmanager',region_name="us-east-1")
  
  #retrieves secret values before they are swapped
  try:
    get_secret_value_response_before = client.get_secret_value(SecretId=secret_arn)
  
    #sets secret values as vars before they are swapped  
    MICROSERVICE_secrets_before = json.loads(get_secret_value_response_before['SecretString'])
    active_region_before = MICROSERVICE_secrets_before['PRIMARY_MICROSERVICE_QA_STACK']
    standby_region_before = MICROSERVICE_secrets_before['STANDBY_MICROSERVICE_QA_STACK']
    
    #swaps east/west secret values for active and standby stacks in secrets manager
    if (active_region == 'us-east-1'):
      failoverLog.append('SETTING THE ACTIVE REGION TO WEST IN SECRETS MANAGER...\n')
      response = client.update_secret(
        SecretId=secret_arn, 
        KmsKeyId='arn:aws:kms:us-east-1:AWSACCOUNT#:key/123-456-789',
        SecretString=json.dumps({"PRIMARY_MICROSERVICE_QA_STACK":"WEST","STANDBY_MICROSERVICE_QA_STACK":"EAST","QA_MASTER_CONNECTION_EAST":credsEast,"QA_MASTER_CONNECTION_WEST":credsWest,"LM_API_ID":LM_API_ID,"LM_API_KEY":LM_API_KEY})
        )
    elif (active_region == 'us-west-2'):
      failoverLog.append('SETTING THE ACTIVE REGION TO EAST IN SECRETS MANAGER...\n')
      response = client.update_secret(
        SecretId=secret_arn,
        KmsKeyId='arn:aws:kms:us-east-1:AWSACCOUNT#:key/123-456-789',
        SecretString=json.dumps({"PRIMARY_MICROSERVICE_QA_STACK":"EAST","STANDBY_MICROSERVICE_QA_STACK":"WEST","QA_MASTER_CONNECTION_EAST":credsEast,"QA_MASTER_CONNECTION_WEST":credsWest,"LM_API_ID":LM_API_ID,"LM_API_KEY":LM_API_KEY})
        )
    
    #retrieves secret values after they are swapped
    try:
      get_secret_value_response = client.get_secret_value(
        SecretId=secret_arn
      )
    except ClientError as e:
      raise e
  
    #sets secret values as vars after they are swapped
    MICROSERVICE_secrets = json.loads(get_secret_value_response['SecretString'])
    active_region_after = MICROSERVICE_secrets['PRIMARY_MICROSERVICE_QA_STACK']
    standby_region_after = MICROSERVICE_secrets['STANDBY_MICROSERVICE_QA_STACK']
    
    #--- validate step success ---
    if ((active_region_before == standby_region_after) and (standby_region_before == active_region_after)):
      log = f"STEP STATUS: SUCCESS!\n\nThe regions in secrets manager BEFORE the failover:\nACTIVE = {active_region_before} | STANDBY = {standby_region_before}\n\nThe regions in secrets manager AFTER the failover:\nACTIVE = {active_region_after} | STANDBY = {standby_region_after}"
    elif ((active_region_before == active_region_after) and (standby_region_before == standby_region_after)):
      log = f"STEP STATUS: FAILED!\nERROR CODE: 11A\nTHE REGIONS ARE STILL THE SAME AS BEFORE!\n{wiki}"
    else:
      log = f"STEP STATUS: FAILED!\nERROR CODE: 11B\nTHE SECRET VALUES ARE NOT WHAT THEY ARE SUPPOSED TO BE.\n{wiki}"
  except:
    log = f"STEP STATUS: FAILED!\nERROR CODE: 11C\nFAILED TO SWAP REGIONS IN SECRETS MANAGER! THERE COULD BE AN ISSUE WITH THE US-EAST-1 REGION. PLEASE MANUALLY SWAP THE REGIONS IN aws_account_name SECRETS MANAGER.\n{wiki}"

  failoverLog.append("\n" + log)
  return {'FAILOVER_LOG': failoverLog}