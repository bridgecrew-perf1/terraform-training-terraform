locals {
  trainers_raw = [
    for line in split("\n", file("${path.module}/data/trainers.txt")) :
    trimspace(line)
  ]

  trainers = [
    for line in local.trainers_raw :
    line if length(line) > 0 && substr(line, 0, 1) != "#"
  ]

  trainers_prefixed = {
    for trainer in local.trainers :
    trainer => "${local.prefix}${trainer}"
  }

  users_raw = [
    for line in split("\n", file("${path.module}/data/users.txt")) :
    trimspace(line)
  ]

  users = [
    for line in local.users_raw :
    line if length(line) > 0 && substr(line, 0, 1) != "#"
  ]

  users_prefixed = {
    for user in local.users :
    user => "${local.prefix}${user}"
  }
}
