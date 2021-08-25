
locals {
  prefix = "${var.prefix}-%{if terraform.workspace != "default"}${terraform.workspace}-%{else}%{endif}"
}

data "aws_caller_identity" "current" {}

locals {
  target_account = data.aws_caller_identity.current.account_id
  target_region  = var.aws_region
}
