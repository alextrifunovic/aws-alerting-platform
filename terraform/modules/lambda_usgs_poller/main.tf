
data "archive_file" "lambda_usgs_poller_zip" {
  type = "zip"
  source_dir = "${path.module}/../../../src/usgs_poller"
  output_path = "${path.module}/../../../build/usgs_poller.zip"
}

resource "aws_lambda_function" "usgs_poller" {
  function_name    = "usgs_poller"
  role              = var.usgs_poller_lambda_role_arn
  handler           = "handler.handler"
  runtime           = "python3.12"
  filename          = data.archive_file.lambda_usgs_poller_zip.output_path
  source_code_hash  = data.archive_file.lambda_usgs_poller_zip.output_base64sha256
  timeout           = 30

  environment {
    variables = {
      INCIDENTS_TABLE_NAME = var.incidents_table_name
    }
  }
}

resource "aws_cloudwatch_event_rule" "usgs_poller_schedule" {
  name = "usgs_poller_schedule"
  schedule_expression = "rate(5 minutes)"
}

resource "aws_cloudwatch_event_target" "usgs_poller_target" {
  arn  = aws_lambda_function.usgs_poller.arn
  rule = aws_cloudwatch_event_rule.usgs_poller_schedule.name
  target_id = "usgs-poller-lambda"
}

resource "aws_lambda_permission" "eventbridge" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.usgs_poller.function_name
  principal     = "events.amazonaws.com"
  statement_id = "AllowEventBridgeInvoke"
  source_arn = aws_cloudwatch_event_rule.usgs_poller_schedule.arn
}