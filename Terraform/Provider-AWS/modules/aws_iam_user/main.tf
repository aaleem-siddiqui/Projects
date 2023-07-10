resource "aws_iam_group" "group" {
  name = var.group_name
}

resource "aws_iam_group_policy_attachment" "policy_attach" {
  for_each                = toset(var.list_of_policys)
  group                   = aws_iam_group.group.name
  policy_arn              = format(
    "arn:aws:iam::aws:policy/%s",
    each.value
    )
}

resource "aws_iam_user" "users" {
  for_each                = toset(var.list_of_users)
  name                    = each.value
  path                    = "/"
  force_destroy           = true
}

resource "aws_iam_access_key" "users" {
  for_each                = toset(var.list_of_users)
  user                    = each.value
  pgp_key                 = format(
    "keybase:%s",
    var.keybase_user
  )
  depends_on              = [
    aws_iam_user.users
  ]
}

resource "aws_iam_user_group_membership" "group_members" {
    for_each              = toset(var.list_of_users)
  user                    = each.value
  groups                  = [
    aws_iam_group.group.name
  ]
  depends_on              = [
    aws_iam_user.users
  ]
}
