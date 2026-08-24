
import boto3
import os
import json
from boto3.dynamodb.conditions import Key



dynamodb = boto3.resource("dynamodb")
incidents_table = dynamodb.Table(os.environ["INCIDENTS_TABLE_NAME"])
users_table = dynamodb.Table(os.environ["USERS_TABLE_NAME"])


def handler(event, context):
    incident_id = event.get("incident_id")
    incident = incidents_table.get_item(Key={"incident_id": incident_id})

    if "Item" not in incident:
        return {"error" : "Incident not found", "incident_id" : incident_id}


    incident_data = incident["Item"]

    incident_location = incident_data["location"]

    response = users_table.query(IndexName = "location-index", KeyConditionExpression = Key("location").eq(incident_location))

    users = response["Items"]

    user_ids = []

    for user in users:
        user_ids.append(user["user_id"])

    return {"incident_id" : incident_id, "targeted_users" : user_ids, "users_count" : len(user_ids)}

