import boto3
import json
from datetime import datetime
from botocore.exceptions import ClientError

  def get_active_stack(event,context):
    print("\n")
      
    region_east = event['REGION_EAST']
    region_west = event['REGION_WEST']
    dt_raw = datetime.now()
    current_datetime = dt_raw.strftime("%Y-%m-%dT%H:%M:00Z")
    print_datetime = dt_raw.strftime("%m/%d/%Y %H:%M:%S")
    
    #get the secret from us-east-1
    session = boto3.session.Session()
    try:
      secret_name = "arn:aws:secretsmanager:us-east-1:AWSaccountNumber:secret:genericServiceName-LWR_ENV-STACKS"
    
      client = session.client(service_name='secretsmanager',region_name="us-east-1")
  
      get_secret_value_response = client.get_secret_value(SecretId=secret_name)
      
    #if failed to get secrets from us-east-1, try replica in us-west-2
    except:
      print("")
      print("FAILED TO RETRIEVE SECRETS FROM US-EAST-1! RETRIEVING SECRETS FROM US-WEST-2.")
      secret_name = "arn:aws:secretsmanager:us-west-2:AWSaccountNumber:secret:genericServiceName-LWR_ENV-STACKS"
    
      client = session.client(service_name='secretsmanager',region_name="us-west-2")
    
      get_secret_value_response = client.get_secret_value(SecretId=secret_name)
      
    #parsing secrets and saving them as vars
    genericServiceName_secrets = json.loads(get_secret_value_response['SecretString'])
    active_stack = genericServiceName_secrets['PRIMARY_genericServiceName_LWR_ENV_STACK'] 
    
    if (active_stack == 'EAST'):
        active_region=region_east
        standby_region=region_west
    elif (active_stack == 'WEST'):
        active_region=region_west
        standby_region=region_east
    
    print("\n-- -- -- -- -- -- -- -- -- -- --\n")
    print(f"THE CURRENT ACTIVE REGION IN genericServiceName-LWR_ENV IS: {active_region}.")
    print(f"THE CURRENT STANDBY REGION IN genericServiceName-LWR_ENV IS: {standby_region}.")
    print(f"THE CURRENT DATE AND TIME IS: {print_datetime}.")
    print("\n-- -- -- -- -- -- -- -- -- -- --\n")
    
    return {'ACTIVE_REGION': active_region, 'STANDBY_REGION': standby_region}