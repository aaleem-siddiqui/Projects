/* -------- SOURCE VARIABLES -------- */
/* -------- DO NOT MODIFY -------- */

variable "ip_set" {
  type        = list(any)
  description = "IP address list"
  default     = []
}

variable "scope" {
  default = "REGIONAL"
}

variable "name" {
  default = "ip-set"
}

variable "description" {
  default = "IP set, Managed by Terraform"
}

variable "ip_addr_version" {
  default = "IPV4"
}