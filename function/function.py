import boto3
import datetime

<<<<<<< HEAD
exporters = {}

=======
>>>>>>> develop
def handler(event, context):
    s3 = boto3.client('s3')
    keys = []
    objs = s3.list_objects(Bucket='lambda-run-on-success', Prefix="status/")
    for obj in objs["Contents"]:
        key = obj["Key"]
        
        status = key.split('/')[-1]
        keys.append(status)

    if '_SUCCESS' in keys:
        print("FOUND")