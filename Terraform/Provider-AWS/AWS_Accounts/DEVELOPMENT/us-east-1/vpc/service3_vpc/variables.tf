/*------------- VPC vars ------------------*/
variable "stack" {
  type = string
  default = "development"
  description = "Stack to deploy, will be used as name tag prefix"
}
variable "project" {
  type = string
  default     = "service3-pci"
  description = "Component name, will be used as name tag prefix"
}
variable "instance_tenancy" {
  default     = "default"
}
variable "enable_dns_hostnames" {
  type        = bool
  default     = true
}
variable "enable_dns_support" {
  type        = bool
  default     = true
}
variable "dhcp_options_domain_name" {
  type        = string
  default     = "ec2.internal"
}
variable "cidr_block" {
  default     = "0.0.3.0/24"
}
variable "example_application_subnets" {
  type = list(string)
  default = [
  "0.0.3.0/27",
  "0.0.3.32/27"
  ]
}
variable "public_subnets" {
  type = list(string)
  default = [
  "0.0.3.64/28",
  "0.0.3.80/28"
  ]
}
variable "gateway_loadbalancer_subnets" {
  type = list(string)
  default = [
  "0.0.3.96/28",
  "0.0.3.112/28"
  ]
}
variable "availability_zone" {
  type        = list(string)
  default     = ["a","b","c","d"]
}
variable "map_public_ip_on_launch" {
  default = false
}
variable "dhcp_options_domain_name_servers" {
  description = "Specify a list of DNS server addresses for DHCP options set, default to AWS provided (requires enable_dhcp_options set to true)"
  type        = list(string)
  default     = ["AmazonProvidedDNS"]
}
variable "public_ingress_ports" {
    type        = list(number)
    description = "list of coma seporated ingress ports"
    default     = [80, 443]
}
variable "s3_bucket_name" {
  type        = list(string)
  default     = []
}
variable "local_dns" {
  type = bool
  default = true
}
variable "main_dns" {
  type = string
  default = "generic.com"
}
variable "tags" {
  type = map
  default = {
    APPLICATION             = "GENERIC
    COMPONENT               = "INFRASTRUCTURE"
    CREATION                = "JIRA"
    ENVIRONMENT             = "development"
    MICROSERVICE            = "service3 UI"
    SERVICE                 = "VPC"
  }
}
