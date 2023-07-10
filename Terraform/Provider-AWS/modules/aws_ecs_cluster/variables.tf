variable "project" {
  type = string
  default = "null"
}

variable "stack" {
  type = string
  default = "QUALITY_ASSURANCE"
  description = "Stack Name"
}

variable "cluster_revision" {
  type = string
  description = "Revision of Cluster"
}

variable "ecs_region" {
  type = string
  description = "Default Region"
}

variable "ec2_subnets" {
  type = set(string)
  description = "Subnet to launch ec2 instance to host cluster"
}

variable "ec2_security_groups" {
  type = set(string)
  description = "security groups for cluster host EC2 to live in"
}

variable "ec2_ssh_key_name" {
  type = string
  description = "ssh key for host EC2 instance"
}

variable "ec2_instance_type" {
  type = string
  description = "Instance type for cluster hosting EC2 instance"
}

variable "ec2_max_count" {
  type = number
  description = "Max number of host instances"
  default = 1
}

variable "ec2_min_count" {
  type = number
  description = "Minimal number of host EC2 instances"
  default = 1
}

variable "ec2_desired_count" {
  type = number
  description = "Desired number of host EC2 instances"
  default = 1
}

variable "on_demand_percentage" {
  type = number
  description = "Percentage of preset instances to use"
  default = 100
}

variable "scaling_by_mem_and_cpu" {
  type = bool
  description = "This is used to decide if the cluster is scaling by only memory, or memory AND cpu usage"
  default = "true"
}

variable "volume_size" {
  type = number
  description = "Size of host EC2 volume in GB"
  default = 30
}

variable "volume_type" {
  type = string
  description = "Host EC2 instnce volume type"
  default = "gp3"
}
variable "encrypted" {
  type = bool
  description = "Enables EBS encryption on the volume"
  default = false
}
variable "kms_key_id" {
  type = string
  description = "The ARN of the AWS Key Management Service (AWS KMS) customer master key (CMK) to use when creating the encrypted volume. encrypted must be set to true when this is set."
  default = null
}
variable "security_software_code" {
  type = string
  description = "security software company code"
  default = "XXXXXXXXXXXXXXXX"
}
variable "security_software_sensor_kit" {
  type = string
  description = "security software sensor kit"
  default = "security_software.tar"
}
variable "FW_user" {
  type = string
  description = "FW Cloud Deployment User Access ID"
  default = "XXXXXXXXXXXXXXXX"
}
variable "FW_pass" {
  type = string
  description = "FW Cloud Deployment Secret ID"
  default = "XXXXXXXXXXXXXXXX"
}
variable "FW_consoleauth" {
  type = string
  description = "URL needed for Token Authentication"
  default = "https://us-east1.cloud.example.com/api/v1/authenticate"
}
variable "FW_token" {
  type = string
  description = "TOKEN created for Installing FW Defender after Authentication.  Real one is generated as instances launch"
  default = ""
}
variable "FW_defender_secret_arn" {
  type = string
  description = "ARN of Secret ID for FW Cloud Access Credentials"
  default = "arn:aws:secretsmanager:us-east-1:account#:secret:FW_cloud_defender_installation_credentials"
}
variable "FW_defender_kms_arn" {
  type = string
  description = "KMS ARN to decrypt secret"
  default = "arn:aws:kms:us-east-1:account#:key/KeyID"
}

variable "available_ec2_types" {
  type = list(string)
  description = "Set of strings with available instances type to use as spot"
  default = [
    "t3.medium",
    "t3.large",
    "t3a.medium",
    "t3a.large"
  ]
}

variable "ecs_task_inline_policy" {
  type = string
  default = null
  description = "AWS IAM Inline Policy Document to attach to the AWS IAM Role of an AWS ECS Task"
}

variable "tags" {
  type = map(any)
  default = {}
}
