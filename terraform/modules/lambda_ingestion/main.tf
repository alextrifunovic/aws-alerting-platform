data "archive_file" "ingestion_lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../../../src/ingestion"
  output_path = "${path.module}/../../../build/ingestion.zip"
}

resource "aws_lambda_function" "ingestion" {
  function_name    = "ingestion"
  role              = var.ingestion_role_arn
  handler           = "handler.handler"
  runtime           = "python3.12"
  filename          = data.archive_file.ingestion_lambda_zip.output_path
  source_code_hash  = data.archive_file.ingestion_lambda_zip.output_base64sha256
  timeout           = 10

  environment {
    variables = {
      INCIDENTS_TABLE_NAME = var.incidents_table_name
    }
  }
}

resource "aws_apigatewayv2_api" "ingestion" {
  name          = "ingestion-api"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_integration" "ingestion" {
  api_id                 = aws_apigatewayv2_api.ingestion.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.ingestion.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "ingestion_post" {
  api_id    = aws_apigatewayv2_api.ingestion.id
  route_key = "POST /incidents"
  target    = "integrations/${aws_apigatewayv2_integration.ingestion.id}"
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.ingestion.id
  name        = "$default"
  auto_deploy = true
}

resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.ingestion.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.ingestion.execution_arn}/*/*"
}