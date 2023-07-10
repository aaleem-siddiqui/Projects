output "generic_vpc_id" {
  description = "sg with full internal access"
  value       = module.aws_vpc.generic_vpc_id
}

output "generic_public_subnet_id" {
  description = "public subnet ids"
  value       = module.aws_vpc.generic_public_subnet_id
}
output "generic_example_application_subnet_id" {
  description = "app private subnet ids"
  value       = module.aws_vpc.generic_example_application_subnet_id
}
output "generic_gateway_loadbalancer_subnet_id" {
  description = "gateway_loadbalancer private subnet ids"
  value       = module.aws_vpc.generic_gateway_loadbalancer_subnet_id
}
/*output "generic_example_db_subnet_id" {
  description = "db private subnet ids"
  value       = module.aws_vpc.generic_example_db_subnet_id
}
output "generic_nat_subnet_id" {
  description = "nat private subnet ids"
  value       = module.aws_vpc.generic_nat_subnet_id
}*/
output "security_group_generic_internal_all_id" {
  description = "sg with full internal access"
  value       = module.aws_vpc.security_group_generic_internal_all_id
}

output "security_group_public_applicationLoadBalancer_id" {
  description = "sg public applicationLoadBalancer access"
  value       = module.aws_vpc.security_group_public_applicationLoadBalancer_id
}

output "generic_ssh_key" {
  description = "ssh key name"
  value = module.aws_vpc.generic_ssh_key
}

output "ebs_key_arn" {
  description = "KMS key ARN for ebs encryption"
  value = module.aws_vpc.ebs_key_arn
}

output "s3_bucket_id" {
  description = "s3 bucket name"
  value = module.aws_vpc.s3_bucket_id
}

output "s3_bucket_domain_name" {
  description = "s3 bucket domain name"
  value = module.aws_vpc.s3_bucket_domain_name
}
output "upload_command" {
  value = module.aws_vpc.upload_command
}

output "route53_zone_id" {
  description = "private zone id"
  value = module.aws_vpc.route53_zone_id
}