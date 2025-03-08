import boto3
import os
import json
import logging

# Configure logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Load environment variables
table_name = os.environ.get('DDB_TABLE')
sns_topic_arn = os.environ.get('SNS_TOPIC_ARN')

logging.info(f"## Loaded table name from environment variable DDB_TABLE: {table_name}")
logging.info(f"## Loaded SNS topic ARN from environment variable SNS_TOPIC_ARN: {sns_topic_arn}")

# Initialize AWS clients
dynamodb_client = boto3.client('dynamodb')
dynamodb_resource = boto3.resource("dynamodb")
sns_client = boto3.client('sns')

table = dynamodb_resource.Table(table_name)
logging.info(f"## Initialized DynamoDB table")

def send_sns_notification(message):
    """Publish a message to SNS topic."""
    try:
        response = sns_client.publish(
            TopicArn=sns_topic_arn,
            Message=json.dumps(message),
            Subject="Lambda Notification"
        )
        logging.info(f"## SNS publish response: {response}")
    except Exception as e:
        logging.error(f"## Failed to publish SNS notification: {str(e)}")

def lambda_handler(event, context):
    logging.info(f"event: {event}")
    logging.info(f"routeKey: {event.get('routeKey', 'UNKNOWN')}")

    body = {}
    
    try:
        if event['routeKey'] == "DELETE /topmovies/{year}":
            year = int(event['pathParameters']['year'])
            query_result = table.delete_item(Key={'year': year})
            logging.info(f"query_result: {query_result}")
            body = {"message": f"Deleted top movie for {year}"}
            send_sns_notification(body)

        elif event['routeKey'] == "GET /topmovies/{year}":
            year = int(event['pathParameters']['year'])
            query_result = table.get_item(Key={'year': year})
            logging.info(f"query_result: {query_result}")
            if "Item" in query_result.keys():
                item = query_result["Item"]
                body = {"year": int(item['year']), "title": item['title']}
            else:
                body = {"message": f"No top movie found for {year}"}
            send_sns_notification(body)

        elif event['routeKey'] == "GET /topmovies":
            query_result = table.scan()
            logging.info(f"query_result: {query_result}")
            items = query_result.get("Items", [])
            body = [{"year": int(item['year']), "title": item['title']} for item in items]
            send_sns_notification({"message": "Fetched all top movies", "movies": body})

        elif event['routeKey'] == "PUT /topmovies":
            request_body = json.loads(event.get('body', '{}'))
            logging.info(f"request_body: {request_body}")
            year = int(request_body["year"])
            title = request_body["title"]
            query_result = table.put_item(Item={"year": year, "title": title})
            logging.info(f"query_result: {query_result}")
            body = {"message": f"Added top movie for {year}"}
            send_sns_notification(body)

        else:
            body = {"message": "Invalid route"}
            logging.warning(f"## Invalid routeKey: {event.get('routeKey')}")

    except Exception as e:
        logging.error(f"## Error processing request: {str(e)}")
        body = {"error": str(e)}

    response_body = json.dumps(body)
    logging.info(f"Response body: {response_body}")

    return {
        "statusCode": 200,
        "headers": {
            "Content-Type": "application/json"
        },
        "body": response_body
    }
