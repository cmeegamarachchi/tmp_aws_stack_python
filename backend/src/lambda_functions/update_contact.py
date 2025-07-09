import json
import sys
import os

# Add the layer to the Python path
sys.path.append("/opt/python")

from contact_service import contact_service


def lambda_handler(event, context):
    """Lambda function to update an existing contact"""

    try:
        # Handle CORS preflight
        if event.get("httpMethod") == "OPTIONS":
            return {
                "statusCode": 200,
                "headers": {
                    "Access-Control-Allow-Origin": "*",
                    "Access-Control-Allow-Headers": "Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token",
                    "Access-Control-Allow-Methods": "PUT,OPTIONS",
                },
                "body": "",
            }

        # Get contact ID from path parameters
        contact_id = event.get("pathParameters", {}).get("id")

        if not contact_id:
            return {
                "statusCode": 400,
                "headers": {
                    "Content-Type": "application/json",
                    "Access-Control-Allow-Origin": "*",
                },
                "body": json.dumps(
                    {"success": False, "error": "Contact ID is required"}
                ),
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

        # Update contact
        updated_contact = contact_service.update_contact(contact_id, contact_data)

        return {
            "statusCode": 200,
            "headers": {
                "Content-Type": "application/json",
                "Access-Control-Allow-Origin": "*",
                "Access-Control-Allow-Headers": "Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token",
                "Access-Control-Allow-Methods": "PUT,OPTIONS",
            },
            "body": json.dumps({"success": True, "data": updated_contact}),
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
