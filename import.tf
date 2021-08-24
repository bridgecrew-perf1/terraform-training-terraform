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

  students_raw = [
    for line in split("\n", file("${path.module}/data/students.txt")) :
    trimspace(line)
  ]

  students = [
    for line in local.students_raw :
    line if length(line) > 0 && substr(line, 0, 1) != "#"
  ]

  students_prefixed = {
    for student in local.students :
    student => "${local.prefix}${student}"
  }
}
