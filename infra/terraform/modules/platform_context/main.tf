locals {
  prefix = "${var.project_name}-${var.environment}"
  labels = {
    project     = var.project_name
    environment = var.environment
    version     = var.project_version
    managed_by  = "terraform"
  }
}
