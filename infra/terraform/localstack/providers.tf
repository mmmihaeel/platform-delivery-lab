provider "aws" {
  access_key                  = "test"
  secret_key                  = "test"
  region                      = var.aws_region
  s3_use_path_style           = true
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_region_validation      = true
  skip_requesting_account_id  = true

  endpoints {
    iam    = var.localstack_endpoint
    lambda = var.localstack_endpoint
    logs   = var.localstack_endpoint
    s3     = var.localstack_endpoint
    sts    = var.localstack_endpoint
  }
}
