/* -------- MAIN VARIABLES -------- */
/* -------- DO NOT MODIFY -------- */

variable "name" {
  type    = list(string)
  default = ["block-list", "block-list-ipv6"]
}

variable "description" {
  type    = string
  default = "Managed by Terraform"
}

variable "scope" {
  type        = map(any)
  description = "IP set scope"
  default = {
    REGIONAL   = "REGIONAL",
    CLOUDFRONT = "CLOUDFRONT"
  }
}

variable "ip_addr_version" {
  type        = map(any)
  description = "IP address version"
  default = {
    IPV4 = "IPV4",
    IPV6 = "IPV6"
  }
}