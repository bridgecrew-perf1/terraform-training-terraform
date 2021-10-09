
output "aws_profile" {
  description = "AWS profile used to create resources"
  value       = var.aws_profile
}

output "aws_region" {
  description = "AWS region"
  value       = var.aws_region
}

# output "debug_value" {
#   description = "Debug value"
#   value       = local.trainers_prefixed
# }
