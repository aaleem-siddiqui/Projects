/*------------- VPC vars ------------------*/
variable "stack" {
  type = string
  default = "dev"
  description = "Stack to deploy, will be used as name tag prefix"
}
variable "project" {
  type = string
  default     = "generic"
  description = "Component name, will be used as name tag prefix"
}
variable "cidr_block" {
  type = string
  default     = "0.0.0.0/0"
  description = "The CIDR block for the VPC"
}
variable "instance_tenancy" {
  type = string
  default     = "default"
  description = "A tenancy option for instances launched into the VPC. Default is default, which makes your instances shared on the host. Using either of the other options (dedicated or host) costs at least $2/hr."
}

variable "enable_dns_hostnames" {
  type        = bool
  default     = true
  description = "A boolean flag to enable/disable DNS hostnames in the VPC. Defaults false."
}
variable "enable_dns_support" {
  type        = bool
  default     = true
  description = "A boolean flag to enable/disable DNS support in the VPC. Defaults true."
}
variable "dhcp_options_domain_name" {
  type        = string
  default     = "ec2.internal"
  description = "the suffix domain name to use by default when resolving non Fully Qualified Domain Names. In other words, this is what ends up being the search value in the /etc/resolv.conf file."
}
variable "public_subnets" {
  type        = list(string)
  default     = [
    "0.0.0.0/28",
    "0.0.0.16/28",
    "0.0.0.32/28"
  ]
  description = "The CIDR block for the subnet"
}
variable "example_application_subnets" {
  type        = list(string)
  default     = [
    "0.0.0.48/28",
    "0.0.0.64/28",
    "0.0.0.80/28"
  ]
  description = "The CIDR block for the subnet"
}
variable "nat_subnets" {
  type        = list(string)
  default     = [
    "0.0.0.80/28",
    "0.0.0.88/28",
    "0.0.0.96/28"
  ]
  description = "The CIDR block for the subnet"
}
variable "example_database_subnets" {
  type        = list(string)
  default     = [
    "0.0.0.96/28",
    "0.0.0.112/28",
    "0.0.0.128/28"
  ]
  description = "The CIDR block for the subnet"
}
variable "gateway_loadbalancer_subnets" {
  type        = list(string)
  default     = [
    "0.0.0.96/28",
    "0.0.0.112/28",
    "0.0.0.128/28"
  ]
  description = "The CIDR block for the subnet"
}
variable "availability_zone" {
  type        = list(string)
  default     = ["a","b","c","d",]
  description = "AZs letters to use"

}
variable "map_public_ip_on_launch" {
  type = bool
  default = false
  description = "Specify true to indicate that instances launched into the subnet should be assigned a public IP address"
}
variable "dhcp_options_domain_name_servers" {
  type        = list(string)
  default     = ["AmazonProvidedDNS"]
  description = "List of name servers to configure in /etc/resolv.conf. If you want to use the default AWS nameservers you should set this to AmazonProvidedDNS."
}

variable "public_ingress_ports" {
  type        = list(number)
  default     = [80, 443]
  description = "Can be specified multiple times for each ingress rule. Each ingress block supports fields documented below."
}

variable "internal_ingress_cidrs" {
  type = list(string)
  description = "The list of CIDRs for interal access rules of all traffic"
  default = []
}

variable "s3_bucket_name" {
  type = list(string)
  default = []
  description = "List of required s3 bucket names"
}

variable "local_dns" {
  type = bool
  default = false
  description = "true/false flag for conditional if we need to create private DNS"
}

variable "main_dns" {
  type = string
  default = "generic.com"
  description = "Name of private DNS zone if local_dns is true"
}

variable "tags" {
  type = map
  default = {
    APPLICATION             = "Terraform"
    COMPONENT               = "Terraform"
    CUSTOMER                = "Generic"
    CREATION                = "Generic"
  }
  description = "AWS tags for all resources created"
}
