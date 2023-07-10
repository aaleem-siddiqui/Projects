pool_name                                   = "quality_assurance-users"
pre_sign_up_lambda                          = "arn:aws:lambda:us-east-1:account#:function:quality_assurance_generic_portal_cognitoPreSignUp"
custom_message_lambda                       = "arn:aws:lambda:us-east-1:account#:function:quality_assurance_generic_portal_cognitoCustomMessage"
from_email                                  = "arn:aws:ses:us-east-1:account#:identity/team-name@generic.com"
tags = {
  APPLICATION       = "generic"
  COMPONENT         = "COGNITO"
  CREATION          = "JIRA"
  STACK             = "quality_assurance"
  Terraform_managed = "True"
}
