
resource "aws_iam_group" "students" {
  name = "${local.prefix}students"
  # path = "/"
}

resource "aws_iam_policy" "student_general" {
  name        = "${local.prefix}student-general"
  path        = "/"
  description = "Set of general rules"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Sid" : "DenyUnapprovedAction",
        "Effect" : "Deny",
        "Action" : [
          "ds:*",
          "iam:CreateUser",
          "cloudtrail:StopLogging",
        ],
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : "ec2:DescribeAccountAttributes",
        "Resource" : "*"
      },
    ]
  })
  tags = merge(var.tags, {})
}

resource "aws_iam_policy" "student_aws_key_pair" {
  name        = "${local.prefix}student-aws-key-pair"
  path        = "/"
  description = "Set of aws_key_pair rules"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Effect" : "Allow",
        "Action" : [
          "ec2:DescribeKeyPairs",
          "ec2:ImportKeyPair",
          "ec2:CreateKeyPair",
          "ec2:DeleteKeyPair",
        ],
        "Resource" : "*",
        # "Resource" : "arn:aws:ec2:eu-central-1:901850860342:*",
        # "Resource" : "arn:aws:ec2:eu-central-1:901850860342:key-pair/*",
      },
      # {
      #   "Effect" : "Allow",
      #   "Action" : [
      #     "iam:DeleteSSHPublicKey",
      #     "iam:GetSSHPublicKey",
      #     "iam:ListSSHPublicKeys",
      #     "iam:UpdateSSHPublicKey",
      #     "iam:UploadSSHPublicKey"
      #   ],
      #   "Resource" : "arn:aws:iam::*:user/$${aws:username}"
      # },
    ]
  })
  tags = merge(var.tags, {})
}

# Based on:
# https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_examples_ec2_securitygroups-vpc.html
resource "aws_iam_policy" "student_aws_security_group" {
  name        = "${local.prefix}student-aws-security-group"
  path        = "/"
  description = "Set of aws_security_group rules"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Effect" : "Allow",
        "Action" : [
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeSecurityGroupRules",
          "ec2:DescribeTags",
          # new rule (-s) comparing with reference above
          "ec2:CreateTags",
        ],
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "ec2:ModifySecurityGroupRules"
        ],
        "Resource" : [
          "arn:aws:ec2:eu-central-1:901850860342:security-group-rule/*"
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "ec2:AuthorizeSecurityGroupIngress",
          "ec2:RevokeSecurityGroupIngress",
          "ec2:AuthorizeSecurityGroupEgress",
          "ec2:RevokeSecurityGroupEgress",
          "ec2:ModifySecurityGroupRules",
          "ec2:UpdateSecurityGroupRuleDescriptionsIngress",
          "ec2:UpdateSecurityGroupRuleDescriptionsEgress",
          # new rule (-s) comparing with reference above
          "ec2:DescribeNetworkInterfaces",
          "ec2:DescribeSecurityGroups",
          "ec2:CreateSecurityGroup",
          "ec2:DeleteSecurityGroup",
        ],
        "Resource" : "arn:aws:ec2:eu-central-1:901850860342:security-group/*",
      },
    ]
  })
  tags = merge(var.tags, {})
}

resource "aws_iam_policy" "student_aws_instance" {
  name        = "${local.prefix}student-aws-instance"
  path        = "/"
  description = "Set of aws_instance rules"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Effect" : "Allow",
        "Action" : [
          "ec2:DescribeInstances",
          "ec2:DescribeInstanceAttribute",
          "ec2:DescribeVpcs",
          "ec2:DescribeTags",
          "ec2:DescribeVolumes",
          "ec2:DescribeKeyPairs",
          "ec2:DescribeInstanceCreditSpecifications",
        ],
        "Resource" : "*",
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "ec2:MonitorInstances",
          "ec2:RebootInstances",
          "ec2:RunInstances",
          "ec2:StartInstances",
          "ec2:StopInstances",
          "ec2:TerminateInstances",
        ],
        # "Resource" : "*",
        "Resource" : [
          "arn:aws:ec2:eu-central-1:901850860342:instance/*",
          "arn:aws:ec2:eu-central-1::image/*",
          "arn:aws:ec2:eu-central-1:901850860342:network-interface/*",
          "arn:aws:ec2:eu-central-1:901850860342:security-group/*",
          "arn:aws:ec2:eu-central-1:901850860342:subnet/*",
          "arn:aws:ec2:eu-central-1:901850860342:volume/*",

          "arn:aws:ec2:eu-central-1:901850860342:vpc/*",
          "arn:aws:ec2:eu-central-1:901850860342:placement-group/*",
          "arn:aws:ec2:eu-central-1:901850860342:capacity-reservation/*",
          "arn:aws:elastic-inference:eu-central-1:901850860342:elastic-inference-accelerator/*",
          "arn:aws:ec2:eu-central-1:901850860342:launch-template/*",
          "arn:aws:ec2:eu-central-1:901850860342:elastic-gpu/*",
          "arn:aws:ec2:eu-central-1:901850860342:key-pair/*",
          "arn:aws:ec2:eu-central-1::snapshot/*"
        ]
      },
    ]
  })
  tags = merge(var.tags, {})
}

resource "aws_iam_group_policy_attachment" "users_attach_policy_student_general" {
  group      = aws_iam_group.students.name
  policy_arn = aws_iam_policy.student_general.arn
}

resource "aws_iam_group_policy_attachment" "users_attach_policy_student_aws_key_pair" {
  group      = aws_iam_group.students.name
  policy_arn = aws_iam_policy.student_aws_key_pair.arn
}

resource "aws_iam_group_policy_attachment" "users_attach_policy_student_aws_security_group" {
  group      = aws_iam_group.students.name
  policy_arn = aws_iam_policy.student_aws_security_group.arn
}

resource "aws_iam_group_policy_attachment" "users_attach_policy_student_aws_instance" {
  group      = aws_iam_group.students.name
  policy_arn = aws_iam_policy.student_aws_instance.arn
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

# https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_passwords_account-policy.html#default-policy-details
resource "random_password" "student" {
  for_each = toset(local.students)

  length           = 8
  override_special = "_-"
  min_upper        = 1
  min_lower        = 1
  min_numeric      = 1
  min_special      = 1
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

