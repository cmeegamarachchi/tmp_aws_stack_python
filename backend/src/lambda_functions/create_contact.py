import json
import sys
import os

# Add the layer to the Python path
sys.path.append("/opt/python")

from contact_service import contact_service


def lambda_handler(event, context):
    """Lambda function to create a new contact"""

    try:
        # Handle CORS preflight
        if event.get("httpMethod") == "OPTIONS":
            return {
                "statusCode": 200,
                "headers": {
                    "Access-Control-Allow-Origin": "*",
                    "Access-Control-Allow-Headers": "Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token",
                    "Access-Control-Allow-Methods": "POST,OPTIONS",
                },
                "body": "",
            }

        # Parse request body
        if not event.get("body"):
            return {
                "statusCode": 400,
                "headers": {
                    "Content-Type": "application/json",
                    "Access-Control-Allow-Origin": "*",
                },
                "body": json.dumps(
                    {"success": False, "error": "Request body is required"}
                ),
            }

        try:
            contact_data = json.loads(event["body"])
        except json.JSONDecodeError:
            return {
                "statusCode": 400,
                "headers": {
                    "Content-Type": "application/json",
                    "Access-Control-Allow-Origin": "*",
                },
                "body": json.dumps(
                    {"success": False, "error": "Invalid JSON in request body"}
                ),
            }

        # Create contact
        created_contact = contact_service.create_contact(contact_data)

        return {
            "statusCode": 201,
            "headers": {
                "Content-Type": "application/json",
                "Access-Control-Allow-Origin": "*",
                "Access-Control-Allow-Headers": "Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token",
                "Access-Control-Allow-Methods": "POST,OPTIONS",
            },
            "body": json.dumps({"success": True, "data": created_contact}),
        }

    except ValueError as e:
        return {
            "statusCode": 400,
            "headers": {
                "Content-Type": "application/json",
                "Access-Control-Allow-Origin": "*",
            },
            "body": json.dumps({"success": False, "error": str(e)}),
        }
    except Exception as e:
        print(f"Error: {str(e)}")
        return {
            "statusCode": 500,
            "headers": {
                "Content-Type": "application/json",
                "Access-Control-Allow-Origin": "*",
            },
            "body": json.dumps({"success": False, "error": str(e)}),
        }
