variable "aws_region" {
  type        = string
  default     = "us-east-1"
  description = "AWS region to deploy into"
}

variable "project_name" {
  type        = string
  default     = "budget-alerts"
  description = "Prefix for resource names and the Project tag"
}

variable "alert_email" {
  type        = string
  description = "Email address that receives budget alerts"

  validation {
    condition     = can(regex("^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$", var.alert_email))
    error_message = "alert_email must be a valid email address."
  }
}

variable "monthly_budget_usd" {
  type        = number
  default     = 5
  description = "Monthly spending limit in US dollars. Alerts fire as a percentage of this amount"

  validation {
    condition     = var.monthly_budget_usd > 0
    error_message = "monthly_budget_usd must be greater than 0."
  }
}