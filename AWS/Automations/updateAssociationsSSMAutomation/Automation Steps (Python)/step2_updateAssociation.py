import boto3
from datetime import datetime

def updateRestartgenericServiceNameStatusAssociation(event,context):
  
  ############################################### VARS ###############################################

  
  active_region = event['active_region']
  standby_region = event['standby_region']
  
  if (active_region == 'us-east-1'):
    associationIDActive = "[ASSOCIATION_ID_HERE]" #restartgenericServiceNameStatus association in west
    associationIDStandby = "[ASSOCIATION_ID_HERE]" #restartgenericServiceNameStatus association in east
  elif (active_region == 'us-west-2'):
    associationIDActive = "[ASSOCIATION_ID_HERE]" #restartgenericServiceNameStatus association in east
    associationIDStandby = "[ASSOCIATION_ID_HERE]" #restartgenericServiceNameStatus association in west

  activeCommand = "sudo su ubuntu -c \"pm2 restart genericServiceName-status\""
  standbyCommand = "ls -al"
  timeout = '3600'
  assName = "restartgenericServiceNameStatus"
  Schedule = "cron(0 00 09 ? * * *)"
  S3bucket = "restart-genericServiceName-status-association-outputs"
  
  
  ############################################### ACTIVE ###############################################
  
  clientActive = boto3.client('ssm',region_name=active_region)
  
  responseActive = clientActive.update_association(
    AssociationId=f"{associationIDActive}",
    AssociationName=f"{assName}",
    ApplyOnlyAtCronInterval=True,
    DocumentVersion='$DEFAULT',
    ScheduleExpression=f"{Schedule}",
    Parameters={
        'commands': [
            activeCommand
        ],
        'executionTimeout': [
            timeout
          ]
      },
    OutputLocation={
        'S3Location': {
            'OutputS3Region': 'us-east-1',
            'OutputS3BucketName': f"{S3bucket}",
        }
    }
    )
    
  ############################################### STANDBY ###############################################

  clientStandby = boto3.client('ssm',region_name=standby_region)
  
  responseStandby = clientStandby.update_association(
    AssociationId=f"{associationIDStandby}",
    AssociationName=f"{assName}",
    ApplyOnlyAtCronInterval=True,
    DocumentVersion='$DEFAULT',
    ScheduleExpression=f"{Schedule}",
    Parameters={
        'commands': [
            standbyCommand
        ],
        'executionTimeout': [
            timeout
          ]
      },
    OutputLocation={
        'S3Location': {
            'OutputS3Region': 'us-east-1',
            'OutputS3BucketName': f"{S3bucket}",
        }
    }
    )
    
  ############################################### OUTPUT ###############################################

  print("\nRequest Response Active\n:")
  print(responseActive)
  print("\n----------------------------------------------------------")
  print("\nRequest Response Standby:\n")
  print(responseStandby)