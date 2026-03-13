module "context" {
  source       = "../modules/platform_context"
  project_name = var.project_name
  environment  = var.environment
  project_version = var.project_version
}

locals {
  reference_stack = {
    edge            = "external https load balancer"
    container_hosts = "cloud run or gke"
    automation      = ["cloud build", "terraform", "ansible"]
    lambdas_equiv   = "cloud functions"
    region          = var.region
  }
}
