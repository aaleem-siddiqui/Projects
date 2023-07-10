output "generic_vpc_id" {
  description = "sg with full internal access"
  value       = aws_vpc.generic.id
}
output "generic_public_subnet_id" {
  description = "public subnet ids"
  value       = aws_subnet.public.*.id
}
output "generic_gateway_loadbalancer_subnet_id" {
  description = "gateway_loadbalancer subnet ids"
  value       = aws_subnet.gateway_loadbalancer.*.id
}
/*
output "generic_example_database_subnet_id" {
  description = "example_database private subnet ids"
  value       = aws_subnet.example_database.*.id
}
output "generic_nat_subnet_id" {
  description = "nat private subnet ids"
  value       = aws_subnet.nat.*.id
}*/
output "generic_example_application_subnet_id" {
  description = "example_application private subnet ids"
  value       = aws_subnet.example_application.*.id
}
output "security_group_generic_internal_all_id" {
  description = "sg with full internal access"
  value       = aws_security_group.generic_internal_all.id
}

output "security_group_public_applicationLoadBalancer_id" {
  description = "sg public applicationLoadBalancer access"
  value       = aws_security_group.public_applicationLoadBalancer.id
}

output "generic_ssh_key" {
  description = "ssh key name"
  value = aws_key_pair.generic.key_name
}

output "ebs_key_arn" {
  description = "KMS key ARN for ebs encryption"
  value = aws_kms_key.custom_ebs_key.arn
}

output "s3_bucket_id" {
  description = "s3 bucket name"
  value = aws_s3_bucket.generic_bucket.*.id
}

output "s3_bucket_domain_name" {
  description = "s3 bucket domain name"
  value = aws_s3_bucket.generic_bucket.*.bucket_domain_name
}
output "upload_command" {
  value = "aws s3 cp ${aws_key_pair.generic.key_name}.pem s3://generic.local/pems/${aws_key_pair.generic.key_name}.pem --profile aws_profile"
}

output "route53_zone_id" {
  description = "private zone id"
  value = aws_route53_zone.private.*.zone_id
}