output "reference_architecture" {
  value = {
    labels = module.context.labels
    stack  = local.reference_stack
  }
}
