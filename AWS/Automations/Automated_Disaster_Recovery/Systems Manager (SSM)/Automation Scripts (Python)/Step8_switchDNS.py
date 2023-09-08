'''
INPUT PAYLOAD:

region: '{{retrieveRegions.ACTIVE_REGION}}'
standby_region: '{{retrieveRegions.STANDBY_REGION}}'
SlackChannel: '{{SlackChannel}}'
wikiLink: '{{retrieveRegions.WIKI_LINK}}'
failoverLog: '{{restartAllServices.FAILOVER_LOG}}'

'''


import boto3
import botocore
from datetime import datetime

def switch_DNS(event,context):
  
  #variables
  failoverLog = event['failoverLog']
  failoverLog.append("STEP: switchDNS\n")
  wiki = event['wikiLink']
  active_region=event['region']
  standby_region = event['standby_region']
  dt_raw = datetime.now()
  print_datetime = dt_raw.strftime("%m/%d/%Y %H:%M:%S")
  zoneId='genericHostedZoneID' #zone ID for MICROSERVICE-QA
  targetRecord=["MICROSERVICE1.companyNameqa.net","MICROSERVICE2.companyNameqa.net","MICROSERVICE3.companyNameqa.net","MICROSERVICE4.companyNameqa.net"] #target dns record to my modified
  
  #setting var for new endpoint depending on active region
  if (active_region == 'us-east-1'):
    rgn='west' #west dns record
    Listener_ARN = 'arn:aws:elasticloadbalancing:us-west-2:AWSACCOUNT#:listener/app/qa/' #west LB listener ARN
  elif (active_region == 'us-west-2'):
    rgn='east' #east dns record
    Listener_ARN = 'arn:aws:elasticloadbalancing:us-east-1:AWSACCOUNT#:listener/app/qa/' #east LB listener ARN
  endpoint=[f"MICROSERVICE1-{rgn}.companyNameqa.net",f"MICROSERVICE2-{rgn}.companyNameqa.net",f"MICROSERVICE3-{rgn}.companyNameqa.net",f"MICROSERVICE4-{rgn}.companyNameqa.net"]
  successCounter = 0
  
  client = boto3.client('elbv2', region_name = standby_region)
  
  #updates port on listener to 443 for new active region anyways
  failoverLog.append(f"UPDATING PORT ON THE {standby_region} (NEW ACTIVE REGION) TO 443 BEFORE SWITCHING DNS JUST IN CASE...")
  response = client.modify_listener(
    Port=443,
    ListenerArn=Listener_ARN,
  )

  #checking change to port
  response_check = client.describe_listeners(
    ListenerArns=[
      Listener_ARN,
      ],
    )
    
  port_after_change = response_check["Listeners"][0]["Port"]
  
  boto_sts=boto3.client('sts')
  
  #assuming role in aws_account_name
  stsresponse = boto_sts.assume_role(
    RoleArn="arn:aws:iam::AWSACCOUNT#:role/MICROSERVICE_FAILOVER_ROLE",
    RoleSessionName='switchDNS'
  )
  
  newsession_id = stsresponse["Credentials"]["AccessKeyId"]
  newsession_key = stsresponse["Credentials"]["SecretAccessKey"]
  newsession_token = stsresponse["Credentials"]["SessionToken"]

  client = boto3.client(
    'route53',
    aws_access_key_id=newsession_id,
    aws_secret_access_key=newsession_key,
    aws_session_token=newsession_token
  )
  
  #updates the route53 endpoint to the standby regions endpoint
  failoverLog.append("UPDATING DNS RECORDS IN ROUTE53...\n\n")
  for i in range(len(targetRecord)):
    response = client.change_resource_record_sets(
      ChangeBatch={
        'Changes': [
          {
            'Action': 'UPSERT',
            'ResourceRecordSet': {
            'Name': targetRecord[i],
            'ResourceRecords': [
              {
                'Value': endpoint[i],
              },
            ],
            'TTL': 60,
            'Type': 'CNAME',
            },
          },
        ],
        'Comment': 'MICROSERVICEFAILOVER',
      },
      HostedZoneId=zoneId,
    )
  
  #posts slack notification
  slack = event['SlackChannel']
  snsclient = boto3.client('sns')
  snsArn = 'arn:aws:sns:us-east-1:AWSACCOUNT#:MICROSERVICE_FAILOVER_NOTIF'
  message = f"FAILOVER END TIME: {print_datetime}\nCHANNEL: {slack}"
  
  try:
    response = snsclient.publish(
      TopicArn = snsArn,
      Message = message,
      MessageAttributes={
        'Channel': {
          'DataType': 'String',
          'StringValue': f"{slack}"
        }
      },
      Subject = f"MICROSERVICE QA FAILOVER COMPLETE. THE DNS HAS BEEN SWITCHED. WE ARE NOW IN {standby_region}"
    )
  except:
    print("UNABLE TO POST TO SLACK.")
  
  #checks route53 record after upsert
  outputArray = []
  try:
    for x in range(len(targetRecord)):
      check_response = client.list_resource_record_sets(
        HostedZoneId=zoneId,
        StartRecordName=targetRecord[x],
        StartRecordType='CNAME',
        MaxItems='1'
      )
    
      #parsing response check
      recordName = check_response["ResourceRecordSets"][0]["Name"]
      recordEndpoint = check_response["ResourceRecordSets"][0]["ResourceRecords"][0]["Value"]
      
      
      if (recordEndpoint == endpoint[x]):
        successCounter += 1
        failoverLog.append("THE RECORD " + recordName + " IS NOW POINTED TO THE " + recordEndpoint + " ENDPOINT.\n")
    
    #--- validate step success ---
    if ((successCounter == len(targetRecord)) and (port_after_change == 443)):
      log = f"STEP STATUS: SUCCESS!\n{successCounter} OF {len(targetRecord)} RECORDS ARE POINTED TO THE CORRECT ENDPOINT AND THE LOAD BALANCER PORT IS 443."
    elif (successCounter != len(targetRecord)):
      log = f"STEP STATUS: FAILED!\nERROR CODE: 8A\nONLY {successCounter} OF {len(targetRecord)} RECORDS ARE POINTED TO THE CORRECT ENDPOINT. PLEASE CHECK ALL ENDPOINTS IN ROUTE53.\n{wiki}"
    elif (port_after_change != 443):
      log = f"STEP STATUS: FAILED!\nERROR CODE: 12A\nTHE PORT ON THE NEW ACTIVE REGION LOAD BALANCER LISTENER IS NOT 443!\nYOU MAY HAVE TO MANUALLY RESTORE THIS CONNECTION.\n{wiki}"
  except:
    log = f"STEP STATUS: UNKNOWN!\nERROR CODE: 8B\nTHERE WAS AN ISSUE PARSING OUTPUTS AND VALIDATING SUCCESS. THIS DOES NOT MEAN THAT THE DNS RECORDS WERE NOT UPDATED. PLEASE MANUALLY CHECK THE ENDPOINTS IN ROUTE53 TO CONFIRM THAT IT HAS BEEN UPDATED.\n{wiki}"
  
  failoverLog.append("\n" + log)
  return {'FAILOVER_LOG': failoverLog}
  