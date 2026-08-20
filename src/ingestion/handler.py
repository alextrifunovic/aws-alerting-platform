import json
import os
import uuid
from datetime import datetime, timezone

import boto3

dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table(os.environ["INCIDENTS_TABLE_NAME"])

VALID_TYPES = {"earthquake", "fire", "flood", "other"}
VALID_SEVERITIES = {"low", "medium", "high", "critical"}


def handler(event, context):
    try:
        body = json.loads(event.get("body") or "{}")
    except json.JSONDecodeError:
        return _response(400, {"error": "Invalid JSON body"})

    incident_type = body.get("type")
    location = body.get("location")
    severity = body.get("severity")
    description = body.get("description", "")

    if incident_type not in VALID_TYPES:
        return _response(400, {"error": f"type must be one of {sorted(VALID_TYPES)}"})
    if not location:
        return _response(400, {"error": "location is required"})
    if severity not in VALID_SEVERITIES:
        return _response(400, {"error": f"severity must be one of {sorted(VALID_SEVERITIES)}"})

    incident_id = str(uuid.uuid4())
    item = {
        "incident_id": incident_id,
        "type": incident_type,
        "location": location,
        "severity": severity,
        "description": description,
        "status": "pending",
        "created_at": datetime.now(timezone.utc).isoformat(),
    }

    table.put_item(Item=item)

    return _response(201, {"incident_id": incident_id, "status": "pending"})


def _response(status_code, body_dict):
    return {
        "statusCode": status_code,
        "headers": {"Content-Type": "application/json"},
        "body": json.dumps(body_dict),
    }