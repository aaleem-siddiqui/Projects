resource "aws_cognito_user_pool" "pool" {
  name = var.pool_name
  tags = var.tags

  schema {
    name                           = "internal-user"
    attribute_data_type            = "String"
    developer_only_attribute       = false
    mutable                        = true  # false for "sub"
    required                       = false # true for "sub"
    string_attribute_constraints {   # if it is a string
      min_length                   = 1                
      max_length                   = 10             
    }
  }

  email_configuration {
    source_arn            = var.from_email
  }

  auto_verified_attributes = ["email"]

  verification_message_template {
    email_message         = "Your verification code is {####}. "
    email_subject         = "Your verification code"
  }

  sms_authentication_message = "Your authentication code is {####}. "

  password_policy {
    minimum_length                   = 8
    require_lowercase                = true
    require_numbers                  = true
    require_symbols                  = true
    require_uppercase                = true
    temporary_password_validity_days = 7
  }

  admin_create_user_config {
    allow_admin_create_user_only     = false
      invite_message_template {
        email_message = "Your username is {username} and temporary password is {####}. "
        email_subject = "Your temporary password"
        sms_message   = "Your username is {username} and temporary password is {####}. "
    }
  }

  lambda_config {
    pre_sign_up                      = var.pre_sign_up_lambda
    custom_message                   = var.custom_message_lambda
  }

  user_pool_add_ons {
    advanced_security_mode           = "OFF"
  }

  account_recovery_setting {
    recovery_mechanism {
      name                  = "verified_email"
      priority              = 1
    }
  }
}

resource "aws_cognito_user_pool_client" "app_client" {
  name                          = "EXAMPLE_COGNITO_POOL_NAME"
  user_pool_id                  = aws_cognito_user_pool.pool.id

  access_token_validity         = 1
  refresh_token_validity        = 30
  id_token_validity             = 1
  enable_token_revocation       = false

  prevent_user_existence_errors = "LEGACY"
  explicit_auth_flows = [
    "ALLOW_ADMIN_USER_PASSWORD_AUTH",
    "ALLOW_CUSTOM_AUTH",
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_USER_SRP_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH" 
  ]
}