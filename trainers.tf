
resource "aws_iam_group" "trainers" {
  name = "${local.prefix}trainers"
  # path = "/"
}

data "aws_iam_policy" "AdministratorAccess" {
  arn  = "arn:aws:iam::aws:policy/AdministratorAccess"
  tags = merge(var.tags, {})
}

# Attach the policy to the group
resource "aws_iam_group_policy_attachment" "trainers_attach_policy_AdministratorAccess" {
  group      = aws_iam_group.trainers.name
  policy_arn = data.aws_iam_policy.AdministratorAccess.arn
}

resource "aws_iam_user" "trainer" {
  for_each = toset(local.trainers)

  name          = local.trainers_prefixed[each.key]
  force_destroy = true
  tags          = merge(var.tags, {})
  # path          = each.value["path"]
}

resource "aws_iam_access_key" "trainer" {
  for_each = toset(local.trainers)

  user = aws_iam_user.trainer[each.value].name
}

resource "aws_iam_user_group_membership" "trainer" {
  for_each = toset(local.trainers)

  user = local.trainers_prefixed[each.key]
  groups = [
    aws_iam_group.trainers.name,
  ]
}

# https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_passwords_account-policy.html#default-policy-details
resource "random_password" "trainer" {
  for_each = toset(local.trainers)

  length           = 8
  override_special = "_"
  min_upper        = 1
  min_lower        = 1
  min_numeric      = 1
  min_special      = 1
}

resource "null_resource" "trainer-login-profile" {
  for_each = toset(local.trainers)
  depends_on = [
    aws_iam_user.trainer
  ]

  triggers = {
    aws_profile = var.aws_profile
    user_name   = local.trainers_prefixed[each.key]
  }

  provisioner "local-exec" {
    when       = create
    on_failure = fail
    command    = "aws --profile ${self.triggers.aws_profile} iam create-login-profile --user-name ${self.triggers.user_name} --password ${random_password.trainer[each.key].result} --no-password-reset-required"
  }

  provisioner "local-exec" {
    when       = destroy
    on_failure = continue
    command    = "aws --profile ${self.triggers.aws_profile} iam delete-login-profile --user-name ${self.triggers.user_name}"
  }
}
