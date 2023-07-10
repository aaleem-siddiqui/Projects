/* ------- main provider -------- */
provider "aws" {
  region          = "us-east-1"
  profile         = "development"
}

terraform {
  backend "s3" {
    bucket        = "BUCKETNAME"
    # key folder should by unic
    key           = "us-east-1/vpc/service2/terraform.tfstate"
    region        = "us-east-1"
    profile       = "development"
  }
}