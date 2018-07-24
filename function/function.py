import boto3
import datetime
import os

def handler(event, context):
    bucket = os.environ['AWS_BUCKET']

    s3 = boto3.client('s3')
    keys = []
    objs = s3.list_objects(Bucket=bucket, Prefix="status/")
    for obj in objs["Contents"]:
        key = obj["Key"]
        
        status = key.split('/')[-1]
        keys.append(status)

    if '_SUCCESS' in keys:
        print("FOUND")