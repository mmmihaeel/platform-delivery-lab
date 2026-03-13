module "context" {
  source       = "../modules/platform_context"
  project_name = var.project_name
  environment  = var.environment
  project_version = var.project_version
}

locals {
  reference_stack = {
    control_plane = "ecs + localstack parity"
    artifact_flow = "build -> package -> publish -> deploy"
    workloads = {
      edge      = "nginx"
      legacy    = "apache"
      runtimes  = ["node", "go", "java", "php"]
      lambdas   = ["node", "go", "java", "php-custom-runtime"]
      observability = ["cloudwatch", "container logs"]
    }
  }
}
