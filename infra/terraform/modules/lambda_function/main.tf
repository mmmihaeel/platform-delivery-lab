resource "aws_lambda_function" "this" {
  function_name    = var.function_name
  description      = var.description
  filename         = var.filename
  handler          = var.handler
  runtime          = var.runtime
  role             = var.role_arn
  architectures    = var.architectures
  source_code_hash = filebase64sha256(var.filename)
  memory_size      = var.memory_size
  timeout          = var.timeout
  tags             = var.tags

  environment {
    variables = var.environment
  }
}

resource "aws_cloudwatch_log_group" "this" {
  name              = "/aws/lambda/${var.function_name}"
  retention_in_days = 7
  tags              = var.tags
}
