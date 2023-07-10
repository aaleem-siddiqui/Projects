provider "aws" {
  region        = "us-east-1"
  profile       = "quality_assurance"
}

terraform {
  backend "s3" {
    bucket        = "BUCKETNAME"
    # key folder should by unic
    key           = "cognito/quality_assurance-users"
    region        = "us-east-1"
    profile       = "quality_assurance"
  }
}
