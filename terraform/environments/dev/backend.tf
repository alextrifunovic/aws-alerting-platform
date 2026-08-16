terraform {
  backend "s3" {
    bucket         = "aws-alerting-platform-tfstate-alextrifunovic"
    key            = "dev/terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "aws-alerting-platform-tf-lock"
    encrypt        = true
  }
}
