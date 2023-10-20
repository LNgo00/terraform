provider "aws" {
  region = "eu-west-1"
}

variable "users_list" {
  description = "number of user IAM"
  type = number
}

variable "users_set" {
  description = "values of user IAM"
  type = set(string)
}

resource "aws_iam_user" "users_list" {
  count = var.users_list
  name = "user.${count.index}"
}

resource "aws_iam_user" "users_set" {
  for_each = var.users_set

  name = "user_${each.value}"
}

output "arn_user" {
  description = "ARN user 2 (position 1)"
  value = aws_iam_user.users_list[1].arn
}

output "arn_all_users_from_users_list" {
  description = "ARN all users from list"

  value = [for user in aws_iam_user.users_list : user.arn]
}

output "arn_all_users_from_users_set" {
  description = "ARN all users from set"

  value = [for user in aws_iam_user.users_set : user.arn]
}

output "name_all_users"{
  description = "Name all users"
  value = [for user in aws_iam_user.users_list : user.name]
}

output "arn_all_user_from_set_and_list" {
  description = "ARN all users from set and list"

  value = concat(
    aws_iam_user.users_list[*].arn,
    [for user in aws_iam_user.users_set : user.arn]
  )
}