import logging
import json

# Configure logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)  # Set to ERROR to log only error and critical messages.

def lambda_handler(event, context):
    try:
        # Assuming the event structure contains a 'logs' dictionary with keys as log levels
        logs = event.get('logs', {})
        for key, value in logs.items():
            if key.lower() == 'warn':
                logger.warning(value)  # Using 'warning' as the correct method name
            elif key.lower() == 'error':
                logger.error(value)
            elif key.lower() == 'info':
                logger.info(value)
            elif key.lower() == 'exception':
                logger.exception(value)  # Special case for logging exceptions if any
            else:
                logger.info(f"Unsupported log level: {key} with message: {value}")

    except Exception as e:
        # Log an error message
        logger.error("Error occurred: %s", e)


        # Optionally return an error response
        return {
            'statusCode': 500,
            'body': json.dumps({'error': str(e)})
        }

    # Return a successful response
    return {
        'statusCode': 200,
        'body': json.dumps({'message': 'Function executed successfully'})
    }
