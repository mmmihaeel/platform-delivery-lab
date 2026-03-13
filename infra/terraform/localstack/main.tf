resource "aws_iam_role" "lambda_exec" {
  name = "${module.context.prefix}-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = module.context.labels
}

module "node_lambda" {
  source        = "../modules/lambda_function"
  function_name = "${var.project_name}-node-runtime"
  description   = "Node.js and TypeScript runtime contract packaged for LocalStack."
  filename      = local.lambda_packages.node
  handler       = "handler.handler"
  runtime       = "nodejs20.x"
  role_arn      = aws_iam_role.lambda_exec.arn
  environment   = merge(local.shared_environment, { RUNTIME_NAME = "nodejs20-typescript" })
  tags          = module.context.labels
}

module "java_lambda" {
  source        = "../modules/lambda_function"
  function_name = "${var.project_name}-java-runtime"
  description   = "Java runtime contract packaged for LocalStack."
  filename      = local.lambda_packages.java
  handler       = "io.platformdeliverylab.lambda.Handler::handleRequest"
  runtime       = "java11"
  role_arn      = aws_iam_role.lambda_exec.arn
  memory_size   = 256
  timeout       = 15
  environment   = merge(local.shared_environment, { RUNTIME_NAME = "java11" })
  tags          = module.context.labels
}
