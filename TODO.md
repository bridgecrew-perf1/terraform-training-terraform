1 student = 1 AWS account
permissions are in policy
- policy для создания ключей
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "CreateAccessKey",
            "Effect": "Allow",
            "Action": [
                "iam:DeleteAccessKey",
                "iam:GetAccessKeyLastUsed",
                "iam:UpdateAccessKey",
                "iam:CreateAccessKey",
                "iam:ListAccessKeys"
            ],
            "Resource": "arn:aws:iam::*:user/${aws:username}"
        }
    ]
}


region restricted:
- create organization
- policy:
aws:RequestedRegion


в master:
- создать organization unit

1) create OU (in master account)
2) put all students' accounts
3) attach SCP=service control policy= policies to OU


по регионам ограничение в
https://docs.aws.amazon.com/organizations/latest/userguide/orgs_manage_policies_scps_examples_general.html


https://docs.aws.amazon.com/organizations/latest/userguide/orgs_manage_policies_scps_examples_ec2.html




TODO:
проверить что студенты не могут делать лишнее
ограничить регион https://aws.amazon.com/blogs/security/easier-way-to-control-access-to-aws-regions-using-iam-policies/
по сервисам через политики
по типу инстансу - политику
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "RequireMicroInstanceType",
      "Effect": "Deny",
      "Action": "ec2:RunInstances",
      "Resource": [
        "arn:aws:ec2:*:*:instance/*"
      ],
      "Condition": {
        "ForAnyValue:StringNotEquals": {
          "ec2:InstanceType": [
            "t2.micro",
            "t2.nano",
            "t2.small"
          ]
        }
      }
    }
  ]
} - это SCPolicy
проверить на машине большего размера

? что если две политики перекрываются
- permissive (более строгая)

квоты не более 10 машин на пользователя, например
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Deny",
            "Action": "ec2:RunInstances",
            "Resource": "*",
            "Condition": {
                "ForAnyValue:StringNotEquals": {
                    "ec2:InstanceType": [
                        "t2.micro",
                        "t2.nano"
                    ]
                }
            }
        }
    ]
}
q: quotas < 10 (runnning?) instances


для курса нужно работать в консоли
нужно зайти в консоль
от Димы:
resource "aws_iam_user" "adm-025-student" {
  name = "student-adm-025"
  tags = merge(var.tags, {"root_profile": var.aws-profile-name})

  provisioner "local-exec" {
    command = "aws iam create-login-profile --profile ${var.aws-profile-name} --user-name ${aws_iam_user.adm-025-student.name} --password ${random_string.temp-password.result}"
    on_failure = fail
  }
  provisioner "local-exec" {
    when = destroy
    command = "aws iam delete-login-profile --profile ${self.tags.root_profile} --user-name ${self.name}"
    on_failure = continue
  }
}



как вычистят
деньги
- инвентаризация
- billing panel
