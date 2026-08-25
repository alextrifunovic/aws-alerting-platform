output "ingestion_role_arn" {
  value = aws_iam_role.ingestion_lambda.arn
}

output "usgs_poller_lambda_role_arn" {
  value = aws_iam_role.usgs_poller_lambda.arn
}

output "targeting_lambda_arn" {
  value = aws_iam_role.targeting_lambda.arn
}