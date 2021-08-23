
resource "aws_iam_group" "users" {
  name = "${local.prefix}users"
  # path = "/"
}

resource "aws_iam_policy" "user" {
  name        = "${local.prefix}user-policy"
  path        = "/"
  description = "Permissions for students"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "eks:DescribeNodegroup",
          "eks:ListNodegroups",
          "eks:DescribeCluster",
          "eks:ListClusters",
          "eks:AccessKubernetesApi",
          "ssm:GetParameter",
          "eks:ListUpdates",
          "eks:ListFargateProfiles"
        ]
        Effect = "Allow"
        # TODO: restrict access more
        Resource = "*"
      },
    ]
  })
  tags = merge(var.tags, {})
}

resource "aws_iam_group_policy_attachment" "users_attach_policy_UserPolicy" {
  group      = aws_iam_group.users.name
  policy_arn = aws_iam_policy.user.arn
}

resource "aws_iam_user" "user" {
  for_each = toset(local.users)

  name          = local.users_prefixed[each.key]
  force_destroy = true
  tags          = merge(var.tags, {})
  # path          = each.value["path"]
}

resource "aws_iam_access_key" "user" {
  for_each = toset(local.users)

  user = aws_iam_user.user[each.value].name
}

resource "aws_iam_user_group_membership" "user" {
  for_each = toset(local.users)

  user = local.users_prefixed[each.key]
  groups = [
    aws_iam_group.users.name,
  ]
}

resource "random_password" "user" {
  for_each = toset(local.users)

  length  = 8
  special = false
}

resource "null_resource" "user-login-profile" {
  for_each = toset(local.users)
  depends_on = [
    aws_iam_user.user
  ]

  triggers = {
    aws_profile = var.aws_profile
    user_name   = local.users_prefixed[each.key]
  }

  provisioner "local-exec" {
    when       = create
    on_failure = fail
    command    = "aws --profile ${self.triggers.aws_profile} iam create-login-profile --user-name ${self.triggers.user_name} --password ${random_password.user[each.key].result} --no-password-reset-required"
  }

  provisioner "local-exec" {
    when       = destroy
    on_failure = continue
    command    = "aws --profile ${self.triggers.aws_profile} iam delete-login-profile --user-name ${self.triggers.user_name}"
  }
}

