variable "project_name" {
  description = "Stable repository and platform identifier."
  type        = string
  default     = "platform-delivery-lab"
}

variable "project_version" {
  description = "Version surfaced through Lambda metadata and labels."
  type        = string
  default     = "1.0.0"
}

variable "environment" {
  description = "Deployment environment."
  type        = string
  default     = "local"
}

variable "aws_region" {
  description = "AWS region used by LocalStack."
  type        = string
  default     = "us-east-1"
}

variable "localstack_endpoint" {
  description = "LocalStack edge endpoint."
  type        = string
  default     = "http://127.0.0.1:4566"
}
