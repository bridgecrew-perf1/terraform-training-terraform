
variable "aws_region" {
  type        = string
  description = "AWS region for cluster"
  default     = "eu-central-1"
}

variable "aws_profile" {
  type        = string
  description = "AWS profile to create training resources"
  default     = "default"
}

variable "prefix" {
  type        = string
  description = "Training prefix for resources"
  default     = "terraform"
}

variable "tags" {
  description = "A map of tags to add to all resources."
  type        = map(string)
  default = {
    training = "adm-025 terraform"
    creator  = "maxim.suslov@dxc.com"
  }
}

variable "pause_training" {
  type        = bool
  description = "True to suspend and free resources"
  default     = false
}
