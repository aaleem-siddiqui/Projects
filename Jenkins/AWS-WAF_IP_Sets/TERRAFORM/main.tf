/* -------- SOURCED MODULES -------- */
/* -------- DO NOT MODIFY -------- */

###### block-list IP set #######
# GLOBAL
module "waf-block-ipv4-set-global" {
  source          = "../MODULES"
  name            = var.name[0]
  description     = var.description
  scope           = var.scope.CLOUDFRONT
  ip_addr_version = var.ip_addr_version.IPV4
  ip_set          = var.ip_sets.block-list
  providers = {
    aws.provider_alias = aws.WAF-global
  }
}

# US-EAST-1
module "waf-block-ipv4-set-us-east-1" {
  source          = "../MODULES"
  name            = var.name[0]
  description     = var.description
  scope           = var.scope.REGIONAL
  ip_addr_version = var.ip_addr_version.IPV4
  ip_set          = var.ip_sets.block-list
  providers = {
    aws.provider_alias = aws.WAF-us-east-1
  }
}

# US-WEST-2
module "waf-block-ipv4-set-us-west-2" {
  source          = "../MODULES"
  name            = var.name[0]
  description     = var.description
  scope           = var.scope.REGIONAL
  ip_addr_version = var.ip_addr_version.IPV4
  ip_set          = var.ip_sets.block-list
  providers = {
    aws.provider_alias = aws.WAF-us-west-2
  }
}

# EU-WEST-1
module "waf-block-ipv4-set-eu-west-1" {
  source          = "../MODULES"
  name            = var.name[0]
  description     = var.description
  scope           = var.scope.REGIONAL
  ip_addr_version = var.ip_addr_version.IPV4
  ip_set          = var.ip_sets.block-list
  providers = {
    aws.provider_alias = aws.WAF-eu-west-1
  }
}

####### block-list-ipv6 IP set ######
# US-EAST-1
# Global
module "waf-block-ipv6-set-global" {
  source          = "../MODULES"
  name            = var.name[1]
  description     = var.description
  scope           = var.scope.CLOUDFRONT
  ip_addr_version = var.ip_addr_version.IPV6
  ip_set          = var.ip_sets.block-list-ipv6
  providers = {
    aws.provider_alias = aws.WAF-global
  }
}

# US-EAST-1
module "waf-block-ipv6-set-us-east-1" {
  source          = "../MODULES"
  name            = var.name[1]
  description     = var.description
  scope           = var.scope.REGIONAL
  ip_addr_version = var.ip_addr_version.IPV6
  ip_set          = var.ip_sets.block-list-ipv6
  providers = {
    aws.provider_alias = aws.WAF-us-east-1
  }
}

# US-WEST-2
module "waf-block-ipv6-set-us-west-2" {
  source          = "../MODULES"
  name            = var.name[1]
  description     = var.description
  scope           = var.scope.REGIONAL
  ip_addr_version = var.ip_addr_version.IPV6
  ip_set          = var.ip_sets.block-list-ipv6
  providers = {
    aws.provider_alias = aws.WAF-us-west-2
  }
}

# EU-WEST-1
module "waf-block-ipv6-set-eu-west-1" {
  source          = "../MODULES"
  name            = var.name[1]
  description     = var.description
  scope           = var.scope.REGIONAL
  ip_addr_version = var.ip_addr_version.IPV6
  ip_set          = var.ip_sets.block-list-ipv6
  providers = {
    aws.provider_alias = aws.WAF-eu-west-1
  }
}