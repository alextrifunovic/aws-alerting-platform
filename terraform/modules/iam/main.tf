
data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "usgs_poller_lambda" {
  name = "usgs_poller_lambda_role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

resource "aws_iam_role" "ingestion_lambda" {
  name               = "ingestion-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

resource "aws_iam_role_policy_attachment" "ingestion_lambda_basic_logs" {
  role       = aws_iam_role.ingestion_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "usgs_poller_lambda_basic_logs" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.usgs_poller_lambda.name
}

data "aws_iam_policy_document" "ingestion_lambda_dynamodb" {
  statement {
    effect    = "Allow"
    actions   = ["dynamodb:PutItem"]
    resources = [var.incidents_table_arn]
  }
}

data "aws_iam_policy_document" "usgs_poller_lambda_dynamodb" {
  statement {
    effect = "Allow"
    actions = ["dynamodb:GetItem"]
    resources = [var.incidents_table_arn]
  }
  statement {
    effect = "Allow"
    actions = ["dynamodb:PutItem"]
    resources = [var.incidents_table_arn]
  }
}

resource "aws_iam_role_policy" "ingestion_lambda_dynamodb" {
  name   = "ingestion-lambda-dynamodb-write"
  role   = aws_iam_role.ingestion_lambda.id
  policy = data.aws_iam_policy_document.ingestion_lambda_dynamodb.json
}

resource "aws_iam_role_policy" "usgs_poller_dynamodb" {
  name = "usgs-poller-lambda-dynamodb-read-write"
  policy = data.aws_iam_policy_document.usgs_poller_lambda_dynamodb.json
  role   = aws_iam_role.usgs_poller_lambda.id
}