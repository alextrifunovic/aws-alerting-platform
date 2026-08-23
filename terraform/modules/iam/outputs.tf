output "ingestion_role_arn" {
  value = aws_iam_role.ingestion_lambda.arn
}

output "usgs_poller_lambda_role_arn" {
  value = aws_iam_role.usgs_poller_lambda.arn
}