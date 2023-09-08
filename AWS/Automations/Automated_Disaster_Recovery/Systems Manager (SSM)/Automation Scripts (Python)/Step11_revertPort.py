'''
INPUT PAYLOAD:

region: '{{retrieveRegions.ACTIVE_REGION}}'
wikiLink: '{{retrieveRegions.WIKI_LINK}}'
failoverLog: '{{swapSecrets.FAILOVER_LOG}}'

'''


import boto3
import botocore

def revertPort(event,context):

  #variables
  failoverLog = event['failoverLog']
  failoverLog.append("STEP: revertPort\n")
  wiki = event['wikiLink']
  active_region=event['region']
  if (active_region == 'us-east-1'):
    Listener_ARN = 'arn:aws:elasticloadbalancing:us-east-1:AWSACCOUNT#:listener/app/qa/' #east LB listener ARN
  elif (active_region == 'us-west-2'):
    Listener_ARN = 'arn:aws:elasticloadbalancing:us-west-2:AWSACCOUNT#:listener/app/qa/' #west LB listener ARN
    
  client = boto3.client('elbv2', region_name = active_region)
  
  #updates port on listener from 4443 to 443 for the active region
  failoverLog.append(f"UPDATING PORT ON THE {active_region} LOAD BALANCER TO RESTORE THE CONNECTION USED BY partner3...")
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
  
  #parsing response checks
  port_after_change = response_check["Listeners"][0]["Port"]
  
  #--- validate step success ---
  try:
    if (port_after_change == 443):
      log = "STEP STATUS: SUCCESS!\nTHE PORT ON THE LISTENER HAS BEEN UPDATED TO: 443"
    elif (port_after_change == 4443):
      log = f"STEP STATUS: FAILED!\nERROR CODE: 12A\nTHE PORT ON ONE OF THE LISTENERS IS STILL: 4443\nYOU MAY HAVE TO MANUALLY RESTORE THIS CONNECTION.\n{wiki}"
    else:
      log = f"STEP STATUS: FAILED!\nERROR CODE: 12B\nTHE PORT ON THE LISTENER IS AN UNKNOWN VALUE: {port_after_change}\nYOU MAY HAVE TO MANUALLY RESTORE THIS CONNECTION.\n{wiki}"
  except:
    log = f"STEP STATUS: UNKNOWN!\nERROR CODE: 12C\nTHERE WAS AN ISSUE PARSING OUTPUTS AND VALIDATING SUCCESS. THIS DOES NOT MEAN THAT THE LISTENER WAS NOT UPDATED. PLEASE MANUALLY CHECK THE LISTENER ON THE LOADBALANCER ({Listener_ARN}) TO CONFIRM THAT IT HAS BEEN UPDATED.\n{wiki}"

  failoverLog.append("\n" + log)
  return {'FAILOVER_LOG': failoverLog}
