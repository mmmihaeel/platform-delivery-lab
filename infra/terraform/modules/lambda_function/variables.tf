variable "function_name" {
  description = "Lambda function name."
  type        = string
}

variable "description" {
  description = "Lambda function description."
  type        = string
}

variable "filename" {
  description = "Path to the Lambda deployment package."
  type        = string
}

variable "handler" {
  description = "Lambda handler entrypoint."
  type        = string
}

variable "runtime" {
  description = "Lambda runtime identifier."
  type        = string
}

variable "role_arn" {
  description = "IAM role ARN assumed by the Lambda function."
  type        = string
}

variable "architectures" {
  description = "CPU architectures supported by the function."
  type        = list(string)
  default     = ["x86_64"]
}

variable "environment" {
  description = "Environment variables passed to the function."
  type        = map(string)
  default     = {}
}

variable "memory_size" {
  description = "Memory allocation in MB."
  type        = number
  default     = 128
}

variable "timeout" {
  description = "Function timeout in seconds."
  type        = number
  default     = 10
}

variable "tags" {
  description = "Tags applied to the function."
  type        = map(string)
  default     = {}
}
