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

resource "aws_iam_role" "ingestion_lambda" {
  name               = "ingestion-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

resource "aws_iam_role_policy_attachment" "ingestion_lambda_basic_logs" {
  role       = aws_iam_role.ingestion_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

data "aws_iam_policy_document" "ingestion_lambda_dynamodb" {
  statement {
    effect    = "Allow"
    actions   = ["dynamodb:PutItem"]
    resources = [var.incidents_table_arn]
  }
}

resource "aws_iam_role_policy" "ingestion_lambda_dynamodb" {
  name   = "ingestion-lambda-dynamodb-write"
  role   = aws_iam_role.ingestion_lambda.id
  policy = data.aws_iam_policy_document.ingestion_lambda_dynamodb.json
}