
Перед:
- обновить теги создателя

Во время тренинга, в конце дня/выходные:
- деактивируем ключи
- останавливаем ec2

После тренинга:
- зачистить
  - ключи
  - security group
  - ec2 + диски
  - s3 backets
  - с ручным подтверждением

# Troubleshooting

## Profile name in remote state

Use the same AWS profile for different admins. It is needed to delete accounts using AWS CLI.

Thus it keeps in triggers:

```text
# null_resource.trainer-login-profile["trainer"] will be created
+ resource "null_resource" "trainer-login-profile" {
    + id       = (known after apply)
    + triggers = {
        + "aws_profile" = "terraform-msuslov"
        + "user_name"   = "kube-trainer"
      }
  }
```
