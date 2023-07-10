output "account_link" {
  value = format(
    "https://%s.signin.aws.amazon.com/console",
    data.aws_caller_identity.current.account_id,
    )
}

output "alias_account_link" {
  value = format(
    "https://%s.signin.aws.amazon.com/console",
    var.account_alias,
    )
}

output "exampleuser" {
  value = aws_iam_user_login_profile.user["USERNAME@generic.com"].encrypted_password
}
