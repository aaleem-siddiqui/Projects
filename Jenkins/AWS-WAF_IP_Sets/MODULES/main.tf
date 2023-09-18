/* -------- MAIN SOURCE -------- */
/* -------- DO NOT MODIFY -------- */

terraform {
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      configuration_aliases = [aws.provider_alias]
    }
  }
}

resource "aws_wafv2_ip_set" "ip-set" {
  provider           = aws.provider_alias
  name               = var.name
  description        = var.description
  scope              = var.scope
  ip_address_version = var.ip_addr_version
  addresses          = var.ip_set
}