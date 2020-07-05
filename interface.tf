variable "aws_region" {
  default = "eu-west-1"
}

variable "start_cron" {
  description = "Rate expression for when to run the start RDS lambda"
  default     = "cron(0 7 ? * MON-FRI *)"
}

variable "stop_cron" {
  description = "Rate expression for when to run the stop RDS"
  default     = "cron(0 21 ? * MON-FRI *)"
}

variable "function_prefix" {
  description = "Prefix for the name of the resources created"
  default     = "git"
}

variable "enabled" {
  default     = 1
  description = "Enable that module or not"
}

variable "rds_tag_key" {
  default     = "rds_lambda_scheduled"
  type        = string
  description = "the key of the RDS instance and will be an environment value for the lambda function"
}

variable "rds_tag_value" {
  default     = "onoff"
  type        = string
  description = "the value of the RDS instance and will be an environment value for the lambda function"
}

output "rds_tag_key" {
  value = var.rds_tag_key
}

output "rds_tag_value" {
  value = var.rds_tag_value
}

