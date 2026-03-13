variable "project_name" {
  description = "Stable repository and platform identifier."
  type        = string
}

variable "environment" {
  description = "Environment name used in labels and naming."
  type        = string
}

variable "project_version" {
  description = "Platform release version surfaced in labels."
  type        = string
}
