module "context" {
  source       = "../modules/platform_context"
  project_name = var.project_name
  environment  = var.environment
  project_version = var.project_version
}

locals {
  reference_stack = {
    edge            = "application gateway"
    container_hosts = "container apps or aks"
    automation      = ["azure devops", "terraform", "ansible"]
    lambdas_equiv   = "azure functions"
    location        = var.location
  }
}
