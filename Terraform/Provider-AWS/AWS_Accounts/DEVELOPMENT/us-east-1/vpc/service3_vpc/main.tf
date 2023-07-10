module "aws_vpc" {
  source                              = "../../../../../../modules/aws_vpc"
  stack                               = var.stack
  project                             = var.project
  cidr_block                          = var.cidr_block
  enable_dns_hostnames                = var.enable_dns_hostnames
  enable_dns_support                  = var.enable_dns_support
  dhcp_options_domain_name            = var.dhcp_options_domain_name
  public_subnets                      = var.public_subnets
  example_application_subnets         = var.example_application_subnets
  gateway_loadbalancer_subnets        = var.gateway_loadbalancer_subnets
  //example_database_subnets          = var.example_database_subnets
  //nat_subnets                       = var.nat_subnets
  availability_zone                   = var.availability_zone
  dhcp_options_domain_name_servers    = var.dhcp_options_domain_name_servers
  public_ingress_ports                = var.public_ingress_ports
  local_dns                           = var.local_dns
  main_dns                            = var.main_dns
  tags                                = var.tags
}