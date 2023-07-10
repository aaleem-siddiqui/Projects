project                                         = "GENERIC"
stack                                           = "quality_assurance"
cluster_revision                                = "service1"
ecs_cluster__ec2_instance_type                  = "c6a.2xlarge"
ecs_cluster__ec2_min_count                      = 2
ecs_cluster__ec2_max_count                      = 6
ecs_cluster__ec2_desired_count                  = 2
ecs_cluster__on_demand_percentage               = 25
ecs_cluster__scaling_by_mem_and_cpu             = true
ecs_cluster__security_software_code             = "XXXXXXXXXXXXXX"
ecs_cluster__security_software_sensor_kit       = "security_software.tar"
ecs_cluster__FW_user                            = ""
ecs_cluster__FW_pass                            = ""
ecs_cluster__FW_consoleauth                     = "https://us-east1.cloud.example.com/api/v1/authenticate"
ecs_cluster__FW_token                           = ""
ecs_cluster__FW_defender_secret_arn             = "arn:aws:secretsmanager:us-east-1:account#:secret:FW_cloud_defender_installation_credentials"
ecs_cluster__FW_defender_kms_arn                = "arn:aws:kms:us-east-1:account#:key/key_id"
ecs_cluster__ecs_region                         = "us-east-1"
ecs_cluster__ec2_subnet_id                      = ["subnet-example","subnet-example"]
ecs_cluster__ec2_security_groups                = ["sg-example"]
ecs_cluster__ec2_ssh_key_name                   = "generic_ssh_key_name"
ecs_cluster__available_ec2_types = [
"c6a.2xlarge",
"c5a.2xlarge",
"c5.2xlarge"
]
tags = {
  APPLICATION       = "GENERIC"
  COMPONENT         = "ECS"
  CUSTOMER          = "GENERIC Inc."
  CREATION          = "JIRA"
  ENVIRONMENT       = "quality_assurance"
  MICROSERVICE      = "service1"
}
