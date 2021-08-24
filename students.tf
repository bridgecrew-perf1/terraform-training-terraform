
resource "aws_iam_group" "students" {
  name = "${local.prefix}students"
  # path = "/"
}

resource "aws_iam_policy" "student" {
  name        = "${local.prefix}student-policy"
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

resource "aws_iam_group_policy_attachment" "users_attach_policy_StudentPolicy" {
  group      = aws_iam_group.students.name
  policy_arn = aws_iam_policy.student.arn
}

resource "aws_iam_user" "student" {
  for_each = toset(local.students)

  name          = local.students_prefixed[each.key]
  force_destroy = true
  tags          = merge(var.tags, {})
  # path          = each.value["path"]
}

resource "aws_iam_access_key" "student" {
  for_each = toset(local.students)

  user = aws_iam_user.student[each.value].name
}

resource "aws_iam_user_group_membership" "student" {
  for_each = toset(local.students)

  user = local.students_prefixed[each.key]
  groups = [
    aws_iam_group.students.name,
  ]
}

resource "random_password" "student" {
  for_each = toset(local.students)

  length  = 8
  special = false
}

resource "null_resource" "student-login-profile" {
  for_each = toset(local.students)
  depends_on = [
    aws_iam_user.student
  ]

  triggers = {
    aws_profile = var.aws_profile
    user_name   = local.students_prefixed[each.key]
  }

  provisioner "local-exec" {
    when       = create
    on_failure = fail
    command    = "aws --profile ${self.triggers.aws_profile} iam create-login-profile --user-name ${self.triggers.user_name} --password ${random_password.student[each.key].result} --no-password-reset-required"
  }

  provisioner "local-exec" {
    when       = destroy
    on_failure = continue
    command    = "aws --profile ${self.triggers.aws_profile} iam delete-login-profile --user-name ${self.triggers.user_name}"
  }
}

