/* -------- MAIN PROVIDER -------- */
/* -------- DO NOT MODIFY -------- */

provider "aws" {
  alias   = "WAF-global"
  region  = "us-east-1"
  profile = AWS-WAF-ACCOUNT
}

provider "aws" {
  alias   = "WAF-us-east-1"
  region  = "us-east-1"
  profile = AWS-WAF-ACCOUNT
}

provider "aws" {
  alias   = "WAF-us-west-2"
  region  = "us-west-2"
  profile = AWS-WAF-ACCOUNT
}

provider "aws" {
  alias   = "WAF-eu-west-1"
  region  = "eu-west-1"
  profile = AWS-WAF-ACCOUNT
}

terraform {
  backend "s3" {
    bucket = "infrastructure-tfstate-WAF"
    # key folder should by unic
    key     = "WAF_IP_sets/terraform.tfstate"
    region  = "us-east-1"
    profile = AWS-WAF-ACCOUNT
  }
}