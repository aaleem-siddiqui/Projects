variable "project" {
  type = string
}
variable "stack" {
  type = string
  description = "Put stack name here."
}
variable "cluster_revision" {
  type = string
  description = "Revision of Cluster"
}
variable "ecs_cluster__ec2_instance_type" {
  type        = string
  description = "EC2 Instance Type for ECS Cluster; see LaunchTemplate.LaunchTemplateData.InstanceType"
}
variable "ecs_cluster__ecs_region" {
  type        = string
  description = "Default Region"
}
variable "ecs_cluster__ec2_max_count" {
  type        = number
  description = "Max number of EC2 instances in ECS Cluster; see AutoScalingGroup.MaxSize"
}
variable "ecs_cluster__ec2_min_count" {
  type        = number
  description = "Min number of EC2 instances in ECS Cluster; see AutoScalingGroup.MinSize"
}
variable "ecs_cluster__ec2_desired_count" {
  type        = number
  description = "Desired number of EC2 instances in ECS Cluster; see AutoScalingGroup.DesiredSize"
}
variable "ecs_cluster__security_software_code" {
  type = string
  description = "security software company code"
}
variable "ecs_cluster__security_software_sensor_kit" {
  type = string
  description = "security software Sensor Kit Version"
}
variable "ecs_cluster__FW_user" {
  type = string
  description = "FW Cloud Deployment User Access ID"
}
variable "ecs_cluster__FW_pass" {
  type = string
  description = "FW Cloud Deployment Secret ID"
}
variable "ecs_cluster__FW_consoleauth" {
  type = string
  description = "URL needed for Token Authentication"
}
variable "ecs_cluster__FW_token" {
  type = string
  description = "TOKEN created for Installing FW Defender after Authentication"
}
variable "ecs_cluster__FW_defender_secret_arn" {
  type = string
  description = "ARN of Secret ID for FW Cloud Access Credentials"
}
variable "ecs_cluster__FW_defender_kms_arn" {
  type = string
  description = "KMS ARN to decrypt secret"
}
variable "ecs_cluster__on_demand_percentage" {
  type = number
  description = "Number of persents of on demand instances to use, default 0 means 100% spot will be used"
}
variable "ecs_cluster__scaling_by_mem_and_cpu" {
  type = bool
  description = "This is used to decide if the cluster is scaling by only memory, or memory AND cpu usage"
  default = "false"
}
variable "ecs_cluster__available_ec2_types" {
  type = list(string)
  description = "list of available instances type to use as spot"
}
variable "ecs_cluster__ec2_ssh_key_name" {
  type = string
  description = "Key Name for instance"
}
variable "ecs_cluster__ec2_subnet_id" {
  type = set(string)
  description = "subnet id"
}
variable "ecs_cluster__ec2_security_groups" {
  type = set(string)
  description = "ec2 security groups"
}
variable "tags" {
  type = map(any)
}
