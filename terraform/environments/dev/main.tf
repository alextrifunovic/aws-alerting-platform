terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "eu-central-1"
}

module "dynamodb" {
  source = "../../modules/dynamodb"
}

module "iam" {
  source               = "../../modules/iam"
  incidents_table_arn  = module.dynamodb.incidents_table_arn
  users_table_arn = module.dynamodb.users_table_arn
}

module "lambda_ingestion" {
  source                = "../../modules/lambda_ingestion"
  ingestion_role_arn    = module.iam.ingestion_role_arn
  incidents_table_name  = module.dynamodb.incidents_table_name
}

module "lambda_usgs_poller" {
  source = "../../modules/lambda_usgs_poller"
  usgs_poller_lambda_role_arn = module.iam.usgs_poller_lambda_role_arn
  incidents_table_name = module.dynamodb.incidents_table_name
}