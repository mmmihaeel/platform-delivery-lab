output "localstack_endpoint" {
  value = var.localstack_endpoint
}

output "deployed_functions" {
  value = {
    node = module.node_lambda.function_name
    java = module.java_lambda.function_name
  }
}

output "packaged_only_functions" {
  value = {
    go  = local.lambda_packages.go
    php = local.lambda_packages.php
  }
}
