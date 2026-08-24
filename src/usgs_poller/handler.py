import json
import logging
import os
import urllib.error
import urllib.request
from datetime import datetime, timezone

import boto3
from botocore.exceptions import ClientError

logger = logging.getLogger()
logger.setLevel(logging.INFO)

dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table(os.environ["INCIDENTS_TABLE_NAME"])

USGS_URL = "https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/2.5_day.geojson"
MIN_MAGNITUDE = 1.7
REQUEST_TIMEOUT_SECONDS = 5


def handler(event, context):
    try:
        with urllib.request.urlopen(USGS_URL, timeout=REQUEST_TIMEOUT_SECONDS) as response:
            data = json.loads(response.read())
    except (urllib.error.URLError, TimeoutError, json.JSONDecodeError):
        logger.exception("Failed to fetch or parse USGS feed")
        raise

    created_count = 0
    skipped_count = 0

    for feature in data["features"]:
        try:
            usgs_id = feature["id"]
            magnitude = feature["properties"]["mag"]
            place = feature["properties"]["place"]
        except (KeyError, TypeError):
            logger.warning("Skipping malformed feature: %s", feature)
            skipped_count += 1
            continue

        if magnitude is None or magnitude < MIN_MAGNITUDE:
            continue

        incident_id = f"usgs-{usgs_id}"

        item = {
            "incident_id": incident_id,
            "type": "earthquake",
            "location": place,
            "severity": _magnitude_to_severity(magnitude),
            "description": f"Magnitude {magnitude} earthquake near {place}",
            "status": "pending",
            "created_at": datetime.now(timezone.utc).isoformat(),
        }

        try:
            table.put_item(
                Item=item,
                ConditionExpression="attribute_not_exists(incident_id)",
            )
            created_count += 1
        except ClientError as error:
            if error.response["Error"]["Code"] == "ConditionalCheckFailedException":
                continue
            raise

    logger.info(
        "Processed USGS feed: created=%d skipped=%d", created_count, skipped_count
    )
    return {"processed": created_count}


def _magnitude_to_severity(magnitude):
    if magnitude >= 7.0:
        return "critical"
    elif magnitude >= 6.0:
        return "high"
    elif magnitude >= 5.0:
        return "medium"
    else:
        return "low"
