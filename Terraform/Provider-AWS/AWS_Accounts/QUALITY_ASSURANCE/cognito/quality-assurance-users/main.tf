module "ecs_cluster" {
  source                     = "../../../../../modules/aws_cognito"
  pool_name                  = var.pool_name
  pre_sign_up_lambda         = var.pre_sign_up_lambda
  custom_message_lambda      = var.custom_message_lambda
  from_email                 = var.from_email
  tags                       = var.tags
}
