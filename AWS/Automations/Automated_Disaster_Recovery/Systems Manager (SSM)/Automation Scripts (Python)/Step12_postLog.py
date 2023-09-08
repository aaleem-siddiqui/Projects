'''
INPUT PAYLOAD:

failoverLog: '{{revertPort.FAILOVER_LOG}}'

'''


import boto3
import botocore
import datetime

def postLog(event,context):
  
  #variables
  lineBreak = "\n\n🔷➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖🔷\n\n"
  stepBreak =  "\n-- -- -- -- -- -- -- -- -- -- --\n"
  failoverLog = event['failoverLog'] 
  printFailoverLog = ""
  
  #adds emojies to log based on step status
  for f in failoverLog:
    if "STEP:" in f:
      printFailoverLog += lineBreak
      printFailoverLog += f
    elif "STEP STATUS: S" in f:
      printFailoverLog += f"{stepBreak} ✅ "
      printFailoverLog += f
    elif "STEP STATUS: F" in f:
      printFailoverLog += f"{stepBreak} ❌ "
      printFailoverLog += f
    elif "STEP STATUS: I" in f:
      printFailoverLog += f"{stepBreak} ⏳ "
      printFailoverLog += f
    elif "STEP STATUS: U" in f:
      printFailoverLog += "{stepBreak} ❓ " 
      printFailoverLog += f
    else:
      printFailoverLog += f


  printFailoverLog += "\n\n\n🔔 REMINDER: PERFORM QA TESTING AND REMEMBER TO APPROVE POST ACTIONS AFTERWARDS. 🔔"

  #post to slack  
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
  

  #sends log to slack
  slack = 'alerts-testing'
  snsclient = boto3.client('sns')
  snsArn = 'arn:aws:sns:us-east-1:AWSACCOUNT#:MICROSERVICE_FAILOVER_NOTIF'
  message = printFailoverLog
  
  try:
    response = snsclient.publish(
      TopicArn = snsArn,
      Message = message,
      MessageAttributes={
        'Channel': {
          'DataType': 'String',
          'StringValue': slack
        }
      },
      Subject = "POST MICROSERVICE FAILOVER LOG"
    )
    
  except:
    print("UNABLE TO POST TO SLACK.")


  