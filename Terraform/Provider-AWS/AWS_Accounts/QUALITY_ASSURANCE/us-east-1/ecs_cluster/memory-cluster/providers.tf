provider "aws" {
  region        = "us-east-1"
  profile       = "AWS_PROFILE"
}

terraform {
  backend "s3" {
    bucket        = "BUCKETNAME"
    # key folder should by unic
    key           = "us-east-1/quality_assurance/ecs_cluster/memory-cluster/terraform.tfstate"
    region        = "us-east-1"
    profile       = "AWS_PROFILE"
  }
}
