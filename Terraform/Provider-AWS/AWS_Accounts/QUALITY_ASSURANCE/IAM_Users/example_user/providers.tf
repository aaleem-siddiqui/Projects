/* ------- main provider -------- */
provider "aws" {
  region          = "us-east-1"
  profile         = "quality_assurance"
}

terraform {
  backend "s3" {
    bucket        = "BUCKETNAME"
    # key folder should by unic
    key           = "IAM_users/USERNAME/terraform.tfstate"
    region        = "us-east-1"
    profile       = "quality_assurance"
  }
}
