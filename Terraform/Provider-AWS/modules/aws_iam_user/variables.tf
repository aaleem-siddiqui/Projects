variable "keybase_user" {
  default = "terraform_local"
  description = "Keybase user name for secret encription refer to fillowing page to see how to set up a kwy base [DOCUMENTATION_LINK_HERE]"
}

variable "group_name" {
  type = string
  description = "Group name to create"
}

variable "list_of_users" {
  type = list(string)
  description = "User names to create"
}

variable "list_of_policys" {
  type = list(string)
  description = "List of names of AWS default policys only"
}
