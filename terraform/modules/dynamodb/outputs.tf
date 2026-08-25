output "incidents_table_arn" {
  value = aws_dynamodb_table.incidents.arn
}

output "incidents_table_name" {
  value = aws_dynamodb_table.incidents.name
}

output "users_table_arn" {
  value = aws_dynamodb_table.users.arn
}

output "users_table_name" {
  value = aws_dynamodb_table.users.name
}