variable "pool_name" {
  type = string
  description = "pool name to create"
}

variable "pre_sign_up_lambda" {
  type = string
  description = "pre-sign up lambda configuration"
}

variable "custom_message_lambda" {
  type = string
  description = "custom message lambda configuration"
}

variable "from_email" {
  type = string
  description = "email that SES sends messages from"
}

variable "tags" {
  type = map(any)
  description = "tags for the resource"
  default = {}
}