module "context" {
  source       = "../modules/platform_context"
  project_name = var.project_name
  environment  = var.environment
  project_version = var.project_version
}

locals {
  lambda_packages = {
    node = "${path.root}/../../../dist/lambdas/node-ts/function.zip"
    go   = "${path.root}/../../../dist/lambdas/go/function.zip"
    java = "${path.root}/../../../dist/lambdas/java/function.zip"
    php  = "${path.root}/../../../dist/lambdas/php/function.zip"
  }

  shared_environment = {
    PLATFORM_NAME    = var.project_name
    PLATFORM_ENV     = var.environment
    PLATFORM_VERSION = var.project_version
  }
}
