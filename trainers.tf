
resource "aws_iam_group" "trainers" {
  name = "${local.prefix}trainers"
  # path = "/"
}

data "aws_iam_policy" "AdministratorAccess" {
  arn  = "arn:aws:iam::aws:policy/AdministratorAccess"
  tags = merge(var.tags, {})
}

data "aws_iam_policy" "AmazonEKSClusterPolicy" {
  arn  = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  tags = merge(var.tags, {})
}

resource "aws_iam_policy" "trainer" {
  name        = "${local.prefix}trainer-policy"
  path        = "/"
  description = "Permissions for trainers"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : "eks:*",
        "Effect" : "Allow",
        # TODO: restrict access more
        # "Resource" : [
        #   # "arn:aws:eks:*:901850860342:fargateprofile/*/*/*",
        #   "arn:aws:eks:eu-central-1:901850860342:fargateprofile/*/*/*",
        #   "arn:aws:eks:eu-central-1:901850860342:identityproviderconfig/kube-training/*/*/*",
        #   "arn:aws:eks:eu-central-1:901850860342:addon/kube-training/*/*",
        #   "arn:aws:eks:eu-central-1:901850860342:cluster/*",
        #   "arn:aws:eks:eu-central-1:901850860342:nodegroup/kube/*/*"
        # ]
        Resource = "*",
      }
    ]
  })
  tags = merge(var.tags, {})
}

# Attach the policy to the group
resource "aws_iam_group_policy_attachment" "trainers_attach_policy_AdministratorAccess" {
  group      = aws_iam_group.trainers.name
  policy_arn = data.aws_iam_policy.AdministratorAccess.arn
}

resource "aws_iam_group_policy_attachment" "trainers_attach_policy_AmazonEKSClusterPolicy" {
  group      = aws_iam_group.trainers.name
  policy_arn = data.aws_iam_policy.AmazonEKSClusterPolicy.arn
}

resource "aws_iam_group_policy_attachment" "trainers_attach_policy_TrainerPolicy" {
  group      = aws_iam_group.trainers.name
  policy_arn = aws_iam_policy.trainer.arn
}

resource "aws_iam_user" "trainer" {
  for_each = toset(local.trainers)

  name = "${local.prefix}${each.key}"
  # path          = each.value["path"]
  force_destroy = true
  tags          = merge(var.tags, {})
}

resource "aws_iam_access_key" "trainer" {
  for_each = toset(local.trainers)

  user = aws_iam_user.trainer[each.value].name
}

resource "aws_iam_user_group_membership" "trainer" {
  for_each = toset(local.trainers)

  user = "${local.prefix}${each.key}"
  groups = [
    aws_iam_group.trainers.name,
  ]
}
