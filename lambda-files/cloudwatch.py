import json
import os
import time
import boto3
from botocore.exceptions import ClientError

class CloudWatchClient:
    def __init__(self, logger, boto3_logs_client, log_group_name):
        self.logger = logger
        self.group_name = log_group_name
        self.cw_client = boto3_logs_client
     
    def send_to_cw(self, log_stream_name, object_to_send):
        self.logger.debug(f"Send to {self.group_name}/{log_stream_name}")
        self.logger.debug(json.dumps(object_to_send))

        upload_sequence_token = ""
        timestamp = int(round(time.time() * 1000))
        self._ensure_log_stream_exists(log_stream_name)
        try:
            describe_log_streams = self.cw_client.describe_log_streams(
                logGroupName=self.group_name, logStreamNamePrefix=log_stream_name)
            security_event_stream = describe_log_streams['logStreams'][0]
            if 'uploadSequenceToken' in security_event_stream:
                upload_sequence_token = security_event_stream['uploadSequenceToken']

        except ClientError as e:
            self.logger.warning(f"describe_log_streams error {e.response}")

        tries = 1
        max_tries = 10
        while tries <= max_tries:
            if tries > 1:
                exponential_backoff_wait_time = 2**tries * 0.01  # wait for (2^tries * 10) milliseconds
                self.logger.debug(f"Exponential backoff: taking a nap for {exponential_backoff_wait_time} seconds.")
                time.sleep(exponential_backoff_wait_time)

            result = self._send_to_cw_real( 
                log_stream_name,
                timestamp,                
                object_to_send, 
                upload_sequence_token
            )
            if result == "":
                return
            else:
                upload_sequence_token = result
                tries += 1
                self.logger.warning(f"Try {tries}. time with upload_sequence_token {upload_sequence_token}")


        raise Exception(f"Was not able to write to {self.group_name} for {max_tries} times.")

    def _ensure_log_stream_exists(self, log_stream_name):
        try:
            self.cw_client.create_log_stream(
                logGroupName=self.group_name,
                logStreamName=log_stream_name
            )
            self.logger.debug(f"Log stream created: {log_stream_name}")
        except self.cw_client.exceptions.ResourceAlreadyExistsException:
            self.logger.warning(f"Log stream already exists: {log_stream_name}")
        except Exception as e:
            self.logger.exeption(f"createLogStream error: {str(e)}")
            raise


    def _send_to_cw_real(self, log_stream_name, timestamp, object_to_send, upload_sequence_token = ""):
        try:
            if upload_sequence_token != "":
                self.cw_client.put_log_events(logGroupName=self.group_name,
                    logStreamName=log_stream_name,
                    logEvents=[
                        {
                            'timestamp': timestamp,
                            'message': json.dumps(object_to_send)
                        }
                    ],
                    sequenceToken=upload_sequence_token
                )
            else:
                self.cw_client.put_log_events(logGroupName=self.group_name,
                    logStreamName=log_stream_name,
                    logEvents=[
                        {
                            'timestamp': timestamp,
                            'message': json.dumps(object_to_send)
                        }
                    ]
                )
            return ""

        except ClientError as e:
            self.logger.warning(f"e.response {e.response}")
            return e.response['expectedSequenceToken']
