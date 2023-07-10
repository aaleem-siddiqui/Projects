import pymongo
import requests
import boto3
import json
import botocore
import sys

def lambda_handler(event, context):
    
    #setting vars
    region=event['region']
    creds=event['creds']
    readOnly=event['readOnly']
    table1Output = []
    table2Output = []
    table3Output = []
    
    #establishes pymongo docdb client
    DocDBclient = pymongo.MongoClient(f"mongodb://{creds}@db.cluster.us-east-1.docdb.amazonaws.com:12345/?replicaSet=rs0&readPreference=secondaryPreferred&retryWrites=false")
    mydb = DocDBclient["db"]
    mycol = mydb["collection"]

    #enables table1, table2, and table3 API calls
    if (region == 'us-west-2'):
        MP_SSN = False
        SR = True
    #disables table1, table2, and table3 API calls
    elif (region == 'us-east-1'):
        MP_SSN = True
        SR = False
    
    #updates to dbs
    if (readOnly == "false"):
        mycol.update_one({"service":"service1"},{"$set":{"configuration.example" : MP_SSN}})
        mycol.update_one({"service":"service2", "env" : "lower_environment"},{"$set":{"configuration.reportDetails.example.sendToS3" : SR,"configuration.reportDetails.example.sendToS3" : SR,"configuration.reportDetails.example.sendToS3" : SR,"configuration.reportDetails.example.sendToS3" : SR}})
        mycol.update_one({"service":"service3"},{"$set":{"configuration.partners.shippingpartner1.apiInfo.fakeApi" : MP_SSN,"configuration.partners.shippingpartner2.apiInfo.fakeApi" : MP_SSN,"configuration.partners.shippingpartner3.apiInfo.fakeApi" : MP_SSN}})
    else:
        print("READING VALUES FROM THE DATABASE...")

    #returns result from table1 DB
    table1 = mycol.find({"service":"service1"},{"_id": 0 ,"configuration.example" : 1})
    for x in table1:
        table1Output.append(x)
    #returns result from table2 DB
    table2 = mycol.find({"service":"service2", "env" : "lower_environment"},{"_id": 0 ,"configuration.reportDetails.example.sendToS3" : 1,"configuration.reportDetails.example.sendToS3" : 1,"configuration.reportDetails.example.sendToS3" : 1,"configuration.reportDetails.example.sendToS3" : 1})
    for x in table2:
        table2Output.append(x)
    #returns result from table3 API DB
    table3 = mycol.find({"service":"service3"},{"_id": 0 ,"configuration.partners.shippingpartner1.apiInfo.fakeApi" : 1,"configuration.partners.shippingpartner2.apiInfo.fakeApi" : 1,"configuration.partners.shippingpartner3.apiInfo.fakeApi" : 1})
    for x in table3:
        table3Output.append(x)
    
    print("-------------------------------------")
    print(str(table1Output))
    print(str(table2Output))
    print(str(table3Output))
    print("-------------------------------------")
        
    return{'table1': str(table1Output),'table2': str(table2Output), 'table3': str(table3Output)}
