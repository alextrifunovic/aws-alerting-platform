resource "aws_dynamodb_table" "incidents" {

  name         = "incidents"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "incident_id"
  attribute {
    name = "incident_id"
    type = "S"
  }

}

resource "aws_dynamodb_table" "users" {

  name         = "users"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "user_id"
  attribute {

    name = "user_id"
    type = "S"

  }

  attribute {

    name = "location"
    type = "S"

  }

  global_secondary_index {
    name            = "location-index"
    hash_key        = "location"
    projection_type = "ALL"
  }



}

resource "aws_dynamodb_table" "connections" {

  name         = "connections"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "connection_id"

  attribute {

    name = "connection_id"
    type = "S"

  }




}
