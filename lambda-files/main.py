import logging
import boto3
import zlib
import os
import base64
import json
from cloudwatch import CloudWatchClient

logger = logging.getLogger()
logger.setLevel(logging.INFO)  # Set to ERROR to log only error and critical messages.

LOG_LEVEL                          = os.environ['LOG_LEVEL']
ACCOUNT_ID                         = os.environ['ACCOUNT_ID']
REGION                             = os.environ['REGION']
CENTRAL_ERROR_IAM_ROLE_ARN         = os.environ['CENTRAL_ERROR_IAM_ROLE_ARN']
CENTRAL_ERROR_LOGGROUP_NAME        = os.environ['CENTRAL_ERROR_LOGGROUP_NAME']
CENTRAL_ERROR_LOGGROUP_REGION_NAME = os.environ['CENTRAL_ERROR_LOGGROUP_REGION_NAME']

def lambda_handler(event, context):
    try:
        # Assume the role in the other account
        sts = boto3.client('sts')
        assumed_role = sts.assume_role(
            RoleArn=CENTRAL_ERROR_IAM_ROLE_ARN,  # Ensure this is passed correctly in the event or environment
            RoleSessionName='logSession'
        )
        
        # Credentials for the assumed role
        creds = assumed_role['Credentials']
        
        # Initialize CloudWatchClient with remote AWS credentials
        remote_aws = boto3.client(
            'logs',
            aws_access_key_id=creds['AccessKeyId'],
            aws_secret_access_key=creds['SecretAccessKey'],
            aws_session_token=creds['SessionToken'],
            region_name=CENTRAL_ERROR_LOGGROUP_REGION_NAME  # Ensure this is passed correctly in the event or environment
        )
        
        cloud_watch_client = CloudWatchClient(logger, remote_aws, CENTRAL_ERROR_LOGGROUP_NAME)
        
        # Extract log data from the CloudWatch log event
        payload = base64.b64decode(event['awslogs']['data'])
        decompressed = zlib.decompress(payload, 16+zlib.MAX_WBITS)
        log_data = json.loads(decompressed.decode('utf8'))
        
        # Use CloudWatchClient to send the log data
        for log_event in log_data.get('logEvents', []):
            message = {
                "account_id": log_data.get('owner'),
                "region": REGION,
                "log_group": log_data.get('logGroup'),
                "message": log_event.get('message')
            }
            cloud_watch_client.send_to_cw(ACCOUNT_ID, message)  # Assuming method signature matches
        
        return {
            'statusCode': 200,
            'body': json.dumps({'message': 'Log processed successfully'})
        }
    except Exception as error:
        print(f'Error processing log: {str(error)}')
        return {
            'statusCode': 500,
            'body': json.dumps({'error': str(error)})
        }
