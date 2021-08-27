


[ ] remote state
Егор: нужен бакет для хранения состояния terraform
+ добавить права на запись
https://servicedesk.luxoft.com/browse/SD-2107441

[ ] квоты не более 10 машин на пользователя, например
quotas < 10 (runnning?) instances


[ ] как вычищять?
деньги
- инвентаризация
- billing panel
Каждый курс запускаются в рамках одного аккаунта = просто удалять ресурсы
(пока не горит автоудаление)
после тренинга можно
- используем префиксы
- использовать теги (не все ресурсы имеют, студентам сложнее создавать ресурсы)


c:\Work\TC\Trainings\My\terraform\dubovitsky\adm-025\terraform\m1>terraform apply
╷
│ Error: Output refers to sensitive values
│
│   on call-module.tf line 16:
│   16: output "ssh-key" {
│
│ To reduce the risk of accidentally exporting sensitive data that was intended to be only internal, Terraform requires that any root module output containing sensitive data be explicitly marked as sensitive,
│ to confirm your intent.
│
│ If you do intend to export this data, annotate the output value as sensitive by adding the following argument:
│     sensitive = true


c:\Work\TC\Trainings\My\terraform\dubovitsky\adm-025\terraform\providers1>terraform apply
╷
│ Warning: Quoted references are deprecated
│
│   on aws-providers.tf line 22, in resource "null_resource" "second-provider-usage-example":
│   22:   provider = "aws.frankfurt-node"
│
│ In this context, references are expected literally rather than in quotes. Terraform 0.11 and earlier required quotes, but quoted references are now deprecated and will be removed in a future version of
│ Terraform. Remove the quotes surrounding this reference to silence this warning.
╵
╷
│ Error: Invalid resource type
│
│   on aws-providers.tf line 21, in resource "null_resource" "second-provider-usage-example":
│   21: resource "null_resource" "second-provider-usage-example" {
│
│ The provider hashicorp/aws does not support resource type "null_resource".


remote-state1


[ ] есть ограничение на 6,144 знаков для политики -> разбить на несколько по регионам / for_each
пока не вылезли
> Для управляемых политик: для пользователя, роли или группы можно добавлять до 10 управляемых политик. Размер каждой управляемой политики не может превышать 6144 символов.
https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies_managed-vs-inline.html

[x] репозиторий на github
- Егор Urocukidodzi
- Dima sadon

[x] Пока используем переменные `${local.target_region}:${local.target_account}` для указания региона и аккаунта.
Если потребуется несколько регионов, то
1) можно использовать condition
  https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_variables.html
2) использовать formatlist (менее предпочтительно):
formatlist(
      "arn:aws:ec2:%s:${local.target_account}:key-pair/*",
      var.target_regions,
    )

[x] дать тренеру права Administrator

[x] проверить что студенты не могут делать лишнее
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

[x] по регионам ограничение в
https://docs.aws.amazon.com/organizations/latest/userguide/orgs_manage_policies_scps_examples_general.html

[x] для курса нужно работать в консоли
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


[Не нужно] - работаем без организации:
  region restricted:
  - create organization
  - policy:
  aws:RequestedRegion

  1) create OU (in master account)
  2) put all students' accounts
  3) attach SCP=service control policy= policies to OU

[Не нужно]
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
