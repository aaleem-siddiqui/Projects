data "aws_caller_identity" "current" {}

resource "aws_iam_account_alias" "alias" {
  account_alias                  = var.account_alias
}

resource "aws_iam_account_password_policy" "strict" {
  minimum_password_length        = 8
  max_password_age               = 90
  password_reuse_prevention      = 3
  require_lowercase_characters   = true
  require_numbers                = true
  require_uppercase_characters   = true
  require_symbols                = true
  allow_users_to_change_password = true
}

resource "aws_iam_group" "admin_group" {
  name = var.admin_group_name
}

resource "aws_iam_group_policy_attachment" "admin_policy_attach" {
  group      = aws_iam_group.admin_group.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_user" "user" {
  for_each                = toset(var.admin_users)
  name                    = each.value
  path                    = "/"
  force_destroy           = true
}

resource "aws_iam_user_login_profile" "user" {
  for_each                = toset(var.admin_users)
  user                    = each.value
  password_length         = 12
  password_reset_required = true
  pgp_key                 = format(
    "keybase:%s",
    var.keybase_user
  )
  depends_on              = [
    aws_iam_user.user
  ]
}

resource "aws_iam_user_group_membership" "group_members" {
  for_each                = toset(var.admin_users)
  user                    = each.value
  groups                  = [
    aws_iam_group.admin_group.name
  ]
  depends_on              = [
    aws_iam_user.user
  ]
}
