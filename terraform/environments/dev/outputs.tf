output "ingestion_api_endpoint" {
  value = module.lambda_ingestion.api_endpoint
}

output "usgs_poller_function_name" {
  value = module.lambda_usgs_poller.usgs_poller_function_name
}

output "targeting_function_name" {
  value = module.targeting.targeting_function_name
}