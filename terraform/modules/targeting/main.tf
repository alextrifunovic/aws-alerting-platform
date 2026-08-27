data "archive_file" "targeting_lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../../../src/targeting"
  output_path = "${path.module}/../../../build/targeting.zip"
}

resource "aws_lambda_function" "targeting" {
  function_name    = "targeting"
  role              = var.targeting_lambda_role_arn
  handler           = "handler.handler"
  runtime           = "python3.12"
  filename          = data.archive_file.targeting_lambda_zip.output_path
  source_code_hash  = data.archive_file.targeting_lambda_zip.output_base64sha256
  timeout           = 10

  environment {
    variables = {
      INCIDENTS_TABLE_NAME = var.incidents_table_name
      USERS_TABLE_NAME = var.users_table_name
    }
  }
}

